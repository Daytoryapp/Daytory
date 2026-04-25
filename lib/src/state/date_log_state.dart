import 'package:date_app/src/data/date_log_repository.dart';
import 'package:date_app/src/models/date_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dateLogControllerProvider =
    StateNotifierProvider<DateLogController, List<DateLog>>((ref) {
  final repository = ref.read(dateLogRepositoryProvider);
  return DateLogController(repository)..load();
});

final selectedDayProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final selectedTagFilterProvider = StateProvider<String?>((ref) => null);

final moodFilterProvider = StateProvider<int?>((ref) => null);

class DateLogController extends StateNotifier<List<DateLog>> {
  DateLogController(this._repository) : super([]);

  final DateLogRepository _repository;

  void load() {
    state = _repository.getAll();
  }

  void add({
    String? title,
    required DateTime startedAt,
    required DateTime endedAt,
    required String memo,
    required int moodScore,
    required double totalCost,
    required String placeName,
    required double latitude,
    required double longitude,
    required List<String> tags,
    required List<String> photos,
  }) {
    _repository.add(
      title: title,
      startedAt: startedAt,
      endedAt: endedAt,
      memo: memo,
      moodScore: moodScore,
      totalCost: totalCost,
      placeName: placeName,
      latitude: latitude,
      longitude: longitude,
      tags: tags,
      photos: photos,
    );
    load();
  }

  void delete(String id) {
    _repository.delete(id);
    load();
  }

  void update(DateLog updatedLog) {
    _repository.update(updatedLog);
    load();
  }
}
