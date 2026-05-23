import 'package:date_app/src/core/constants/app_constants.dart';
import 'package:date_app/src/core/widgets/mood_widget.dart';
import 'package:date_app/src/features/add/widgets/image_picker_row.dart';
import 'package:date_app/src/features/add/widgets/place_picker.dart';
import 'package:date_app/src/models/date_log.dart';
import 'package:date_app/src/models/date_place.dart';
import 'package:date_app/src/state/date_log_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AddLogScreen extends ConsumerStatefulWidget {
  const AddLogScreen({super.key, this.editLog});
  final DateLog? editLog;

  @override
  ConsumerState<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends ConsumerState<AddLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _memoController = TextEditingController();
  final _costController = TextEditingController();

  final List<DatePlace> _selectedPlaces = [];
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay(
    hour: (TimeOfDay.now().hour + 2).clamp(0, 23),
    minute: TimeOfDay.now().minute,
  );
  int _mood = 4;
  List<String> _existingPhotoUrls = [];
  List<XFile> _newImages = [];
  final Set<String> _selectedTags = {};
  bool _uploading = false;

  bool get _isEditing => widget.editLog != null;

  @override
  void initState() {
    super.initState();
    final log = widget.editLog;
    if (log != null) {
      _titleController.text = log.title ?? '';
      _memoController.text = log.memo;
      _costController.text = log.totalCost == 0 ? '' : log.totalCost.toInt().toString();
      _selectedDate = log.startedAt;
      _startTime = TimeOfDay.fromDateTime(log.startedAt);
      _endTime = TimeOfDay.fromDateTime(log.endedAt);
      _mood = log.moodScore;
      _selectedPlaces.addAll(log.places);
      _selectedTags.addAll(log.tags);
      _existingPhotoUrls = List.of(log.photos);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.surfaceWarm,
      appBar: AppBar(
        backgroundColor: AppConstants.surfaceWarm,
        elevation: 0,
        title: Text(
          _isEditing ? '기록 수정' : '기록 작성',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppConstants.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppConstants.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이미지
                const _SectionLabel(label: '사진 (최대 5장) · 길게 눌러 순서 변경'),
                ImagePickerRow(
                  initialUrls: _existingPhotoUrls,
                  onChanged: (keptUrls, newFiles) {
                    _existingPhotoUrls = keptUrls;
                    _newImages = newFiles;
                  },
                ),
                const SizedBox(height: 16),

                // 제목
                const _SectionLabel(label: '제목 (선택)'),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(hintText: '어떤 데이트였나요?'),
                ),
                const SizedBox(height: 14),

                // 코스 (복수 장소)
                const _SectionLabel(label: '코스 * · 길게 눌러 순서 변경'),
                _CoursePicker(
                  places: _selectedPlaces,
                  onAdd: () async {
                    final result = await PlacePicker.show(context);
                    if (result != null) setState(() => _selectedPlaces.add(result));
                  },
                  onRemove: (i) => setState(() => _selectedPlaces.removeAt(i)),
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex--;
                      final item = _selectedPlaces.removeAt(oldIndex);
                      _selectedPlaces.insert(newIndex, item);
                    });
                  },
                ),
                const SizedBox(height: 14),

                // 날짜 & 시간
                const _SectionLabel(label: '날짜'),
                _DateField(
                  date: _selectedDate,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppConstants.pink),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                ),
                const SizedBox(height: 10),
                const _SectionLabel(label: '시간'),
                Row(
                  children: [
                    Expanded(
                      child: _TimeField(
                        label: '시작',
                        time: _startTime,
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _startTime,
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppConstants.pink),
                              ),
                              child: child!,
                            ),
                          );
                          if (picked != null) setState(() => _startTime = picked);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TimeField(
                        label: '종료',
                        time: _endTime,
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _endTime,
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppConstants.pink),
                              ),
                              child: child!,
                            ),
                          );
                          if (picked != null) setState(() => _endTime = picked);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 메모
                const _SectionLabel(label: '메모 *'),
                TextFormField(
                  controller: _memoController,
                  maxLines: 4,
                  decoration: const InputDecoration(hintText: '오늘 데이트 어땠나요?'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? '메모를 입력해 주세요' : null,
                ),
                const SizedBox(height: 14),

                // 비용
                const _SectionLabel(label: '비용'),
                TextFormField(
                  controller: _costController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: '0', suffixText: '원'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    if (double.tryParse(v) == null) return '숫자를 입력해주세요';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // 태그
                const _SectionLabel(label: '태그 (복수 선택 가능)'),
                _TagSelector(
                  selected: _selectedTags,
                  onChanged: (tags) => setState(() {
                    _selectedTags
                      ..clear()
                      ..addAll(tags);
                  }),
                ),
                const SizedBox(height: 24),

                // 감정
                const _SectionLabel(label: '오늘 감정은?'),
                const SizedBox(height: 10),
                _MoodSelector(selected: _mood, onChanged: (m) => setState(() => _mood = m)),
                const SizedBox(height: 32),

                FilledButton(
                  onPressed: _uploading ? null : _submit,
                  child: _uploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_isEditing ? '수정 저장하기' : '기록 저장하기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<String>> _uploadPhotos() async {
    if (_newImages.isEmpty) return [];
    final client = Supabase.instance.client;
    const uuid = Uuid();
    final urls = <String>[];
    for (final image in _newImages) {
      try {
        final bytes = await image.readAsBytes();
        final rawExt = image.name.contains('.')
            ? image.name.split('.').last.toLowerCase()
            : 'jpg';
        final ext = (rawExt == 'heic' || rawExt == 'heif') ? 'jpg' : rawExt;
        final path = '${DateTime.now().millisecondsSinceEpoch}_${uuid.v4()}.$ext';
        await client.storage.from('photos').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: 'image/$ext'),
        );
        final url = client.storage.from('photos').getPublicUrl(path);
        urls.add(url);
      } catch (e) {
        debugPrint('[Upload] ERROR: $e');
      }
    }
    return urls;
  }

  Future<void> _submit() async {
    if (_selectedPlaces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('장소를 하나 이상 선택해 주세요')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _uploading = true);

    final newUrls = await _uploadPhotos();
    final photoUrls = [..._existingPhotoUrls, ...newUrls];
    final cost = double.tryParse(_costController.text) ?? 0;

    final startedAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    final endedAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (_isEditing) {
      await ref.read(dateLogControllerProvider.notifier).update(
            widget.editLog!.copyWith(
              title: _titleController.text.isEmpty ? null : _titleController.text.trim(),
              startedAt: startedAt,
              endedAt: endedAt,
              memo: _memoController.text.trim(),
              moodScore: _mood,
              totalCost: cost,
              places: List.of(_selectedPlaces),
              tags: _selectedTags.toList(),
              photos: photoUrls,
            ),
          );
    } else {
      await ref.read(dateLogControllerProvider.notifier).add(
            title: _titleController.text.isEmpty ? null : _titleController.text.trim(),
            startedAt: startedAt,
            endedAt: endedAt,
            memo: _memoController.text.trim(),
            moodScore: _mood,
            totalCost: cost,
            places: List.of(_selectedPlaces),
            tags: _selectedTags.toList(),
            photos: photoUrls,
          );
    }

    if (!mounted) return;
    setState(() => _uploading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEditing ? '수정되었습니다' : '기록이 저장되었습니다')),
    );
    Navigator.of(context).pop(_isEditing);
  }
}

