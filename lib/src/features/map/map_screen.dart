import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:date_app/src/core/constants/app_constants.dart';
import 'package:date_app/src/features/detail/detail_screen.dart';
import 'package:date_app/src/models/date_log.dart';
import 'package:date_app/src/state/date_log_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

// 줌 레벨 기준: 이 이상이면 마커 표시
const double _markerShowZoom = 9.0;

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = MapController();
  double _currentZoom = 7.0;

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(dateLogControllerProvider);
    final showMarkers = _currentZoom >= _markerShowZoom;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            // 한반도 중심, 전체가 보이는 줌
            initialCenter: const LatLng(36.5, 127.8),
            initialZoom: _currentZoom,
            onMapEvent: (event) {
              if (event is MapEventMove || event is MapEventScrollWheelZoom || event is MapEventFlingAnimation) {
                final zoom = _mapController.camera.zoom;
                if ((zoom - _currentZoom).abs() > 0.1) {
                  setState(() => _currentZoom = zoom);
                }
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: AppConstants.osmTileUrl,
              userAgentPackageName: AppConstants.userAgentPackage,
            ),
            if (showMarkers)
              MarkerLayer(
                markers: logs.map((log) {
                  return Marker(
                    point: LatLng(log.latitude, log.longitude),
                    width: 60,
                    height: 72,
                    child: GestureDetector(
                      onTap: () => _showPreview(context, log.id),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: ((_currentZoom - _markerShowZoom) / 1.0).clamp(0.0, 1.0),
                        child: _MapMarker(log: log),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),

        // Header overlay
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 12, offset: const Offset(0, 2))],
                    ),
                    child: const Text('지도', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConstants.textPrimary)),
                  ),
                  const Spacer(),
                  _MapIconButton(icon: Icons.my_location_rounded, onTap: () {}),
                ],
              ),
            ),
          ),
        ),

        if (logs.isEmpty)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 12)],
              ),
              child: const Text('기록을 추가하면 지도에 표시돼요', style: TextStyle(fontSize: 14, color: AppConstants.textSecondary)),
            ),
          ),
      ],
    );
  }

  void _showPreview(BuildContext context, String logId) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXL)),
      ),
      builder: (_) => _MapLogPreview(logId: logId, ref: ref),
    );
  }
}

// ── 마커 위젯 ───────────────────────────────────────────────────────────────
class _MapMarker extends StatefulWidget {
  const _MapMarker({required this.log});
  final DateLog log;

  @override
  State<_MapMarker> createState() => _MapMarkerState();
}

class _MapMarkerState extends State<_MapMarker> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final photos = widget.log.photos;
    if (photos.isEmpty) return;
    final path = photos.first;
    try {
      Uint8List bytes;
      if (path.startsWith('http')) {
        // 네트워크 이미지는 Image.network로 처리 (별도 로드 불필요)
        return;
      } else if (kIsWeb) {
        // web: XFile blob URL → bytes
        return; // web blob URL은 Image.network로 처리
      } else {
        bytes = await File(path).readAsBytes();
      }
      if (mounted) setState(() => _bytes = bytes);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final moodColor = AppConstants.moodColors[widget.log.moodScore.clamp(1, 5)];
    final moodEmoji = AppConstants.moodEmojis[widget.log.moodScore.clamp(1, 5)];
    final hasPhoto = widget.log.photos.isNotEmpty;
    final photoPath = hasPhoto ? widget.log.photos.first : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: moodColor == Colors.transparent ? AppConstants.pink : moodColor, width: 2.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: ClipOval(
            child: _markerContent(hasPhoto, photoPath, moodEmoji, moodColor),
          ),
        ),
        // 말풍선 꼬리
        CustomPaint(
          size: const Size(12, 7),
          painter: _TailPainter(color: moodColor == Colors.transparent ? AppConstants.pink : moodColor),
        ),
      ],
    );
  }

  Widget _markerContent(bool hasPhoto, String? photoPath, String emoji, Color moodColor) {
    // 이미지 bytes 로드됨 (mobile)
    if (_bytes != null) {
      return Image.memory(_bytes!, fit: BoxFit.cover, width: 52, height: 52);
    }

    // 네트워크 or web blob URL
    if (hasPhoto && photoPath != null) {
      if (photoPath.startsWith('http') || photoPath.startsWith('blob:')) {
        return Image.network(
          photoPath,
          fit: BoxFit.cover,
          width: 52,
          height: 52,
          errorBuilder: (_, __, ___) => _EmojiContent(emoji: emoji, color: moodColor),
        );
      }
    }

    // 사진 없음 → 이모지
    return _EmojiContent(emoji: emoji, color: moodColor);
  }
}

class _EmojiContent extends StatelessWidget {
  const _EmojiContent({required this.emoji, required this.color});
  final String emoji;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withAlpha(60),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
    );
  }
}

// 말풍선 꼬리 Painter
class _TailPainter extends CustomPainter {
  const _TailPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TailPainter old) => old.color != color;
}

// ── 공통 위젯 ───────────────────────────────────────────────────────────────
class _MapIconButton extends StatelessWidget {
  const _MapIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 12, offset: const Offset(0, 2))],
        ),
        child: Icon(icon, size: 20, color: AppConstants.textPrimary),
      ),
    );
  }
}

class _MapLogPreview extends StatelessWidget {
  const _MapLogPreview({required this.logId, required this.ref});
  final String logId;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final log = ref.watch(dateLogControllerProvider).firstWhere((item) => item.id == logId);
    final moodEmoji = AppConstants.moodEmojis[log.moodScore.clamp(1, 5)];
    final moodColor = AppConstants.moodColors[log.moodScore.clamp(1, 5)];
    final costStr = NumberFormat('#,###').format(log.totalCost.toInt());

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(color: AppConstants.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // 바텀시트 썸네일도 이미지 우선
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  child: log.photos.isNotEmpty
                      ? _PreviewThumb(path: log.photos.first, moodColor: moodColor, moodEmoji: moodEmoji)
                      : Container(
                          width: 56, height: 56,
                          color: moodColor.withAlpha(80),
                          child: Center(child: Text(moodEmoji, style: const TextStyle(fontSize: 28))),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log.title ?? log.placeName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConstants.textPrimary)),
                      const SizedBox(height: 3),
                      Text('${log.placeName}  ·  $costStr원', style: const TextStyle(fontSize: 13, color: AppConstants.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            if (log.memo.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppConstants.surface, borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                child: Text(log.memo, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: AppConstants.textSecondary, height: 1.5)),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DetailScreen(log: log)));
              },
              child: const Text('상세 보기'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewThumb extends StatefulWidget {
  const _PreviewThumb({required this.path, required this.moodColor, required this.moodEmoji});
  final String path;
  final Color moodColor;
  final String moodEmoji;

  @override
  State<_PreviewThumb> createState() => _PreviewThumbState();
}

class _PreviewThumbState extends State<_PreviewThumb> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && !widget.path.startsWith('http')) {
      try {
        File(widget.path).readAsBytes().then((b) {
          if (mounted) setState(() => _bytes = b);
        });
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.path.startsWith('http') || widget.path.startsWith('blob:')) {
      return Image.network(widget.path, width: 56, height: 56, fit: BoxFit.cover);
    }
    if (_bytes != null) {
      return Image.memory(_bytes!, width: 56, height: 56, fit: BoxFit.cover);
    }
    return Container(
      width: 56, height: 56,
      color: widget.moodColor.withAlpha(80),
      child: Center(child: Text(widget.moodEmoji, style: const TextStyle(fontSize: 28))),
    );
  }
}
