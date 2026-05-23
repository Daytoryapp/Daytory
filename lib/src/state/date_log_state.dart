import 'package:date_app/src/data/date_log_repository.dart';
import 'package:date_app/src/models/date_log.dart';
import 'package:date_app/src/models/date_place.dart';
import 'package:date_app/src/state/auth_state.dart' as app_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 파트너 신규 기록 알림 메시지 큐. 순서대로 소비됨.
final partnerNotificationProvider = StateProvider<List<String>>((ref) => const []);

final dateLogControllerProvider =
    StateNotifierProvider<DateLogController, List<DateLog>>((ref) {
  final repository = ref.read(dateLogRepositoryProvider);
  final controller = DateLogController(repository)..load();

  RealtimeChannel? partnerChannel;

  void subscribeToPartner(String? partnerId) {
    partnerChannel?.unsubscribe();
    partnerChannel = null;
    if (partnerId == null) return;

    partnerChannel = Supabase.instance.client
        .channel('partner_logs_$partnerId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'date_logs',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'kakao_id',
            value: partnerId,
          ),
          callback: (_) async {
            await controller.load();
            final notifier = ref.read(partnerNotificationProvider.notifier);
            notifier.state = [...notifier.state, '파트너가 새 데이트를 기록했어요 💕'];
          },
        )
        .subscribe();
  }

  // 앱 시작 시 이미 연결된 파트너 구독
  subscribeToPartner(ref.read(app_auth.authStateProvider).profile?.partnerKakaoId);

  ref.listen<app_auth.AuthState>(app_auth.authStateProvider, (previous, next) {
    if (previous?.profile?.partnerKakaoId != next.profile?.partnerKakaoId) {
      controller.load();
      subscribeToPartner(next.profile?.partnerKakaoId);
    }
  });

  ref.onDispose(() {
    partnerChannel?.unsubscribe();
  });

  return controller;
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
    required List<DatePlace> places,
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
      places: places,
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
