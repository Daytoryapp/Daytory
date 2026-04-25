import 'package:date_app/src/core/constants/app_constants.dart';
import 'package:date_app/src/state/date_log_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final _placeController = TextEditingController();
  final _latController = TextEditingController(text: '37.5665');
  final _lngController = TextEditingController(text: '126.9780');
  final _tagsController = TextEditingController();
  int _mood = 4;

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    _costController.dispose();
    _placeController.dispose();
    _latController.dispose();
    _lngController.dispose();
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
              const SizedBox(height: 24),

              _SectionLabel(label: '제목'),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: '어떤 데이트였나요? (선택)'),
              ),
              const SizedBox(height: 14),

              _SectionLabel(label: '장소'),
              TextFormField(
                controller: _placeController,
                decoration: const InputDecoration(hintText: '예) 성수동 카페'),
                validator: (v) => (v == null || v.isEmpty) ? '장소를 입력해 주세요' : null,
              ),
              const SizedBox(height: 14),

              _SectionLabel(label: '좌표'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: '위도'),
                      validator: (v) => double.tryParse(v ?? '') == null ? '숫자를 입력해주세요' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: '경도'),
                      validator: (v) => double.tryParse(v ?? '') == null ? '숫자를 입력해주세요' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              _SectionLabel(label: '메모'),
              TextFormField(
                controller: _memoController,
                maxLines: 4,
                decoration: const InputDecoration(hintText: '오늘 데이트 어땠나요?'),
                validator: (v) => (v == null || v.trim().isEmpty) ? '메모를 입력해 주세요' : null,
              ),
              const SizedBox(height: 14),

              _SectionLabel(label: '비용'),
              TextFormField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: '0', suffixText: '원'),
                validator: (v) => double.tryParse(v ?? '') == null ? '숫자를 입력해주세요' : null,
              ),
              const SizedBox(height: 14),

              _SectionLabel(label: '태그'),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(hintText: '카페, 영화, 드라이브 (쉼표 구분)'),
              ),
              const SizedBox(height: 24),

              _SectionLabel(label: '오늘 감정은?'),
              const SizedBox(height: 12),
              _MoodSelector(
                selected: _mood,
                onChanged: (mood) => setState(() => _mood = mood),
              ),
              const SizedBox(height: 32),

              FilledButton(
                onPressed: _submit,
                child: const Text('기록 저장하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final now = DateTime.now();
    ref.read(dateLogControllerProvider.notifier).add(
          title: _titleController.text.isEmpty ? null : _titleController.text.trim(),
          startedAt: now,
          endedAt: now.add(const Duration(hours: 2)),
          memo: _memoController.text.trim(),
          moodScore: _mood,
          totalCost: double.parse(_costController.text),
          placeName: _placeController.text.trim(),
          latitude: double.parse(_latController.text),
          longitude: double.parse(_lngController.text),
          tags: tags,
          photos: const [],
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('💝  기록이 저장되었습니다')),
    );

    _titleController.clear();
    _memoController.clear();
    _costController.clear();
    _placeController.clear();
    _tagsController.clear();
    setState(() => _mood = 4);
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConstants.textSecondary),
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
              border: Border.all(
                color: isSelected ? AppConstants.pink : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppConstants.moodEmojis[mood], style: TextStyle(fontSize: isSelected ? 28 : 22)),
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
