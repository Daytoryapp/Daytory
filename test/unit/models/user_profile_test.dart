import 'package:date_app/src/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const baseProfile = UserProfile(
    kakaoId: 'user-001',
    kakaoNickname: '테스트유저',
    kakaoProfileImageUrl: 'https://example.com/img.jpg',
    coupleNickname: '우리커플',
    inviteCode: 'ABC123',
    gender: 'female',
    name: '홍길동',
    partnerKakaoId: 'partner-001',
    partnerNickname: '파트너',
    partnerProfileImageUrl: 'https://example.com/partner.jpg',
    partnerGender: 'male',
  );

  group('UserProfile.isComplete', () {
    test('coupleNickname이 있으면 true', () {
      expect(baseProfile.isComplete, isTrue);
    });

    test('coupleNickname이 null이면 false', () {
      const profile = UserProfile(kakaoId: 'u', kakaoNickname: 'n');
      expect(profile.isComplete, isFalse);
    });

    test('coupleNickname이 빈 문자열이면 false', () {
      const profile = UserProfile(
          kakaoId: 'u', kakaoNickname: 'n', coupleNickname: '');
      expect(profile.isComplete, isFalse);
    });
  });

  group('UserProfile.isLinked', () {
    test('partnerKakaoId가 있으면 true', () {
      expect(baseProfile.isLinked, isTrue);
    });

    test('partnerKakaoId가 null이면 false', () {
      const profile = UserProfile(kakaoId: 'u', kakaoNickname: 'n');
      expect(profile.isLinked, isFalse);
    });
  });

  group('UserProfile.avatarEmoji', () {
    test('gender가 male이면 여우 이모지', () {
      const profile =
          UserProfile(kakaoId: 'u', kakaoNickname: 'n', gender: 'male');
      expect(profile.avatarEmoji, '🦊');
    });

    test('gender가 female이면 토끼 이모지', () {
      const profile =
          UserProfile(kakaoId: 'u', kakaoNickname: 'n', gender: 'female');
      expect(profile.avatarEmoji, '🐰');
    });

    test('gender가 null이면 토끼 이모지(기본값)', () {
      const profile = UserProfile(kakaoId: 'u', kakaoNickname: 'n');
      expect(profile.avatarEmoji, '🐰');
    });
  });

  group('UserProfile.toMap / fromMap', () {
    test('round-trip: 모든 필드가 복원됨', () {
      final map = baseProfile.toMap();
      final restored = UserProfile.fromMap(map);

      expect(restored.kakaoId, baseProfile.kakaoId);
      expect(restored.kakaoNickname, baseProfile.kakaoNickname);
      expect(restored.kakaoProfileImageUrl, baseProfile.kakaoProfileImageUrl);
      expect(restored.coupleNickname, baseProfile.coupleNickname);
      expect(restored.inviteCode, baseProfile.inviteCode);
      expect(restored.gender, baseProfile.gender);
      expect(restored.name, baseProfile.name);
      expect(restored.partnerKakaoId, baseProfile.partnerKakaoId);
      expect(restored.partnerNickname, baseProfile.partnerNickname);
      expect(restored.partnerGender, baseProfile.partnerGender);
    });

    test('null 필드는 round-trip 후에도 null 유지', () {
      const minimal = UserProfile(kakaoId: 'u', kakaoNickname: 'n');
      final restored = UserProfile.fromMap(minimal.toMap());

      expect(restored.inviteCode, isNull);
      expect(restored.partnerKakaoId, isNull);
      expect(restored.coupleNickname, isNull);
    });

    test('anniversaryDate가 올바르게 직렬화됨', () {
      final profile = UserProfile(
        kakaoId: 'u',
        kakaoNickname: 'n',
        anniversaryDate: DateTime(2024, 2, 14),
      );
      final restored = UserProfile.fromMap(profile.toMap());
      expect(restored.anniversaryDate, DateTime(2024, 2, 14));
    });

    test('fromMap: kakaoId가 없으면 TypeError', () {
      expect(
        () => UserProfile.fromMap({'kakaoNickname': 'n'}),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('UserProfile.copyWith', () {
    test('inviteCode가 null인 프로파일에 copyWith(inviteCode: ...) 적용 가능', () {
      const profile = UserProfile(kakaoId: 'u', kakaoNickname: 'n');
      final updated = profile.copyWith(inviteCode: 'XYZ789');
      expect(updated.inviteCode, 'XYZ789');
    });

    test('지정하지 않은 필드는 원본 값 유지', () {
      final updated = baseProfile.copyWith(coupleNickname: '새커플명');
      expect(updated.coupleNickname, '새커플명');
      expect(updated.kakaoId, baseProfile.kakaoId);
      expect(updated.inviteCode, baseProfile.inviteCode);
      expect(updated.partnerKakaoId, baseProfile.partnerKakaoId);
    });

    test('clearPartner=true면 파트너 관련 필드가 null로 초기화됨', () {
      final cleared = baseProfile.copyWith(clearPartner: true);
      expect(cleared.partnerKakaoId, isNull);
      expect(cleared.partnerNickname, isNull);
      expect(cleared.partnerProfileImageUrl, isNull);
      expect(cleared.partnerGender, isNull);
    });

    test('clearPartner=true여도 내 정보는 보존됨', () {
      final cleared = baseProfile.copyWith(clearPartner: true);
      expect(cleared.kakaoId, baseProfile.kakaoId);
      expect(cleared.inviteCode, baseProfile.inviteCode);
      expect(cleared.coupleNickname, baseProfile.coupleNickname);
    });

    test('clearPartner=false(기본값)면 파트너 필드 유지', () {
      final updated = baseProfile.copyWith(coupleNickname: '변경');
      expect(updated.partnerKakaoId, baseProfile.partnerKakaoId);
    });

    test('partnerKakaoId를 명시적으로 새 값으로 업데이트 가능', () {
      final updated = baseProfile.copyWith(partnerKakaoId: 'new-partner');
      expect(updated.partnerKakaoId, 'new-partner');
    });
  });
}
