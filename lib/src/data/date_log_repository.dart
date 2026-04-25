import 'package:date_app/src/models/date_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final dateLogRepositoryProvider = Provider<DateLogRepository>((ref) {
  return DateLogRepository();
});

class DateLogRepository {
  final _uuid = const Uuid();
  final List<DateLog> _logs = [
    DateLog(
      id: "seed-1",
      title: "주말 브런치 데이트",
      startedAt: DateTime.now().subtract(const Duration(days: 2)),
      endedAt: DateTime.now().subtract(const Duration(days: 2)).add(const Duration(hours: 3)),
      memo: "한강 보면서 브런치 먹고 카페까지 다녀왔다.",
      moodScore: 5,
      totalCost: 48000,
      placeName: "망원 한강공원",
      latitude: 37.5559,
      longitude: 126.8969,
      tags: const ["브런치", "산책"],
      photos: const [],
    ),
    DateLog(
      id: "seed-2",
      title: "저녁 영화 데이트",
      startedAt: DateTime.now().subtract(const Duration(days: 8)),
      endedAt: DateTime.now().subtract(const Duration(days: 8)).add(const Duration(hours: 4)),
      memo: "영화 보고 근처 이자카야에서 늦은 저녁.",
      moodScore: 4,
      totalCost: 72000,
      placeName: "홍대입구역",
      latitude: 37.5572,
      longitude: 126.9245,
      tags: const ["영화", "저녁"],
      photos: const [],
    ),
  ];

  List<DateLog> getAll() {
    final copy = [..._logs];
    copy.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return copy;
  }

  DateLog add({
    required DateTime startedAt,
    required DateTime endedAt,
    required String memo,
    required int moodScore,
    required double totalCost,
    required String placeName,
    required double latitude,
    required double longitude,
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
      placeName: placeName,
      latitude: latitude,
      longitude: longitude,
      tags: tags,
      photos: photos,
    );
    _logs.add(log);
    return log;
  }

  void update(DateLog updatedLog) {
    final index = _logs.indexWhere((item) => item.id == updatedLog.id);
    if (index == -1) {
      return;
    }
    _logs[index] = updatedLog;
  }

  void delete(String id) {
    _logs.removeWhere((item) => item.id == id);
  }
}
