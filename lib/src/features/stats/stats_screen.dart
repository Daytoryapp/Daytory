import 'package:date_app/src/core/constants/app_constants.dart';
import 'package:date_app/src/state/date_log_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(dateLogControllerProvider);
    final totalCount = logs.length;
    final totalCost = logs.fold<double>(0, (sum, item) => sum + item.totalCost);
    final avgMood = logs.isEmpty
        ? 0.0
        : logs.fold<int>(0, (sum, item) => sum + item.moodScore) / logs.length;

    final monthMap = <String, int>{};
    for (final log in logs) {
      monthMap[log.monthKey] = (monthMap[log.monthKey] ?? 0) + 1;
    }
    final sortedMonths = monthMap.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    final moodDist = <int, int>{};
    for (final log in logs) {
      moodDist[log.moodScore] = (moodDist[log.moodScore] ?? 0) + 1;
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          const Text('통계', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppConstants.textPrimary, letterSpacing: -0.5)),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: _HeroCard(emoji: '📅', label: '총 데이트', value: '$totalCount회')),
              const SizedBox(width: 10),
              Expanded(child: _HeroCard(emoji: '💸', label: '총 비용', value: '${NumberFormat('#,###').format(totalCost.toInt())}원')),
            ],
          ),
          const SizedBox(height: 10),
          _HeroCard(
            emoji: AppConstants.moodEmojis[avgMood.round().clamp(1, 5)],
            label: '평균 감정',
            value: avgMood == 0 ? '-' : '${avgMood.toStringAsFixed(1)}점  ${AppConstants.moodLabels[avgMood.round().clamp(1, 5)]}',
            wide: true,
          ),

          if (moodDist.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionHeader(title: '감정 분포'),
            const SizedBox(height: 12),
            _MoodDistribution(distribution: moodDist, total: totalCount),
          ],

          if (sortedMonths.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionHeader(title: '월별 횟수'),
            const SizedBox(height: 12),
            ...sortedMonths.map((entry) => _MonthRow(month: entry.key, count: entry.value, max: sortedMonths.map((e) => e.value).reduce((a, b) => a > b ? a : b))),
          ],

          if (logs.isEmpty)
            const _EmptyStats(),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConstants.textPrimary));
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.emoji, required this.label, required this.value, this.wide = false});
  final String emoji;
  final String label;
  final String value;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: wide
          ? Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 12, color: AppConstants.textSecondary, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConstants.textPrimary)),
                  ],
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 8),
                Text(label, style: const TextStyle(fontSize: 12, color: AppConstants.textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConstants.textPrimary)),
              ],
            ),
    );
  }
}

class _MoodDistribution extends StatelessWidget {
  const _MoodDistribution({required this.distribution, required this.total});
  final Map<int, int> distribution;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(5, (i) {
        final mood = 5 - i;
        final count = distribution[mood] ?? 0;
        final ratio = total == 0 ? 0.0 : count / total;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(AppConstants.moodEmojis[mood], style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 8,
                    backgroundColor: AppConstants.surface,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppConstants.pink),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 24,
                child: Text('$count', style: const TextStyle(fontSize: 12, color: AppConstants.textSecondary, fontWeight: FontWeight.w600), textAlign: TextAlign.right),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _MonthRow extends StatelessWidget {
  const _MonthRow({required this.month, required this.count, required this.max});
  final String month;
  final int count;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(month, style: const TextStyle(fontSize: 13, color: AppConstants.textSecondary, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: count / max,
                minHeight: 8,
                backgroundColor: AppConstants.surface,
                valueColor: const AlwaysStoppedAnimation<Color>(AppConstants.pinkLight),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('$count회', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConstants.textPrimary)),
        ],
      ),
    );
  }
}

class _EmptyStats extends StatelessWidget {
  const _EmptyStats();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📊', style: TextStyle(fontSize: 40)),
            SizedBox(height: 12),
            Text('아직 기록이 없어요', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConstants.textPrimary)),
            SizedBox(height: 4),
            Text('데이트를 기록하면 통계가 나타나요', style: TextStyle(fontSize: 13, color: AppConstants.textSecondary)),
          ],
        ),
      ),
    );
  }
}
