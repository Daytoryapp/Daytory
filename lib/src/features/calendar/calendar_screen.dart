import 'dart:io';
import 'package:date_app/src/core/constants/app_constants.dart';
import 'package:date_app/src/core/widgets/mood_widget.dart';
import 'package:date_app/src/features/detail/detail_screen.dart';
import 'package:date_app/src/models/date_log.dart';
import 'package:date_app/src/state/auth_state.dart';
import 'package:date_app/src/state/date_log_state.dart';
import 'package:flutter/foundation.dart';
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
          _Header(
            hasFilter: selectedTag != null || selectedMood != null,
            onFilter: () => _showFilterSheet(context, ref, logs),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TableCalendar<DateLog>(
              firstDay: DateTime(2020),
              lastDay: DateTime(2032),
              focusedDay: selectedDay,
              selectedDayPredicate: (day) => isSameDay(day, selectedDay),
              eventLoader: (day) => logs.where((log) => isSameDay(log.startedAt, day)).toList(),
              onDaySelected: (selected, _) => ref.read(selectedDayProvider.notifier).state = selected,
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, _) {
                  final path = _dayPhotoPath(day, logs);
                  if (path == null) return null;
                  return _CalendarPhotoCell(day: day, photoPath: path, isSelected: false, isToday: false);
                },
                selectedBuilder: (context, day, _) {
                  final path = _dayPhotoPath(day, logs);
                  if (path == null) return null;
                  return _CalendarPhotoCell(day: day, photoPath: path, isSelected: true, isToday: false);
                },
                todayBuilder: (context, day, _) {
                  final path = _dayPhotoPath(day, logs);
                  if (path == null) return null;
                  return _CalendarPhotoCell(day: day, photoPath: path, isSelected: false, isToday: true);
                },
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return const SizedBox.shrink();
                  if (events.any((e) => e.photos.isNotEmpty)) return const SizedBox.shrink();
                  final moods = events.map((e) => e.moodScore).toSet().toList()
                    ..sort();
                  return Positioned(
                    bottom: 4,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: moods.take(3).map((m) => Container(
                        width: 5, height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(color: AppConstants.moodColors[m.clamp(1, 5)], shape: BoxShape.circle),
                      )).toList(),
                    ),
                  );
                },
              ),
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(color: AppConstants.pinkLight, shape: BoxShape.circle),
                todayTextStyle: TextStyle(color: AppConstants.pink, fontWeight: FontWeight.w700),
                selectedDecoration: BoxDecoration(color: AppConstants.pink, shape: BoxShape.circle),
                selectedTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                outsideTextStyle: TextStyle(color: AppConstants.border),
                weekendTextStyle: TextStyle(color: AppConstants.pink),
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
          ),
          _DateSummaryRow(selectedDay: selectedDay, count: dayLogs.length),
          Expanded(
            child: dayLogs.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: dayLogs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _LogCard(log: dayLogs[i]),
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref, List<DateLog> logs) {
    final allTags = logs.expand((e) => e.tags).toSet().toList()..sort();
    String? tempTag = ref.read(selectedTagFilterProvider);
    int? tempMood = ref.read(moodFilterProvider);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXL))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppConstants.border, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              const Text('필터', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              const Text('태그', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConstants.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
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
                spacing: 8, runSpacing: 8,
                children: [
                  _FilterChip(label: '전체', selected: tempMood == null, onTap: () => setModalState(() => tempMood = null)),
                  for (var m = 1; m <= 5; m++)
                    _MoodFilterChip(
                      moodScore: m,
                      selected: tempMood == m,
                      onTap: () => setModalState(() => tempMood = m),
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
                      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)), side: const BorderSide(color: AppConstants.border), foregroundColor: AppConstants.textSecondary),
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
                      style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM))),
                      child: const Text('적용'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
              IconButton(onPressed: onFilter, icon: const Icon(Icons.tune_rounded), color: AppConstants.textPrimary),
              if (hasFilter)
                Positioned(right: 10, top: 10, child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppConstants.pink, shape: BoxShape.circle))),
            ],
          ),
        ],
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
          Text(DateFormat('yyyy년 M월 d일').format(selectedDay), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppConstants.textPrimary)),
          const Spacer(),
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: AppConstants.pinkLight, borderRadius: BorderRadius.circular(20)),
              child: Text('$count건', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConstants.pink)),
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

class _MoodFilterChip extends StatelessWidget {
  const _MoodFilterChip({required this.moodScore, required this.selected, required this.onTap});
  final int moodScore;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppConstants.pinkLight : AppConstants.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
          border: Border.all(color: selected ? AppConstants.pink : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MoodWidget(moodScore: moodScore, size: 20),
            const SizedBox(width: 5),
            Text(
              AppConstants.moodLabels[moodScore],
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: selected ? AppConstants.pink : AppConstants.textSecondary),
            ),
          ],
        ),
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
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: selected ? AppConstants.pink : AppConstants.textSecondary)),
      ),
    );
  }
}

