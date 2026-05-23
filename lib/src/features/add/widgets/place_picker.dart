import 'dart:convert';
import 'dart:io';

import 'package:date_app/src/core/constants/app_constants.dart';
import 'package:date_app/src/core/constants/place_constants.dart';
import 'package:date_app/src/models/date_place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';

class PlacePicker extends StatefulWidget {
  const PlacePicker({super.key, required this.onSelected, this.initial});
  final ValueChanged<DatePlace> onSelected;
  final DatePlace? initial;

  static Future<DatePlace?> show(BuildContext context, {DatePlace? initial}) {
    return showModalBottomSheet<DatePlace>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXL)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (context, scrollController) => _PlacePickerContent(
          scrollController: scrollController,
          initial: initial,
        ),
      ),
    );
  }

  @override
  State<PlacePicker> createState() => _PlacePickerState();
}

class _PlacePickerState extends State<PlacePicker> {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _PlacePickerContent extends StatefulWidget {
  const _PlacePickerContent({required this.scrollController, this.initial});
  final ScrollController scrollController;
  final DatePlace? initial;

  @override
  State<_PlacePickerContent> createState() => _PlacePickerContentState();
}

class _PlacePickerContentState extends State<_PlacePickerContent> {
  SidoInfo? _selectedSido;
  SigunguInfo? _selectedSigungu;
  bool _loadingLocation = false;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _selectedSido = PlaceConstants.regions
          .where((s) => s.name == widget.initial!.sido)
          .firstOrNull;
      if (_selectedSido != null) {
        _selectedSigungu = _selectedSido!.sigungus
            .where((sg) => sg.name == widget.initial!.sigungu)
            .firstOrNull;
      }
    }
  }

  Future<void> _useCurrentLocation() async {
    if (_loadingLocation) return;
    setState(() => _loadingLocation = true);
    try {
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isEnabled) {
        if (mounted) {
          setState(() => _loadingLocation = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('기기의 위치 서비스를 활성화해 주세요.')),
          );
        }
        return;
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() => _loadingLocation = false);
          if (perm == LocationPermission.deniedForever) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('설정에서 위치 권한을 허용해 주세요.')),
            );
          }
        }
        return;
      }
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (_) {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
      }
      final place = await _reverseGeocode(pos.latitude, pos.longitude);
      if (mounted) {
        Navigator.of(context).pop(place);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치를 가져올 수 없어요.')),
        );
      }
    }
  }

  /// 카카오 로컬 API 역지오코딩 — 한국 행정구역(시도/시군구/동) 정확도 최고.
  /// REST API 키 미설정 또는 실패 시 기존 중심점 방식으로 폴백.
  Future<DatePlace> _reverseGeocode(double lat, double lon) async {
    try {
      final restKey = dotenv.env['KAKAO_REST_API_KEY'] ?? '';
      if (restKey.isEmpty || restKey == '여기에_REST_API_키_입력') {
        return _nominatimFallback(lat, lon);
      }

      // x=경도, y=위도 (카카오 API 파라미터 순서 주의)
      final uri = Uri.parse(
        'https://dapi.kakao.com/v2/local/geo/coord2address.json'
        '?x=$lon&y=$lat',
      );
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.getUrl(uri);
      request.headers.set('Authorization', 'KakaoAK $restKey');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      client.close();

      final data = jsonDecode(body) as Map<String, dynamic>;
      final docs = data['documents'] as List?;
      if (docs == null || docs.isEmpty) return _nominatimFallback(lat, lon);

      final addr = (docs.first as Map<String, dynamic>)['address'] as Map<String, dynamic>?;
      if (addr == null) return _nominatimFallback(lat, lon);

      // region_1depth_name: "경기" / region_2depth_name: "수원시 권선구" / region_3depth_name: "금곡동"
      final sido    = addr['region_1depth_name'] as String? ?? '';
      final sigungu = addr['region_2depth_name'] as String? ?? '';
      final dong    = addr['region_3depth_name'] as String? ?? '';

      if (sido.isEmpty || sigungu.isEmpty) return _nominatimFallback(lat, lon);

      return DatePlace(
        sido: sido,
        sigungu: sigungu,
        eupmyeondong: dong.isNotEmpty ? dong : null,
        latitude: lat,
        longitude: lon,
      );
    } catch (_) {
      return _nominatimFallback(lat, lon);
    }
  }

  /// Nominatim(OSM) 폴백 — 카카오 키가 없거나 API 실패 시 사용.
  Future<DatePlace> _nominatimFallback(double lat, double lon) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=$lat&lon=$lon&format=json&accept-language=ko',
      );
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.getUrl(uri);
      request.headers.set('User-Agent', 'DayStoryApp/1.0');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      client.close();

      final data = jsonDecode(body) as Map<String, dynamic>;
      final address = data['address'] as Map<String, dynamic>? ?? {};

      final rawState = address['state'] as String? ?? '';
      final sido = rawState
          .replaceAll('특별시', '').replaceAll('광역시', '')
          .replaceAll('특별자치시', '').replaceAll('특별자치도', '')
          .replaceAll('도', '').trim();

      String sigungu = address['city'] as String? ??
          address['county'] as String? ??
          address['town'] as String? ?? '';

      final district = address['city_district'] as String? ?? '';
      final suburb   = address['suburb'] as String? ?? '';
      final dong = (suburb.isNotEmpty && suburb != district)
          ? suburb
          : (address['quarter'] as String? ??
             address['neighbourhood'] as String? ??
             address['village'] as String? ?? '');

      if (district.isNotEmpty && !sigungu.contains(district)) {
        sigungu = '$sigungu $district'.trim();
      }

      if (sido.isEmpty || sigungu.isEmpty) {
        return PlaceConstants.findNearestDatePlace(lat, lon);
      }

      return DatePlace(
        sido: rawState.isNotEmpty ? rawState : sido,
        sigungu: sigungu,
        eupmyeondong: dong.isNotEmpty ? dong : null,
        latitude: lat,
        longitude: lon,
      );
    } catch (_) {
      return PlaceConstants.findNearestDatePlace(lat, lon);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppConstants.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('장소 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConstants.textPrimary)),
                  const Spacer(),
                  if (_selectedSido != null)
                    TextButton(
                      onPressed: () => setState(() {
                        _selectedSido = null;
                        _selectedSigungu = null;
                      }),
                      child: const Text('다시 선택'),
                    ),
                ],
              ),
              if (_selectedSido != null) ...[
                const SizedBox(height: 8),
                _Breadcrumb(sido: _selectedSido!.name, sigungu: _selectedSigungu?.name),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
        // 현재 위치 버튼 (시도 선택 전에만 표시)
        if (_selectedSido == null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _loadingLocation ? null : _useCurrentLocation,
                icon: _loadingLocation
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.my_location_rounded, size: 18),
                label: Text(_loadingLocation ? '위치 확인 중...' : '현재 위치 사용'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4A8FE7),
                  side: const BorderSide(color: Color(0xFF4A8FE7)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                ),
              ),
            ),
          ),
        if (_selectedSido == null) const Divider(height: 1),
        Expanded(
          child: _selectedSido == null
              ? _SidoList(
                  scrollController: widget.scrollController,
                  onSelected: (sido) => setState(() => _selectedSido = sido),
                )
              : _SigunguList(
                  scrollController: widget.scrollController,
                  sido: _selectedSido!,
                  onSelected: (sigungu) {
                    Navigator.of(context).pop(
                      PlaceConstants.toDatePlace(_selectedSido!.name, sigungu),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.sido, this.sigungu});
  final String sido;
  final String? sigungu;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Chip(label: sido),
        if (sigungu != null) ...[
          const Icon(Icons.chevron_right, size: 16, color: AppConstants.textSecondary),
          _Chip(label: sigungu!),
        ],
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppConstants.pinkLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, color: AppConstants.pink, fontWeight: FontWeight.w600)),
    );
  }
}

