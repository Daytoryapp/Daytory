import 'package:date_app/src/data/date_log_repository.dart';
import 'package:date_app/src/models/date_place.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

const _testPlace = DatePlace(
  sido: '서울특별시',
  sigungu: '마포구',
  latitude: 37.5638,
  longitude: 126.9085,
);

void main() {
  setUpAll(() async {
    Hive.init('.test_hive_repo');
    await DateLogRepository.init();
  });

  tearDownAll(() async {
    await Hive.deleteBoxFromDisk('date_logs');
    await Hive.close();
  });

  group('DateLogRepository', () {
    late DateLogRepository repository;

    setUp(() {
      Hive.box<Map>('date_logs').clear();
      repository = DateLogRepository();
    });

    test('getAll returns seeded logs in descending date order', () {
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

    test('add inserts a new log and returns it', () {
      final before = repository.getAll().length;
      final now = DateTime.now();
      final added = repository.add(
        startedAt: now,
        endedAt: now.add(const Duration(hours: 2)),
        memo: '새 기록',
        moodScore: 3,
        totalCost: 30000,
        place: _testPlace,
        tags: const ['테스트'],
        photos: const [],
        title: '새 제목',
      );
      expect(repository.getAll().length, before + 1);
      expect(added.place.sigungu, '마포구');
      expect(added.id, isNotEmpty);
    });

    test('delete removes log by id', () {
      final before = repository.getAll();
      repository.delete(before.first.id);
      final after = repository.getAll();
      expect(after.length, before.length - 1);
      expect(after.any((l) => l.id == before.first.id), isFalse);
    });

    test('delete is no-op for unknown id', () {
      final before = repository.getAll().length;
      repository.delete('nonexistent-id');
      expect(repository.getAll().length, before);
    });

    test('update modifies existing log in place', () {
      final log = repository.getAll().first;
      final updated = log.copyWith(memo: '수정된 메모');
      repository.update(updated);
      final found = repository.getAll().firstWhere((l) => l.id == log.id);
      expect(found.memo, '수정된 메모');
    });
  });
}
