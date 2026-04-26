import 'package:date_app/src/core/constants/app_constants.dart';
import 'package:date_app/src/core/widgets/rabbit_mood_widget.dart';
import 'package:date_app/src/features/add/widgets/image_picker_row.dart';
import 'package:date_app/src/features/add/widgets/place_picker.dart';
import 'package:date_app/src/models/date_place.dart';
import 'package:date_app/src/state/date_log_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AddLogScreen extends ConsumerStatefulWidget {
  const AddLogScreen({super.key});

  @override
  ConsumerState<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends ConsumerState<AddLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _memoController = TextEditingController();
  final _costController = TextEditingController();
  final _tagsController = TextEditingController();

  DatePlace? _selectedPlace;
  DateTime _selectedDate = DateTime.now();
  int _mood = 4;
  List<XFile> _images = [];
  bool _uploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    _costController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('기록 작성', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppConstants.textPrimary, letterSpacing: -0.5)),
              const SizedBox(height: 20),

              // 이미지
              const _SectionLabel(label: '사진 (최대 5장)'),
              ImagePickerRow(onChanged: (imgs) => setState(() => _images = imgs)),
              const SizedBox(height: 16),

              // 제목
              const _SectionLabel(label: '제목 (선택)'),
              TextFormField(controller: _titleController, decoration: const InputDecoration(hintText: '어떤 데이트였나요?')),
              const SizedBox(height: 14),

              // 장소
              const _SectionLabel(label: '장소 *'),
              _PlaceField(
                place: _selectedPlace,
                onTap: () async {
                  final result = await PlacePicker.show(context, initial: _selectedPlace);
                  if (result != null) setState(() => _selectedPlace = result);
                },
              ),
              const SizedBox(height: 14),

              // 날짜
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
              const _SectionLabel(label: '태그'),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(hintText: '카페, 영화, 드라이브 (쉼표 구분)'),
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
                    : const Text('기록 저장하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<String>> _uploadPhotos() async {
    if (_images.isEmpty) return [];
    final client = Supabase.instance.client;
    const uuid = Uuid();
    final urls = <String>[];
    for (final image in _images) {
      try {
        final bytes = await image.readAsBytes();
        // iOS는 HEIC로 올 수 있으므로 항상 jpeg로 처리
        final rawExt = image.name.contains('.')
            ? image.name.split('.').last.toLowerCase()
            : 'jpg';
        final ext = (rawExt == 'heic' || rawExt == 'heif') ? 'jpg' : rawExt;
        final path = '${DateTime.now().millisecondsSinceEpoch}_${uuid.v4()}.$ext';
        debugPrint('[Upload] path=$path size=${bytes.length}bytes');
        await client.storage.from('photos').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: 'image/$ext'),
        );
        final url = client.storage.from('photos').getPublicUrl(path);
        debugPrint('[Upload] success url=$url');
        urls.add(url);
      } catch (e) {
        debugPrint('[Upload] ERROR: $e');
      }
    }
    return urls;
  }

  Future<void> _submit() async {
    if (_selectedPlace == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('장소를 선택해 주세요')));
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _uploading = true);

    final photoUrls = await _uploadPhotos();

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final cost = double.tryParse(_costController.text) ?? 0;

    await ref.read(dateLogControllerProvider.notifier).add(
          title: _titleController.text.isEmpty ? null : _titleController.text.trim(),
          startedAt: _selectedDate,
          endedAt: _selectedDate.add(const Duration(hours: 2)),
          memo: _memoController.text.trim(),
          moodScore: _mood,
          totalCost: cost,
          place: _selectedPlace!,
          tags: tags,
          photos: photoUrls,
        );

    if (!mounted) return;
    setState(() => _uploading = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('기록이 저장되었습니다')));
    _reset();
  }

  void _reset() {
    _titleController.clear();
    _memoController.clear();
    _costController.clear();
    _tagsController.clear();
    setState(() {
      _selectedPlace = null;
      _selectedDate = DateTime.now();
      _mood = 4;
      _images = [];
    });
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConstants.textSecondary)),
    );
  }
}

class _PlaceField extends StatelessWidget {
  const _PlaceField({required this.place, required this.onTap});
  final DatePlace? place;
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
            const Icon(Icons.location_on_outlined, size: 18, color: AppConstants.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                place?.displayName ?? '지역을 선택하세요',
                style: TextStyle(
                  fontSize: 14,
                  color: place != null ? AppConstants.textPrimary : AppConstants.textSecondary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppConstants.textSecondary),
          ],
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
              border: Border.all(color: isSelected ? AppConstants.pink : Colors.transparent, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RabbitMoodWidget(moodScore: mood, size: isSelected ? 34 : 28),
                const SizedBox(height: 4),
                Text(
                  AppConstants.moodLabels[mood],
                  style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? AppConstants.pink : AppConstants.textSecondary),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