class _SidoList extends StatelessWidget {
  const _SidoList({required this.scrollController, required this.onSelected});
  final ScrollController scrollController;
  final ValueChanged<SidoInfo> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: PlaceConstants.regions.length,
      itemBuilder: (context, index) {
        final sido = PlaceConstants.regions[index];
        return ListTile(
          title: Text(sido.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppConstants.textPrimary)),
          subtitle: Text('${sido.sigungus.length}개 지역', style: const TextStyle(fontSize: 12, color: AppConstants.textSecondary)),
          trailing: const Icon(Icons.chevron_right, color: AppConstants.textSecondary, size: 18),
          onTap: () => onSelected(sido),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        );
      },
    );
  }
}

class _SigunguList extends StatelessWidget {
  const _SigunguList({required this.scrollController, required this.sido, required this.onSelected});
  final ScrollController scrollController;
  final SidoInfo sido;
  final ValueChanged<SigunguInfo> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: sido.sigungus.length,
      itemBuilder: (context, index) {
        final sigungu = sido.sigungus[index];
        return ListTile(
          leading: const Icon(Icons.location_on_outlined, color: AppConstants.pink, size: 20),
          title: Text(sigungu.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppConstants.textPrimary)),
          onTap: () => onSelected(sigungu),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        );
      },
    );
  }
}
