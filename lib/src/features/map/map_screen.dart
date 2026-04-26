import 'dart:io';
import 'dart:ui' as ui;
import 'package:date_app/src/core/constants/app_constants.dart';
import 'package:date_app/src/core/widgets/mood_widget.dart';
import 'package:date_app/src/features/detail/detail_screen.dart';
import 'package:date_app/src/models/date_log.dart';
import 'package:date_app/src/state/date_log_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';


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
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
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
            MarkerLayer(
              markers: logs.map((log) {
                return Marker(
                  point: LatLng(log.latitude, log.longitude),
                  width: 60,
                  height: 72,
                  child: GestureDetector(
                    onTap: () => _showPreview(context, log.id),
                    child: _MapMarker(log: log),
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
      builder: (_) => _MapLogPreview(logId: logId),
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
      if (path.startsWith('http') || kIsWeb) return;
      final bytes = await File(path).readAsBytes();
      if (mounted) setState(() => _bytes = bytes);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final moodScore = widget.log.moodScore.clamp(1, 5);
    final moodColor = AppConstants.moodColors[moodScore];
    final borderColor = AppConstants.moodBorderColors[moodScore];
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
            border: Border.all(color: borderColor, width: 2.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: ClipOval(
            child: _markerContent(hasPhoto, photoPath, moodScore, moodColor),
          ),
        ),
        CustomPaint(
          size: const Size(12, 7),
          painter: _TailPainter(color: borderColor),
        ),
      ],
    );
  }

  Widget _markerContent(bool hasPhoto, String? photoPath, int moodScore, Color moodColor) {
    if (_bytes != null) {
      return Image.memory(_bytes!, fit: BoxFit.cover, width: 52, height: 52);
    }
    if (hasPhoto && photoPath != null && (photoPath.startsWith('http') || photoPath.startsWith('blob:'))) {
      return Image.network(
        photoPath,
        fit: BoxFit.cover,
        width: 52,
        height: 52,
        errorBuilder: (_, __, ___) => _RabbitMarkerContent(moodScore: moodScore, moodColor: moodColor),
      );
    }
    return _RabbitMarkerContent(moodScore: moodScore, moodColor: moodColor);
  }
}

class _RabbitMarkerContent extends ConsumerWidget {
  const _RabbitMarkerContent({required this.moodScore, required this.moodColor});
  final int moodScore;
  final Color moodColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: moodColor.withAlpha(60),
      child: Center(child: MoodWidget(moodScore: moodScore, size: 32)),
    );
  }
}

// 말풍선 꼬리
class _TailPainter extends CustomPainter {
  const _TailPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
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

// ── 바텀시트 프리뷰 (ConsumerStatefulWidget) ────────────────────────────────
class _MapLogPreview extends ConsumerStatefulWidget {
  const _MapLogPreview({required this.logId});
  final String logId;

  @override
  ConsumerState<_MapLogPreview> createState() => _MapLogPreviewState();
}

class _MapLogPreviewState extends ConsumerState<_MapLogPreview> {
  bool _deleting = false;

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('기록 삭제'),
        content: const Text('이 기록을 삭제할까요?\n삭제 후 복구할 수 없어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소', style: TextStyle(color: AppConstants.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제', style: TextStyle(color: AppConstants.pink, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => _deleting = true);
      await ref.read(dateLogControllerProvider.notifier).delete(widget.logId);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(dateLogControllerProvider);
    final matches = logs.where((l) => l.id == widget.logId).toList();
    if (matches.isEmpty) return const SizedBox.shrink();

    final log = matches.first;
    final moodScore = log.moodScore.clamp(1, 5);
    final moodColor = AppConstants.moodColors[moodScore];
    final costStr = NumberFormat('#,###').format(log.totalCost.toInt());

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(color: AppConstants.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),

            // Log info row
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  child: log.photos.isNotEmpty
                      ? _PreviewThumb(path: log.photos.first, moodScore: moodScore, moodColor: moodColor)
                      : Container(
                          width: 64, height: 64,
                          color: moodColor.withAlpha(80),
                          child: Center(child: MoodWidget(moodScore: moodScore, size: 44)),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.title ?? log.placeName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConstants.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 12, color: AppConstants.textSecondary),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              '${log.placeName}  ·  $costStr원',
                              style: const TextStyle(fontSize: 13, color: AppConstants.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
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
                decoration: BoxDecoration(
                  color: AppConstants.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Text(
                  log.memo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppConstants.textSecondary, height: 1.5),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _deleting ? null : _confirmDelete,
                    icon: _deleting
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text('삭제'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                      side: const BorderSide(color: AppConstants.pinkMid),
                      foregroundColor: AppConstants.pink,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DetailScreen(log: log)));
                    },
                    style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                    child: const Text('상세 보기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewThumb extends StatefulWidget {
  const _PreviewThumb({required this.path, required this.moodScore, required this.moodColor});
  final String path;
  final int moodScore;
  final Color moodColor;

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
      return Image.network(widget.path, width: 64, height: 64, fit: BoxFit.cover);
    }
    if (_bytes != null) {
      return Image.memory(_bytes!, width: 64, height: 64, fit: BoxFit.cover);
    }
    return Container(
      width: 64, height: 64,
      color: widget.moodColor.withAlpha(80),
      child: Center(child: MoodWidget(moodScore: widget.moodScore, size: 44)),
    );
  }
}
