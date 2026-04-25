class DateLog {
  DateLog({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.memo,
    required this.moodScore,
    required this.totalCost,
    required this.placeName,
    required this.latitude,
    required this.longitude,
    required this.tags,
    required this.photos,
    this.title,
  });

  final String id;
  final String? title;
  final DateTime startedAt;
  final DateTime endedAt;
  final String memo;
  final int moodScore;
  final double totalCost;
  final String placeName;
  final double latitude;
  final double longitude;
  final List<String> tags;
  final List<String> photos;

  String get dayKey =>
      "${startedAt.year.toString().padLeft(4, '0')}-${startedAt.month.toString().padLeft(2, '0')}-${startedAt.day.toString().padLeft(2, '0')}";

  String get monthKey =>
      "${startedAt.year.toString().padLeft(4, '0')}-${startedAt.month.toString().padLeft(2, '0')}";

  DateLog copyWith({
    String? id,
    String? title,
    DateTime? startedAt,
    DateTime? endedAt,
    String? memo,
    int? moodScore,
    double? totalCost,
    String? placeName,
    double? latitude,
    double? longitude,
    List<String>? tags,
    List<String>? photos,
  }) {
    return DateLog(
      id: id ?? this.id,
      title: title ?? this.title,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      memo: memo ?? this.memo,
      moodScore: moodScore ?? this.moodScore,
      totalCost: totalCost ?? this.totalCost,
      placeName: placeName ?? this.placeName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      tags: tags ?? this.tags,
      photos: photos ?? this.photos,
    );
  }
}
