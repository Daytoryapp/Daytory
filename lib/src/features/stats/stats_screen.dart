import 'package:date_app/src/state/date_log_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(dateLogControllerProvider);
    final totalCount = logs.length;
    final totalCost = logs.fold<double>(0, (sum, item) => sum + item.totalCost);
    final avgMood = logs.isEmpty
        ? 0
        : logs.fold<int>(0, (sum, item) => sum + item.moodScore) / logs.length;

    final monthMap = <String, int>{};
    for (final log in logs) {
      monthMap[log.monthKey] = (monthMap[log.monthKey] ?? 0) + 1;
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("통계", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          _StatCard(label: "총 데이트 횟수", value: "$totalCount회"),
          _StatCard(label: "총 비용", value: "${totalCost.toInt()}원"),
          _StatCard(label: "평균 감정 점수", value: "${avgMood.toStringAsFixed(1)}점"),
          const SizedBox(height: 12),
          Text("월별 횟수", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (monthMap.isEmpty)
            const Text("표시할 기록이 없습니다.")
          else
            ...monthMap.entries.map(
              (entry) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(entry.key),
                trailing: Text("${entry.value}회"),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(value, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
