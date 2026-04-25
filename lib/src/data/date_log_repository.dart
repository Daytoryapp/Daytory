import 'package:date_app/src/models/date_log.dart';
import 'package:date_app/src/models/date_place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

final dateLogRepositoryProvider = Provider<DateLogRepository>((ref) {
  return DateLogRepository();
});

class DateLogRepository {
  static const _boxName = 'date_logs';
  final _uuid = const Uuid();

  Box<Map> get _box => Hive.box<Map>(_boxName);

  static Future<void> init() async {
    await Hive.openBox<Map>(_boxName);
  }

  List<DateLog> getAll() {
    final logs = _box.values
        .map((v) => DateLog.fromMap(Map<String, dynamic>.from(v)))
        .toList();
    logs.sort((a, b) => b.startedAt.compareTo(a.startedAt));

    // 최초 실행 시 시드 데이터 주입
    if (logs.isEmpty) {
      _seed();
      return getAll();
    }
    return logs;
  }

  void _seed() {
    final now = DateTime.now();
    final places = [
      DatePlace(sido: '서울특별시', sigungu: '마포구', latitude: 37.5638, longitude: 126.9085),
      DatePlace(sido: '서울특별시', sigungu: '마포구', latitude: 37.5572, longitude: 126.9245),
    ];
    final seeds = [
      DateLog(
        id: 'seed-1',
        title: '주말 브런치 데이트',
        startedAt: now.subtract(const Duration(days: 2)),
        endedAt: now.subtract(const Duration(days: 2)).add(const Duration(hours: 3)),
        memo: '한강 보면서 브런치 먹고 카페까지 다녀왔다.',
        moodScore: 5,
        totalCost: 48000,
        place: places[0],
        tags: const ['브런치', '산책'],
        photos: const [],
      ),
      DateLog(
        id: 'seed-2',
        title: '저녁 영화 데이트',
        startedAt: now.subtract(const Duration(days: 8)),
        endedAt: now.subtract(const Duration(days: 8)).add(const Duration(hours: 4)),
        memo: '영화 보고 근처 이자카야에서 늦은 저녁.',
        moodScore: 4,
        totalCost: 72000,
        place: places[1],
        tags: const ['영화', '저녁'],
        photos: const [],
      ),
    ];
    for (final log in seeds) {
      _box.put(log.id, log.toMap());
    }
  }

  DateLog add({
    required DateTime startedAt,
    required DateTime endedAt,
    required String memo,
    required int moodScore,
    required double totalCost,
    required DatePlace place,
    required List<String> tags,
    required List<String> photos,
    String? title,
  }) {
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
    _box.put(log.id, log.toMap());
    return log;
  }

  void update(DateLog updatedLog) {
    _box.put(updatedLog.id, updatedLog.toMap());
  }

  void delete(String id) {
    _box.delete(id);
  }
}
