import 'package:date_app/src/models/date_place.dart';

class DateLog {
  DateLog({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.memo,
    required this.moodScore,
    required this.totalCost,
    required this.place,
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
  final DatePlace place;
  final List<String> tags;
  final List<String> photos; // file paths (mobile) or blob URLs (web)

  String get placeName => place.displayName;
  double get latitude => place.latitude;
  double get longitude => place.longitude;

  String get dayKey =>
      '${startedAt.year.toString().padLeft(4, '0')}-${startedAt.month.toString().padLeft(2, '0')}-${startedAt.day.toString().padLeft(2, '0')}';

  String get monthKey =>
      '${startedAt.year.toString().padLeft(4, '0')}-${startedAt.month.toString().padLeft(2, '0')}';

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'memo': memo,
        'moodScore': moodScore,
        'totalCost': totalCost,
        'place': place.toMap(),
        'tags': tags,
        'photos': photos,
      };

  factory DateLog.fromMap(Map<String, dynamic> map) => DateLog(
        id: map['id'] as String,
        title: map['title'] as String?,
        startedAt: DateTime.parse(map['startedAt'] as String),
        endedAt: DateTime.parse(map['endedAt'] as String),
        memo: map['memo'] as String,
        moodScore: map['moodScore'] as int,
        totalCost: (map['totalCost'] as num).toDouble(),
        place: DatePlace.fromMap(Map<String, dynamic>.from(map['place'] as Map)),
        tags: List<String>.from(map['tags'] as List),
        photos: List<String>.from(map['photos'] as List),
      );

  DateLog copyWith({
    String? id,
    String? title,
    DateTime? startedAt,
    DateTime? endedAt,
    String? memo,
    int? moodScore,
    double? totalCost,
    DatePlace? place,
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
      place: place ?? this.place,
      tags: tags ?? this.tags,
      photos: photos ?? this.photos,
    );
  }
}
