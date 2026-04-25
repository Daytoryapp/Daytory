import 'package:date_app/src/models/date_log.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
        placeName: '홍대입구',
        latitude: 37.5572,
        longitude: 126.9245,
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

    test('copyWith updates only specified fields', () {
      final updated = sut.copyWith(moodScore: 5, title: '새 제목');
      expect(updated.moodScore, 5);
      expect(updated.title, '새 제목');
      expect(updated.placeName, sut.placeName);
      expect(updated.id, sut.id);
    });

    test('copyWith preserves original when nothing specified', () {
      final copy = sut.copyWith();
      expect(copy.id, sut.id);
      expect(copy.memo, sut.memo);
      expect(copy.tags, sut.tags);
    });
  });
}