// ── 코스 피커 ─────────────────────────────────────────────────────────────────

class _CoursePicker extends StatelessWidget {
  const _CoursePicker({
    required this.places,
    required this.onAdd,
    required this.onRemove,
    this.onReorder,
  });
  final List<DatePlace> places;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final void Function(int oldIndex, int newIndex)? onReorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Column(
        children: [
          if (places.isNotEmpty)
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              onReorder: onReorder ?? (_, __) {},
              children: List.generate(places.length, (i) {
                return _PlaceRow(
                  key: ValueKey(i),
                  place: places[i],
                  index: i,
                  isLast: i == places.length - 1,
                  onRemove: () => onRemove(i),
                );
              }),
            ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: places.isEmpty
                    ? null
                    : const Border(top: BorderSide(color: AppConstants.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_location_alt_outlined, size: 16, color: AppConstants.pink),
                  const SizedBox(width: 6),
                  Text(
                    places.isEmpty ? '장소를 선택하세요' : '장소 추가',
                    style: TextStyle(
                      fontSize: 14,
                      color: places.isEmpty ? AppConstants.textSecondary : AppConstants.pink,
                      fontWeight: places.isEmpty ? FontWeight.w400 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceRow extends StatelessWidget {
  const _PlaceRow({
    super.key,
    required this.place,
    required this.index,
    required this.isLast,
    required this.onRemove,
  });
  final DatePlace place;
  final int index;
  final bool isLast;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_handle_rounded, size: 20, color: AppConstants.textSecondary),
              ),
              const SizedBox(width: 6),
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(color: AppConstants.pink, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.location_on_outlined, size: 16, color: AppConstants.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  place.displayName,
                  style: const TextStyle(fontSize: 14, color: AppConstants.textPrimary),
                ),
              ),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(Icons.close_rounded, size: 18, color: AppConstants.textSecondary),
              ),
            ],
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Container(width: 1.5, height: 16, color: AppConstants.pink.withAlpha(100)),
          ),
      ],
    );
  }
}

