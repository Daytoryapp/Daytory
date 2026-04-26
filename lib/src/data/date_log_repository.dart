import 'package:date_app/src/models/date_log.dart';
import 'package:date_app/src/models/date_place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

final dateLogRepositoryProvider = Provider<DateLogRepository>((ref) {
  return DateLogRepository();
});

class DateLogRepository {
  final _client = Supabase.instance.client;
  final _uuid = const Uuid();

  String? get _kakaoId {
    final box = Hive.box<Map>('user_profile');
    final raw = box.get('data');
    if (raw == null) return null;
    return raw['kakaoId'] as String?;
  }

  Future<List<DateLog>> getAll() async {
    final id = _kakaoId;
    if (id == null) return [];
    final rows = await _client
        .from('date_logs')
        .select()
        .eq('kakao_id', id)
        .order('started_at', ascending: false);
    return rows.map((r) => DateLog.fromSupabase(r)).toList();
  }

  Future<DateLog> add({
    required DateTime startedAt,
    required DateTime endedAt,
    required String memo,
    required int moodScore,
    required double totalCost,
    required DatePlace place,
    required List<String> tags,
    required List<String> photos,
    String? title,
  }) async {
    final id = _kakaoId ?? 'anonymous';
    final log = DateLog(
      id: _uuid.v4(),
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
    await _client.from('date_logs').insert(log.toSupabase(id));
    return log;
  }

  Future<void> update(DateLog log) async {
    final id = _kakaoId ?? 'anonymous';
    await _client
        .from('date_logs')
        .update(log.toSupabase(id))
        .eq('id', log.id);
  }

  Future<void> delete(String id) async {
    await _client.from('date_logs').delete().eq('id', id);
  }
}
