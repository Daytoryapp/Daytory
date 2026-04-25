import 'package:date_app/src/core/constants/app_constants.dart';
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

    final hasFilter = selectedTag != null || selectedMood != null;

    return SafeArea(
      child: Column(
        children: [
          _Header(
            hasFilter: hasFilter,
            onFilter: () => _showFilterSheet(context, ref, logs),
          ),
          _Calendar(logs: logs, selectedDay: selectedDay, ref: ref),
          _DateSummaryRow(selectedDay: selectedDay, count: dayLogs.length),
          Expanded(
            child: dayLogs.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: dayLogs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _LogCard(log: dayLogs[index]),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXL)),
      ),
      builder: (context) {
        String? tempTag = selectedTag;
        int? tempMood = selectedMood;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 20),
                  const Text('필터', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConstants.textPrimary)),
                  const SizedBox(height: 16),
                  const Text('태그', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConstants.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FilterChip(label: '전체', selected: tempTag == null, onTap: () => setModalState(() => tempTag = null)),
                      for (final tag in allTags)
                        _FilterChip(label: tag, selected: tempTag == tag, onTap: () => setModalState(() => tempTag = tag)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('감정', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConstants.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FilterChip(label: '전체', selected: tempMood == null, onTap: () => setModalState(() => tempMood = null)),
                      for (var mood = 1; mood <= 5; mood++)
                        _FilterChip(
                          label: '${AppConstants.moodEmojis[mood]} ${AppConstants.moodLabels[mood]}',
                          selected: tempMood == mood,
                          onTap: () => setModalState(() => tempMood = mood),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            ref.read(selectedTagFilterProvider.notifier).state = null;
                            ref.read(moodFilterProvider.notifier).state = null;
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                            side: const BorderSide(color: AppConstants.border),
                            foregroundColor: AppConstants.textSecondary,
                          ),
                          child: const Text('초기화'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            ref.read(selectedTagFilterProvider.notifier).state = tempTag;
                            ref.read(moodFilterProvider.notifier).state = tempMood;
                            Navigator.of(context).pop();
                          },
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                          ),
                          child: const Text('적용'),
                        ),
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

class _Header extends StatelessWidget {
  const _Header({required this.hasFilter, required this.onFilter});
  final bool hasFilter;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
      child: Row(
        children: [
          const Text('캘린더', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppConstants.textPrimary, letterSpacing: -0.5)),
          const Spacer(),
          Stack(
            children: [
              IconButton(
                onPressed: onFilter,
                icon: const Icon(Icons.tune_rounded),
                color: AppConstants.textPrimary,
              ),
              if (hasFilter)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(color: AppConstants.pink, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Calendar extends StatelessWidget {
  const _Calendar({required this.logs, required this.selectedDay, required this.ref});
  final List<DateLog> logs;
  final DateTime selectedDay;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TableCalendar<DateLog>(
        firstDay: DateTime(2022),
        lastDay: DateTime(2032),
        focusedDay: selectedDay,
        selectedDayPredicate: (day) => isSameDay(day, selectedDay),
        eventLoader: (day) => logs.where((log) => isSameDay(log.startedAt, day)).toList(),
        onDaySelected: (selected, focused) {
          ref.read(selectedDayProvider.notifier).state = selected;
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppConstants.pinkLight,
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(color: AppConstants.pink, fontWeight: FontWeight.w700),
          selectedDecoration: const BoxDecoration(color: AppConstants.pink, shape: BoxShape.circle),
          selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          markerDecoration: const BoxDecoration(color: AppConstants.pink, shape: BoxShape.circle),
          markerSize: 5,
          outsideTextStyle: const TextStyle(color: AppConstants.border),
          weekendTextStyle: const TextStyle(color: Color(0xFFFF4D8D)),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConstants.textPrimary),
          leftChevronIcon: Icon(Icons.chevron_left, color: AppConstants.textPrimary),
          rightChevronIcon: Icon(Icons.chevron_right, color: AppConstants.textPrimary),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(fontSize: 12, color: AppConstants.textSecondary, fontWeight: FontWeight.w500),
          weekendStyle: TextStyle(fontSize: 12, color: AppConstants.pink, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _DateSummaryRow extends StatelessWidget {
  const _DateSummaryRow({required this.selectedDay, required this.count});
  final DateTime selectedDay;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Text(
            DateFormat('yyyy년 M월 d일').format(selectedDay),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppConstants.textPrimary),
          ),
          const Spacer(),
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppConstants.pinkLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count건',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConstants.pink),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('💝', style: TextStyle(fontSize: 40)),
          SizedBox(height: 12),
          Text('이 날의 기록이 없어요', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConstants.textPrimary)),
          SizedBox(height: 4),
          Text('기록 탭에서 추가해보세요', style: TextStyle(fontSize: 13, color: AppConstants.textSecondary)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppConstants.pinkLight : AppConstants.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
          border: Border.all(color: selected ? AppConstants.pink : Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? AppConstants.pink : AppConstants.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _LogCard extends ConsumerWidget {
  const _LogCard({required this.log});
  final DateLog log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodColor = AppConstants.moodColors[log.moodScore.clamp(1, 5)];
    final moodEmoji = AppConstants.moodEmojis[log.moodScore.clamp(1, 5)];
    final costStr = NumberFormat('#,###').format(log.totalCost.toInt());

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => DetailScreen(log: log)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(color: AppConstants.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: moodColor,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Center(child: Text(moodEmoji, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.title ?? log.placeName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConstants.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: AppConstants.textSecondary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          '${log.placeName}  ·  $costStr원',
                          style: const TextStyle(fontSize: 12, color: AppConstants.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (log.tags.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      children: log.tags.take(3).map((tag) => _TagBadge(tag: tag)).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => ref.read(dateLogControllerProvider.notifier).delete(log.id),
              child: const Icon(Icons.delete_outline_rounded, size: 20, color: AppConstants.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagBadge extends StatelessWidget {
  const _TagBadge({required this.tag});
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppConstants.surface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(tag, style: const TextStyle(fontSize: 11, color: AppConstants.textSecondary, fontWeight: FontWeight.w500)),
    );
  }
}
