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
  final _latController = TextEditingController(text: "37.5665");
  final _lngController = TextEditingController(text: "126.9780");
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
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("기록 작성", style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "제목(선택)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _placeController,
                decoration: const InputDecoration(
                  labelText: "장소",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? "장소를 입력해 주세요." : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: "위도",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => double.tryParse(value ?? "") == null
                          ? "숫자를 입력해 주세요."
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: "경도",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => double.tryParse(value ?? "") == null
                          ? "숫자를 입력해 주세요."
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _memoController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "메모",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? "메모를 입력해 주세요." : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "비용",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    double.tryParse(value ?? "") == null ? "숫자를 입력해 주세요." : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: "태그(쉼표 구분)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text("감정 점수: $_mood점"),
              Slider(
                min: 1,
                max: 5,
                divisions: 4,
                value: _mood.toDouble(),
                label: "$_mood",
                onChanged: (value) {
                  setState(() {
                    _mood = value.toInt();
                  });
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: const Text("저장"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final tags = _tagsController.text
        .split(",")
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
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
      const SnackBar(content: Text("기록이 저장되었습니다.")),
    );

    _titleController.clear();
    _memoController.clear();
    _costController.clear();
    _placeController.clear();
    _tagsController.clear();
    setState(() {
      _mood = 4;
    });
  }
}
