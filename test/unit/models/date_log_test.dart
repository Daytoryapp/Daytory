import 'package:date_app/src/models/date_log.dart';
import 'package:date_app/src/models/date_place.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const testPlace = DatePlace(
    sido: '서울특별시',
    sigungu: '마포구',
    latitude: 37.5638,
    longitude: 126.9085,
  );

  group('DateLog', () {
    late DateLog sut;

    setUp(() {
      sut = DateLog(
        id: 'test-id',
        startedAt: DateTime(2026, 4, 25, 12),
        endedAt: DateTime(2026, 4, 25, 15),
        memo: '테스트 메모',
        moodScore: 4,
        totalCost: 50000,
        place: testPlace,
        tags: const ['카페', '산책'],
        photos: const [],
      );
    });

    test('dayKey returns yyyy-MM-dd format', () {
      expect(sut.dayKey, '2026-04-25');
    });

    test('monthKey returns yyyy-MM format', () {
      expect(sut.monthKey, '2026-04');
    });

    test('placeName delegates to place.displayName', () {
      expect(sut.placeName, contains('마포구'));
    });

    test('copyWith updates only specified fields', () {
      final updated = sut.copyWith(moodScore: 5, title: '새 제목');
      expect(updated.moodScore, 5);
      expect(updated.title, '새 제목');
      expect(updated.place, sut.place);
      expect(updated.id, sut.id);
    });

    test('copyWith preserves original when nothing specified', () {
      final copy = sut.copyWith();
      expect(copy.id, sut.id);
      expect(copy.memo, sut.memo);
      expect(copy.tags, sut.tags);
    });

    test('toMap / fromMap round-trips correctly', () {
      final map = sut.toMap();
      final restored = DateLog.fromMap(map);
      expect(restored.id, sut.id);
      expect(restored.memo, sut.memo);
      expect(restored.moodScore, sut.moodScore);
      expect(restored.place.sido, sut.place.sido);
      expect(restored.place.sigungu, sut.place.sigungu);
    });
  });
}
