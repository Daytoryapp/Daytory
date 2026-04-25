import 'package:date_app/src/data/date_log_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DateLogRepository repository;

  setUp(() {
    repository = DateLogRepository();
  });

  group('DateLogRepository.getAll', () {
    test('returns seeded logs in descending date order', () {
      final logs = repository.getAll();
      expect(logs.length, greaterThanOrEqualTo(2));
      for (var i = 0; i < logs.length - 1; i++) {
        expect(
          logs[i].startedAt.isAfter(logs[i + 1].startedAt) ||
              logs[i].startedAt.isAtSameMomentAs(logs[i + 1].startedAt),
          isTrue,
        );
      }
    });
  });

  group('DateLogRepository.add', () {
    test('inserts a new log and returns it', () {
      final before = repository.getAll().length;
      final now = DateTime.now();
      final added = repository.add(
        startedAt: now,
        endedAt: now.add(const Duration(hours: 2)),
        memo: '새 기록',
        moodScore: 3,
        totalCost: 30000,
        placeName: '테스트 장소',
        latitude: 37.5,
        longitude: 127.0,
        tags: const ['테스트'],
        photos: const [],
        title: '새 제목',
      );
      expect(repository.getAll().length, before + 1);
      expect(added.placeName, '테스트 장소');
      expect(added.id, isNotEmpty);
    });
  });

  group('DateLogRepository.delete', () {
    test('removes log by id', () {
      final before = repository.getAll();
      repository.delete(before.first.id);
      final after = repository.getAll();
      expect(after.length, before.length - 1);
      expect(after.any((l) => l.id == before.first.id), isFalse);
    });

    test('is no-op for unknown id', () {
      final before = repository.getAll().length;
      repository.delete('nonexistent-id');
      expect(repository.getAll().length, before);
    });
  });

  group('DateLogRepository.update', () {
    test('modifies existing log in place', () {
      final log = repository.getAll().first;
      final updated = log.copyWith(memo: '수정된 메모');
      repository.update(updated);
      final found = repository.getAll().firstWhere((l) => l.id == log.id);
      expect(found.memo, '수정된 메모');
    });

    test('is no-op for unknown id', () {
      final before = repository.getAll().length;
      final ghost = repository.getAll().first.copyWith(id: 'ghost-id');
      repository.update(ghost);
      expect(repository.getAll().length, before);
    });
  });
}
