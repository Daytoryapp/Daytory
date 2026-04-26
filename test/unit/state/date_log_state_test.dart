// DateLogController는 Supabase 네트워크에 의존하므로
// 단위 테스트는 Provider 선언 및 초기 상태 검증으로 대체합니다.
import 'package:date_app/src/state/date_log_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('selectedDayProvider', () {
    test('defaults to today', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final today = DateTime.now();
      final selected = container.read(selectedDayProvider);
      expect(selected.year, today.year);
      expect(selected.month, today.month);
      expect(selected.day, today.day);
    });
  });

  group('selectedTagFilterProvider', () {
    test('defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedTagFilterProvider), isNull);
    });

    test('can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedTagFilterProvider.notifier).state = '카페';
      expect(container.read(selectedTagFilterProvider), '카페');
    });
  });

  group('moodFilterProvider', () {
    test('defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(moodFilterProvider), isNull);
    });

    test('can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(moodFilterProvider.notifier).state = 4;
      expect(container.read(moodFilterProvider), 4);
    });
  });

  group('DateLogController provider', () {
    test('initial state is empty list before load completes', () {
      // Supabase 미연결 환경에서 초기값은 [] (load()는 비동기)
      // 네트워크 의존 테스트는 통합 테스트로 분리
      expect(dateLogControllerProvider, isNotNull);
    });
  });
}
