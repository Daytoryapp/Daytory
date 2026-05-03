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

  const testPlace2 = DatePlace(
    sido: '서울특별시',
    sigungu: '강남구',
    latitude: 37.4979,
    longitude: 127.0276,
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
        places: const [testPlace],
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

    test('placeName shows single place name', () {
      expect(sut.placeName, contains('마포구'));
    });

    test('placeName shows "외 N곳" for multiple places', () {
      final multi = sut.copyWith(places: const [testPlace, testPlace2]);
      expect(multi.placeName, contains('외 1곳'));
    });

    test('place getter returns first place', () {
      expect(sut.place, testPlace);
    });

    test('latitude/longitude from first place', () {
      expect(sut.latitude, testPlace.latitude);
      expect(sut.longitude, testPlace.longitude);
    });

    test('copyWith updates only specified fields', () {
      final updated = sut.copyWith(moodScore: 5, title: '새 제목');
      expect(updated.moodScore, 5);
      expect(updated.title, '새 제목');
      expect(updated.places, sut.places);
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

    test('toMap / fromMap round-trips multiple places', () {
      final multi = sut.copyWith(places: const [testPlace, testPlace2]);
      final restored = DateLog.fromMap(multi.toMap());
      expect(restored.places.length, 2);
      expect(restored.places[1].sigungu, '강남구');
    });
  });
}
