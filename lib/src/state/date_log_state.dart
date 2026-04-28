import 'package:date_app/src/data/date_log_repository.dart';
import 'package:date_app/src/models/date_log.dart';
import 'package:date_app/src/models/date_place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dateLogControllerProvider =
    StateNotifierProvider<DateLogController, List<DateLog>>((ref) {
  final repository = ref.read(dateLogRepositoryProvider);
  return DateLogController(repository)..load();
});

final selectedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());
final selectedTagFilterProvider = StateProvider<String?>((ref) => null);
final moodFilterProvider = StateProvider<int?>((ref) => null);
final mapCategoryFilterProvider = StateProvider<String?>((ref) => null);

class DateLogController extends StateNotifier<List<DateLog>> {
  DateLogController(this._repository) : super([]);
  final DateLogRepository _repository;

  Future<void> load() async {
    final logs = await _repository.getAll();
    state = logs;
  }

  Future<void> add({
    String? title,
    required DateTime startedAt,
    required DateTime endedAt,
    required String memo,
    required int moodScore,
    required double totalCost,
    required DatePlace place,
    required List<String> tags,
    required List<String> photos,
  }) async {
    await _repository.add(
      title: title,
      startedAt: startedAt,
      endedAt: endedAt,
      memo: memo,
      moodScore: moodScore,
      totalCost: totalCost,
      place: place,
      tags: tags,
      photos: photos,
    );
    await load();
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    await load();
  }

  Future<void> update(DateLog updatedLog) async {
    await _repository.update(updatedLog);
    await load();
  }
}
