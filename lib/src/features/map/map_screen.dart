import 'package:date_app/src/features/detail/detail_screen.dart';
import 'package:date_app/src/state/date_log_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(dateLogControllerProvider);
    final mapController = MapController();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text("지도", style: Theme.of(context).textTheme.headlineSmall),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_alt_outlined),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: const MapOptions(
                    initialCenter: LatLng(37.5665, 126.9780),
                    initialZoom: 11,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: "com.example.date_app",
                    ),
                    MarkerLayer(
                      markers: logs
                          .map(
                            (log) => Marker(
                              point: LatLng(log.latitude, log.longitude),
                              width: 44,
                              height: 44,
                              child: GestureDetector(
                                onTap: () {
                                  showModalBottomSheet<void>(
                                    context: context,
                                    builder: (_) => _MapLogPreview(logId: log.id),
                                  );
                                },
                                child: const Icon(
                                  Icons.location_pin,
                                  size: 42,
                                  color: Colors.pink,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        "마커를 탭하면 해당 데이트 기록 미리보기가 열립니다.",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapLogPreview extends ConsumerWidget {
  const _MapLogPreview({required this.logId});

  final String logId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = ref
        .watch(dateLogControllerProvider)
        .firstWhere((item) => item.id == logId);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(log.title ?? log.placeName, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(log.memo, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: log.tags.map((tag) => Chip(label: Text(tag))).toList(),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => DetailScreen(log: log),
                    ),
                  );
                },
                child: const Text("상세 보기"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
