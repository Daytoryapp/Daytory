class UserProfile {
  final String kakaoId;
  final String kakaoNickname;
  final String? kakaoProfileImageUrl;
  final String? coupleNickname;
  final DateTime? anniversaryDate;
  // 'male' | 'female' | null(미선택)
  final String? gender;
  final String? name;
  final DateTime? birthdate;

  const UserProfile({
    required this.kakaoId,
    required this.kakaoNickname,
    this.kakaoProfileImageUrl,
    this.coupleNickname,
    this.anniversaryDate,
    this.gender,
    this.name,
    this.birthdate,
  });

  bool get isComplete => coupleNickname != null && coupleNickname!.isNotEmpty;

  String get avatarEmoji => gender == 'male' ? '🦊' : '🐰';

  bool get isMale => gender == 'male';

  Map<String, dynamic> toMap() => {
        'kakaoId': kakaoId,
        'kakaoNickname': kakaoNickname,
        'kakaoProfileImageUrl': kakaoProfileImageUrl,
        'coupleNickname': coupleNickname,
        'anniversaryDate': anniversaryDate?.toIso8601String(),
        'gender': gender,
        'name': name,
        'birthdate': birthdate?.toIso8601String(),
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        kakaoId: map['kakaoId'] as String,
        kakaoNickname: map['kakaoNickname'] as String,
        kakaoProfileImageUrl: map['kakaoProfileImageUrl'] as String?,
        coupleNickname: map['coupleNickname'] as String?,
        anniversaryDate: map['anniversaryDate'] != null
            ? DateTime.parse(map['anniversaryDate'] as String)
            : null,
        gender: map['gender'] as String?,
        name: map['name'] as String?,
        birthdate: map['birthdate'] != null
            ? DateTime.tryParse(map['birthdate'] as String)
            : null,
      );

  UserProfile copyWith({
    String? coupleNickname,
    DateTime? anniversaryDate,
    String? gender,
    String? name,
    DateTime? birthdate,
  }) =>
      UserProfile(
        kakaoId: kakaoId,
        kakaoNickname: kakaoNickname,
        kakaoProfileImageUrl: kakaoProfileImageUrl,
        coupleNickname: coupleNickname ?? this.coupleNickname,
        anniversaryDate: anniversaryDate ?? this.anniversaryDate,
        gender: gender ?? this.gender,
        name: name ?? this.name,
        birthdate: birthdate ?? this.birthdate,
      );
}
