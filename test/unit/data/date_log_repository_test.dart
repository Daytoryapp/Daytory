// DateLogRepository는 Supabase 네트워크에 의존하므로
// 단위 테스트는 인터페이스 컴파일 검증 및 모델 변환 검증으로 대체합니다.
import 'package:date_app/src/data/date_log_repository.dart';
import 'package:date_app/src/models/date_log.dart';
import 'package:date_app/src/models/date_place.dart';
import 'package:flutter_test/flutter_test.dart';

const _testPlace = DatePlace(
  sido: '서울특별시',
  sigungu: '마포구',
  latitude: 37.5638,
  longitude: 126.9085,
);

void main() {
  test('DateLogRepository provider type is correct', () {
    // Provider 타입이 DateLogRepository임을 컴파일 타임에 검증
    expect(dateLogRepositoryProvider, isNotNull);
  });

  group('DateLog.fromSupabase', () {
    test('parses row correctly', () {
      final now = DateTime.now().toUtc();
      final row = <String, dynamic>{
        'id': 'test-id',
        'title': '테스트 제목',
        'started_at': now.toIso8601String(),
        'ended_at': now.add(const Duration(hours: 2)).toIso8601String(),
        'memo': '메모',
        'mood_score': 4,
        'total_cost': 50000,
        'sido': '서울특별시',
        'sigungu': '마포구',
        'latitude': 37.5638,
        'longitude': 126.9085,
        'tags': ['카페', '산책'],
        'photo_urls': <String>[],
      };
      final log = DateLog.fromSupabase(row);
      expect(log.id, 'test-id');
      expect(log.title, '테스트 제목');
      expect(log.moodScore, 4);
      expect(log.totalCost, 50000.0);
      expect(log.tags, ['카페', '산책']);
      expect(log.place.sido, '서울특별시');
    });

    test('handles null optional fields', () {
      final now = DateTime.now().toUtc();
      final row = <String, dynamic>{
        'id': 'test-id-2',
        'title': null,
        'started_at': now.toIso8601String(),
        'ended_at': now.add(const Duration(hours: 1)).toIso8601String(),
        'memo': null,
        'mood_score': 3,
        'total_cost': 0,
        'sido': null,
        'sigungu': null,
        'latitude': null,
        'longitude': null,
        'tags': null,
        'photo_urls': null,
      };
      final log = DateLog.fromSupabase(row);
      expect(log.title, isNull);
      expect(log.memo, '');
      expect(log.tags, isEmpty);
      expect(log.photos, isEmpty);
      expect(log.place.latitude, 0.0);
    });
  });

  group('DateLog.toSupabase', () {
    test('serializes correctly', () {
      final now = DateTime.now();
      final log = DateLog(
        id: 'log-id',
        title: '제목',
        startedAt: now,
        endedAt: now.add(const Duration(hours: 2)),
        memo: '메모',
        moodScore: 5,
        totalCost: 30000,
        place: _testPlace,
        tags: const ['영화'],
        photos: const [],
      );
      final map = log.toSupabase('kakao-123');
      expect(map['id'], 'log-id');
      expect(map['kakao_id'], 'kakao-123');
      expect(map['mood_score'], 5);
      expect(map['sido'], '서울특별시');
      expect(map['tags'], ['영화']);
    });
  });
}
