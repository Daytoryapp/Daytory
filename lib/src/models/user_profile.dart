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
  final String? inviteCode;
  final String? partnerKakaoId;
  final String? partnerNickname;
  final String? partnerProfileImageUrl;
  final String? partnerGender;

  const UserProfile({
    required this.kakaoId,
    required this.kakaoNickname,
    this.kakaoProfileImageUrl,
    this.coupleNickname,
    this.anniversaryDate,
    this.gender,
    this.name,
    this.birthdate,
    this.inviteCode,
    this.partnerKakaoId,
    this.partnerNickname,
    this.partnerProfileImageUrl,
    this.partnerGender,
  });

  bool get isComplete => coupleNickname != null && coupleNickname!.isNotEmpty;

  bool get isLinked => partnerKakaoId != null;

  String get avatarEmoji => gender == 'male' ? '🦊' : '🐰';

  String get partnerAvatarEmoji => partnerGender == 'male' ? '🦊' : '🐰';

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
        'inviteCode': inviteCode,
        'partnerKakaoId': partnerKakaoId,
        'partnerNickname': partnerNickname,
        'partnerProfileImageUrl': partnerProfileImageUrl,
        'partnerGender': partnerGender,
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
        inviteCode: map['inviteCode'] as String?,
        partnerKakaoId: map['partnerKakaoId'] as String?,
        partnerNickname: map['partnerNickname'] as String?,
        partnerProfileImageUrl: map['partnerProfileImageUrl'] as String?,
        partnerGender: map['partnerGender'] as String?,
      );

  UserProfile copyWith({
    String? coupleNickname,
    DateTime? anniversaryDate,
    String? gender,
    String? name,
    DateTime? birthdate,
    String? inviteCode,
    String? partnerKakaoId,
    String? partnerNickname,
    String? partnerProfileImageUrl,
    String? partnerGender,
    bool clearPartner = false,
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
        inviteCode: inviteCode ?? this.inviteCode,
        partnerKakaoId: clearPartner ? null : (partnerKakaoId ?? this.partnerKakaoId),
        partnerNickname: clearPartner ? null : (partnerNickname ?? this.partnerNickname),
        partnerProfileImageUrl: clearPartner ? null : (partnerProfileImageUrl ?? this.partnerProfileImageUrl),
        partnerGender: clearPartner ? null : (partnerGender ?? this.partnerGender),
      );
}
