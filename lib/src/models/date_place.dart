class DatePlace {
  const DatePlace({
    required this.sido,
    required this.sigungu,
    required this.latitude,
    required this.longitude,
    this.eupmyeondong,
  });

  final String sido;
  final String sigungu;
  final String? eupmyeondong;
  final double latitude;
  final double longitude;

  String get displayName {
    final short = sido.replaceAll('특별시', '').replaceAll('광역시', '').replaceAll('특별자치시', '').replaceAll('특별자치도', '').replaceAll('도', '');
    return eupmyeondong != null ? '$short $sigungu $eupmyeondong' : '$short $sigungu';
  }

  String get shortName => sigungu;

  Map<String, dynamic> toMap() => {
        'sido': sido,
        'sigungu': sigungu,
        'eupmyeondong': eupmyeondong,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory DatePlace.fromMap(Map<String, dynamic> map) => DatePlace(
        sido: map['sido'] as String,
        sigungu: map['sigungu'] as String,
        eupmyeondong: map['eupmyeondong'] as String?,
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
      );

  @override
  bool operator ==(Object other) =>
      other is DatePlace && sido == other.sido && sigungu == other.sigungu;

  @override
  int get hashCode => Object.hash(sido, sigungu);
}
