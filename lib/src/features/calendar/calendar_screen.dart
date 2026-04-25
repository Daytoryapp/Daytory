import 'package:date_app/src/features/detail/detail_screen.dart';
import 'package:date_app/src/models/date_log.dart';
import 'package:date_app/src/state/date_log_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(dateLogControllerProvider);
    final selectedDay = ref.watch(selectedDayProvider);
    final selectedTag = ref.watch(selectedTagFilterProvider);
    final selectedMood = ref.watch(moodFilterProvider);

    final dayLogs = logs.where((log) {
      final sameDay = isSameDay(log.startedAt, selectedDay);
      final tagPass = selectedTag == null || log.tags.contains(selectedTag);
      final moodPass = selectedMood == null || log.moodScore == selectedMood;
      return sameDay && tagPass && moodPass;
    }).toList();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text("캘린더", style: Theme.of(context).textTheme.headlineSmall),
                const Spacer(),
                IconButton(
                  onPressed: () => _showFilterSheet(context, ref, logs),
                  icon: const Icon(Icons.filter_list),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TableCalendar<DateLog>(
              firstDay: DateTime(2022),
              lastDay: DateTime(2032),
              focusedDay: selectedDay,
              selectedDayPredicate: (day) => isSameDay(day, selectedDay),
              eventLoader: (day) {
                return logs.where((log) => isSameDay(log.startedAt, day)).toList();
              },
              onDaySelected: (selected, focused) {
                ref.read(selectedDayProvider.notifier).state = selected;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Text(
                  DateFormat("yyyy.MM.dd").format(selectedDay),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  "총 ${dayLogs.length}건",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Expanded(
            child: dayLogs.isEmpty
                ? const Center(child: Text("선택한 날짜의 기록이 없습니다."))
                : ListView.builder(
                    itemCount: dayLogs.length,
                    itemBuilder: (context, index) {
                      final log = dayLogs[index];
                      return _LogCard(log: log);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref, List<DateLog> logs) {
    final allTags = logs.expand((e) => e.tags).toSet().toList()..sort();
    final selectedTag = ref.read(selectedTagFilterProvider);
    final selectedMood = ref.read(moodFilterProvider);

    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        String? tempTag = selectedTag;
        int? tempMood = selectedMood;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("필터", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text("태그 전체"),
                        selected: tempTag == null,
                        onSelected: (_) => setModalState(() => tempTag = null),
                      ),
                      for (final tag in allTags)
                        ChoiceChip(
                          label: Text(tag),
                          selected: tempTag == tag,
                          onSelected: (_) => setModalState(() => tempTag = tag),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text("감정 전체"),
                        selected: tempMood == null,
                        onSelected: (_) => setModalState(() => tempMood = null),
                      ),
                      for (var mood = 1; mood <= 5; mood++)
                        ChoiceChip(
                          label: Text("$mood 점"),
                          selected: tempMood == mood,
                          onSelected: (_) => setModalState(() => tempMood = mood),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempTag = null;
                            tempMood = null;
                          });
                        },
                        child: const Text("초기화"),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () {
                          ref.read(selectedTagFilterProvider.notifier).state = tempTag;
                          ref.read(moodFilterProvider.notifier).state = tempMood;
                          Navigator.of(context).pop();
                        },
                        child: const Text("적용"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _LogCard extends ConsumerWidget {
  const _LogCard({required this.log});

  final DateLog log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        title: Text(log.title ?? log.placeName),
        subtitle: Text("${log.placeName} · 감정 ${log.moodScore}점 · ${log.totalCost.toInt()}원"),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            ref.read(dateLogControllerProvider.notifier).delete(log.id);
          },
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DetailScreen(log: log),
            ),
          );
        },
      ),
    );
  }
}
