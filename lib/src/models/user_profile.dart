class UserProfile {
  final String kakaoId;
  final String kakaoNickname;
  final String? kakaoProfileImageUrl;
  final String? coupleNickname;
  final DateTime? anniversaryDate;

  const UserProfile({
    required this.kakaoId,
    required this.kakaoNickname,
    this.kakaoProfileImageUrl,
    this.coupleNickname,
    this.anniversaryDate,
  });

  bool get isComplete => coupleNickname != null && coupleNickname!.isNotEmpty;

  Map<String, dynamic> toMap() => {
        'kakaoId': kakaoId,
        'kakaoNickname': kakaoNickname,
        'kakaoProfileImageUrl': kakaoProfileImageUrl,
        'coupleNickname': coupleNickname,
        'anniversaryDate': anniversaryDate?.toIso8601String(),
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        kakaoId: map['kakaoId'] as String,
        kakaoNickname: map['kakaoNickname'] as String,
        kakaoProfileImageUrl: map['kakaoProfileImageUrl'] as String?,
        coupleNickname: map['coupleNickname'] as String?,
        anniversaryDate: map['anniversaryDate'] != null
            ? DateTime.parse(map['anniversaryDate'] as String)
            : null,
      );

  UserProfile copyWith({String? coupleNickname, DateTime? anniversaryDate}) =>
      UserProfile(
        kakaoId: kakaoId,
        kakaoNickname: kakaoNickname,
        kakaoProfileImageUrl: kakaoProfileImageUrl,
        coupleNickname: coupleNickname ?? this.coupleNickname,
        anniversaryDate: anniversaryDate ?? this.anniversaryDate,
      );
}