// ── 공통 위젯 ─────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppConstants.textSecondary,
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppConstants.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 18, color: AppConstants.textSecondary),
            const SizedBox(width: 8),
            Text(
              DateFormat('yyyy년 M월 d일').format(date),
              style: const TextStyle(fontSize: 14, color: AppConstants.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({required this.label, required this.time, required this.onTap});
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppConstants.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded, size: 18, color: AppConstants.textSecondary),
            const SizedBox(width: 8),
            Text(
              '$label  $h:$m',
              style: const TextStyle(fontSize: 14, color: AppConstants.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 태그 셀렉터 ──────────────────────────────────────────────────────────────

const _kPresetTags = [
  '카페', '맛집', '산책', '영화', '드라이브',
  '쇼핑', '공원', '야외', '전시', '운동',
  '여행', '홈데이트', '야경', '스포츠', '뮤지컬',
];

class _TagSelector extends StatelessWidget {
  const _TagSelector({required this.selected, required this.onChanged});
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  void _toggle(String tag) {
    final next = Set<String>.from(selected);
    if (next.contains(tag)) {
      next.remove(tag);
    } else {
      next.add(tag);
    }
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _kPresetTags.map((tag) {
        final isSelected = selected.contains(tag);
        return GestureDetector(
          onTap: () => _toggle(tag),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppConstants.pinkLight : AppConstants.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(
                color: isSelected ? AppConstants.pink : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppConstants.pink : AppConstants.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MoodSelector extends StatelessWidget {
  const _MoodSelector({required this.selected, required this.onChanged});
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (i) {
        final mood = i + 1;
        final isSelected = selected == mood;
        final color = AppConstants.moodColors[mood];
        return GestureDetector(
          onTap: () => onChanged(mood),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 60,
            height: 68,
            decoration: BoxDecoration(
              color: isSelected ? color : AppConstants.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(
                color: isSelected ? AppConstants.pink : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MoodWidget(moodScore: mood, size: isSelected ? 34 : 28),
                const SizedBox(height: 4),
                Text(
                  AppConstants.moodLabels[mood],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppConstants.pink : AppConstants.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