class _LogCard extends ConsumerWidget {
  const _LogCard({required this.log});
  final DateLog log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodScore = log.moodScore.clamp(1, 5);
    final moodColor = AppConstants.moodColors[moodScore];
    final costStr = NumberFormat('#,###').format(log.totalCost.toInt());
    final myKakaoId = ref.watch(authStateProvider).profile?.kakaoId;
    final isPartner = myKakaoId != null && log.ownerKakaoId != null && log.ownerKakaoId != myKakaoId;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DetailScreen(log: log))),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(
            color: isPartner ? AppConstants.pinkMid : AppConstants.border,
          ),
        ),
        child: Row(
          children: [
            // 대표 이미지 or 감정 색상 블록
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              child: log.photos.isNotEmpty
                  ? _PhotoThumb(path: log.photos.first)
                  : Container(
                      width: 56, height: 56,
                      color: moodColor,
                      child: Center(child: MoodWidget(moodScore: moodScore, size: 38)),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          log.title ?? log.placeName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConstants.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isPartner) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppConstants.pinkLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('파트너', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppConstants.pink)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: AppConstants.textSecondary),
                      const SizedBox(width: 2),
                      Expanded(child: Text('${log.placeName}  ·  $costStr원', style: const TextStyle(fontSize: 12, color: AppConstants.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  if (log.tags.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(spacing: 4, children: log.tags.take(3).map((t) => _TagBadge(tag: t)).toList()),
                  ],
                ],
              ),
            ),
            if (!isPartner) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('기록 삭제'),
                      content: const Text('이 기록을 삭제할까요?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('삭제', style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await ref.read(dateLogControllerProvider.notifier).delete(log.id);
                  }
                },
                child: const Icon(Icons.delete_outline_rounded, size: 20, color: AppConstants.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PhotoThumb extends StatefulWidget {
  const _PhotoThumb({required this.path});
  final String path;

  @override
  State<_PhotoThumb> createState() => _PhotoThumbState();
}

class _PhotoThumbState extends State<_PhotoThumb> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && !widget.path.startsWith('http')) {
      try {
        _bytes = File(widget.path).readAsBytesSync();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.path.startsWith('http')) {
      return Image.network(widget.path, width: 56, height: 56, fit: BoxFit.cover);
    }
    if (_bytes != null) {
      return Image.memory(_bytes!, width: 56, height: 56, fit: BoxFit.cover);
    }
    return Container(width: 56, height: 56, color: AppConstants.surface, child: const Icon(Icons.image_outlined, color: AppConstants.textSecondary));
  }
}

class _TagBadge extends StatelessWidget {
  const _TagBadge({required this.tag});
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: AppConstants.surface, borderRadius: BorderRadius.circular(4)),
      child: Text(tag, style: const TextStyle(fontSize: 11, color: AppConstants.textSecondary, fontWeight: FontWeight.w500)),
    );
  }
}

String? _dayPhotoPath(DateTime day, List<DateLog> logs) {
  for (final log in logs) {
    if (isSameDay(log.startedAt, day) && log.photos.isNotEmpty) {
      return log.photos.first;
    }
  }
  return null;
}

class _CalendarPhotoCell extends StatefulWidget {
  const _CalendarPhotoCell({
    required this.day,
    required this.photoPath,
    required this.isSelected,
    required this.isToday,
  });

  final DateTime day;
  final String photoPath;
  final bool isSelected;
  final bool isToday;

  @override
  State<_CalendarPhotoCell> createState() => _CalendarPhotoCellState();
}

class _CalendarPhotoCellState extends State<_CalendarPhotoCell> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    if (kIsWeb || widget.photoPath.startsWith('http') || widget.photoPath.startsWith('blob:')) return;
    try {
      final bytes = await File(widget.photoPath).readAsBytes();
      if (mounted) setState(() => _bytes = bytes);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isSelected
        ? AppConstants.pink
        : widget.isToday
            ? AppConstants.pink
            : Colors.transparent;
    final borderWidth = widget.isSelected || widget.isToday ? 2.0 : 0.0;

    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: ClipOval(
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildImage(),
              ColoredBox(color: Colors.black.withAlpha(45)),
              Center(
                child: Text(
                  '${widget.day.day}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (widget.photoPath.startsWith('http') || widget.photoPath.startsWith('blob:')) {
      return Image.network(
        widget.photoPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: AppConstants.pinkLight),
      );
    }
    if (_bytes != null) {
      return Image.memory(_bytes!, fit: BoxFit.cover);
    }
    return Container(color: AppConstants.pinkLight);
  }
}
