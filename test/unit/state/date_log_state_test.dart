import 'package:date_app/src/state/date_log_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('DateLogController initial state', () {
    test('loads seeded data on creation', () {
      final logs = container.read(dateLogControllerProvider);
      expect(logs, isNotEmpty);
    });
  });

  group('DateLogController.add', () {
    test('appends entry and reflects in state', () {
      final before = container.read(dateLogControllerProvider).length;
      final now = DateTime.now();
      container.read(dateLogControllerProvider.notifier).add(
            startedAt: now,
            endedAt: now.add(const Duration(hours: 2)),
            memo: '테스트',
            moodScore: 3,
            totalCost: 20000,
            placeName: '테스트 장소',
            latitude: 37.5,
            longitude: 127.0,
            tags: const [],
            photos: const [],
          );
      expect(container.read(dateLogControllerProvider).length, before + 1);
    });
  });

  group('DateLogController.delete', () {
    test('removes entry from state', () {
      final target = container.read(dateLogControllerProvider).first;
      container.read(dateLogControllerProvider.notifier).delete(target.id);
      final after = container.read(dateLogControllerProvider);
      expect(after.any((l) => l.id == target.id), isFalse);
    });
  });

  group('DateLogController.update', () {
    test('reflects updated fields in state', () {
      final target = container.read(dateLogControllerProvider).first;
      final updated = target.copyWith(memo: '수정 메모', moodScore: 1);
      container.read(dateLogControllerProvider.notifier).update(updated);
      final found = container
          .read(dateLogControllerProvider)
          .firstWhere((l) => l.id == target.id);
      expect(found.memo, '수정 메모');
      expect(found.moodScore, 1);
    });
  });

  group('selectedDayProvider', () {
    test('defaults to today', () {
      final today = DateTime.now();
      final selected = container.read(selectedDayProvider);
      expect(selected.year, today.year);
      expect(selected.month, today.month);
      expect(selected.day, today.day);
    });
  });
}
