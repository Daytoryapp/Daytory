import 'package:date_app/src/models/date_place.dart';

class DateLog {
  DateLog({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.memo,
    required this.moodScore,
    required this.totalCost,
    required this.places,
    required this.tags,
    required this.photos,
    this.title,
    this.ownerKakaoId,
  }) : assert(places.isNotEmpty);

  final String id;
  final String? title;
  final String? ownerKakaoId;
  final DateTime startedAt;
  final DateTime endedAt;
  final String memo;
  final int moodScore;
  final double totalCost;
  final List<DatePlace> places;
  final List<String> tags;
  final List<String> photos;

  DatePlace get place => places.first;
  String get placeName => places.length == 1
      ? places.first.displayName
      : '${places.first.displayName} 외 ${places.length - 1}곳';
  double get latitude => places.first.latitude;
  double get longitude => places.first.longitude;

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
        'places': places.map((p) => p.toMap()).toList(),
        'tags': tags,
        'photos': photos,
        'ownerKakaoId': ownerKakaoId,
      };

  factory DateLog.fromMap(Map<String, dynamic> map) {
    final List<DatePlace> places;
    if (map['places'] != null) {
      places = (map['places'] as List)
          .map((p) => DatePlace.fromMap(Map<String, dynamic>.from(p as Map)))
          .toList();
    } else {
      places = [DatePlace.fromMap(Map<String, dynamic>.from(map['place'] as Map))];
    }
    return DateLog(
      id: map['id'] as String,
      title: map['title'] as String?,
      startedAt: DateTime.parse(map['startedAt'] as String),
      endedAt: DateTime.parse(map['endedAt'] as String),
      memo: map['memo'] as String,
      moodScore: map['moodScore'] as int,
      totalCost: (map['totalCost'] as num).toDouble(),
      places: places,
      tags: List<String>.from(map['tags'] as List),
      photos: List<String>.from(map['photos'] as List),
      ownerKakaoId: map['ownerKakaoId'] as String?,
    );
  }

  factory DateLog.fromSupabase(Map<String, dynamic> row) {
    final List<DatePlace> places;
    final rawPlaces = row['places'];
    if (rawPlaces != null && rawPlaces is List && rawPlaces.isNotEmpty) {
      places = rawPlaces
          .map((p) => DatePlace.fromMap(Map<String, dynamic>.from(p as Map)))
          .toList();
    } else {
      places = [
        DatePlace(
          sido: row['sido'] as String? ?? '',
          sigungu: row['sigungu'] as String? ?? '',
          latitude: (row['latitude'] as num?)?.toDouble() ?? 0,
          longitude: (row['longitude'] as num?)?.toDouble() ?? 0,
        ),
      ];
    }
    return DateLog(
      id: row['id'] as String,
      title: row['title'] as String?,
      startedAt: DateTime.parse(row['started_at'] as String).toLocal(),
      endedAt: DateTime.parse(row['ended_at'] as String).toLocal(),
      memo: row['memo'] as String? ?? '',
      moodScore: row['mood_score'] as int,
      totalCost: (row['total_cost'] as num).toDouble(),
      places: places,
      tags: List<String>.from((row['tags'] as List?) ?? []),
      photos: List<String>.from((row['photo_urls'] as List?) ?? []),
      ownerKakaoId: row['kakao_id'] as String?,
    );
  }

  Map<String, dynamic> toSupabase(String kakaoId) => {
        'id': id,
        'kakao_id': kakaoId,
        'title': title,
        'started_at': startedAt.toUtc().toIso8601String(),
        'ended_at': endedAt.toUtc().toIso8601String(),
        'memo': memo,
        'mood_score': moodScore,
        'total_cost': totalCost,
        // 첫 번째 장소 — 기존 컬럼 호환성 유지
        'sido': places.first.sido,
        'sigungu': places.first.sigungu,
        'latitude': places.first.latitude,
        'longitude': places.first.longitude,
        // 전체 코스
        'places': places.map((p) => p.toMap()).toList(),
        'tags': tags,
        'photo_urls': photos,
      };

  DateLog copyWith({
    String? id,
    String? title,
    DateTime? startedAt,
    DateTime? endedAt,
    String? memo,
    int? moodScore,
    double? totalCost,
    List<DatePlace>? places,
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
      places: places ?? this.places,
      tags: tags ?? this.tags,
      photos: photos ?? this.photos,
      ownerKakaoId: ownerKakaoId,
    );
  }
}
