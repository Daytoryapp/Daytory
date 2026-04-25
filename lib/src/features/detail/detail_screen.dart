import 'package:date_app/src/core/constants/app_constants.dart';
import 'package:date_app/src/models/date_log.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({required this.log, super.key});
  final DateLog log;

  @override
  Widget build(BuildContext context) {
    final moodEmoji = AppConstants.moodEmojis[log.moodScore.clamp(1, 5)];
    final moodLabel = AppConstants.moodLabels[log.moodScore.clamp(1, 5)];
    final moodColor = AppConstants.moodColors[log.moodScore.clamp(1, 5)];
    final costStr = NumberFormat('#,###').format(log.totalCost.toInt());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('데이트 기록'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          // Hero section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: moodColor.withAlpha(120),
              borderRadius: BorderRadius.circular(AppConstants.radiusXL),
            ),
            child: Row(
              children: [
                Text(moodEmoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.title ?? log.placeName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppConstants.textPrimary, letterSpacing: -0.3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$moodLabel · $moodEmoji',
                        style: const TextStyle(fontSize: 14, color: AppConstants.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Info section
          _InfoSection(
            children: [
              _InfoRow(icon: Icons.calendar_today_outlined, label: '날짜', value: DateFormat('yyyy년 M월 d일 HH:mm').format(log.startedAt)),
              _InfoRow(icon: Icons.location_on_outlined, label: '장소', value: log.placeName),
              _InfoRow(icon: Icons.payments_outlined, label: '비용', value: '$costStr원'),
            ],
          ),

          const SizedBox(height: 12),

          _InfoSection(
            children: [
              _InfoRow(icon: Icons.notes_rounded, label: '메모', value: log.memo, multiLine: true),
            ],
          ),

          if (log.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoSection(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.label_outline_rounded, size: 16, color: AppConstants.textSecondary),
                          SizedBox(width: 6),
                          Text('태그', style: TextStyle(fontSize: 13, color: AppConstants.textSecondary, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: log.tags.map((tag) => _TagChip(tag: tag)).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          _InfoSection(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.map_outlined, size: 16, color: AppConstants.textSecondary),
                        SizedBox(width: 6),
                        Text('위치 좌표', style: TextStyle(fontSize: 13, color: AppConstants.textSecondary, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppConstants.surface,
                        borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      ),
                      child: Text(
                        '${log.latitude.toStringAsFixed(6)}, ${log.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 13, color: AppConstants.textPrimary, fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppConstants.border),
      ),
      child: Column(
        children: children
            .expand((child) => [child, const Divider(height: 1)])
            .toList()
          ..removeLast(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value, this.multiLine = false});
  final IconData icon;
  final String label;
  final String value;
  final bool multiLine;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: AppConstants.textSecondary),
          const SizedBox(width: 6),
          SizedBox(
            width: 40,
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppConstants.textSecondary, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: AppConstants.textPrimary, fontWeight: FontWeight.w500),
              maxLines: multiLine ? null : 1,
              overflow: multiLine ? null : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.tag});
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppConstants.pinkLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
      ),
      child: Text(tag, style: const TextStyle(fontSize: 12, color: AppConstants.pink, fontWeight: FontWeight.w600)),
    );
  }
}
