import 'package:date_app/src/core/constants/app_constants.dart';
import 'package:date_app/src/features/detail/detail_screen.dart';
import 'package:date_app/src/state/date_log_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(dateLogControllerProvider);

    return Stack(
      children: [
        FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(37.5665, 126.9780),
            initialZoom: 11,
          ),
          children: [
            TileLayer(
              urlTemplate: AppConstants.osmTileUrl,
              userAgentPackageName: AppConstants.userAgentPackage,
            ),
            MarkerLayer(
              markers: logs.map((log) {
                final emoji = AppConstants.moodEmojis[log.moodScore.clamp(1, 5)];
                return Marker(
                  point: LatLng(log.latitude, log.longitude),
                  width: 52,
                  height: 52,
                  child: GestureDetector(
                    onTap: () => _showPreview(context, ref, log.id),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppConstants.pink, width: 2),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
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

        // Empty hint
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

  void _showPreview(BuildContext context, WidgetRef ref, String logId) {
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
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: AppConstants.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: moodColor,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Center(child: Text(moodEmoji, style: const TextStyle(fontSize: 28))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.title ?? log.placeName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConstants.textPrimary),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${log.placeName}  ·  $costStr원',
                        style: const TextStyle(fontSize: 13, color: AppConstants.textSecondary),
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
