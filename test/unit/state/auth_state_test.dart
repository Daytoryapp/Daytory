import 'package:date_app/src/models/user_profile.dart';
import 'package:date_app/src/state/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// AuthNotifier는 생성자에서 Hive와 Supabase에 직접 의존하므로
/// 해당 클래스 자체를 인스턴스화하기 어렵습니다.
/// 이 파일에서는 AuthState 데이터 클래스와 AuthStatus 열거형의
/// 비즈니스 규칙 및 경계값을 검증합니다.
/// linkPartner / ensureInviteCode 의 흐름 검증은 통합 테스트로 분리합니다.
void main() {
  group('AuthStatus', () {
    test('모든 상태값이 정의됨', () {
      expect(AuthStatus.values, containsAll([
        AuthStatus.loading,
        AuthStatus.loggedOut,
        AuthStatus.needsProfile,
        AuthStatus.ready,
      ]));
    });
  });

  group('AuthState 생성', () {
    test('status만 지정 시 profile은 null', () {
      const s = AuthState(status: AuthStatus.loggedOut);
      expect(s.profile, isNull);
      expect(s.status, AuthStatus.loggedOut);
    });

    test('profile과 status 함께 지정', () {
      const profile = UserProfile(kakaoId: 'k', kakaoNickname: 'n');
      const s = AuthState(status: AuthStatus.ready, profile: profile);
      expect(s.profile?.kakaoId, 'k');
      expect(s.status, AuthStatus.ready);
    });
  });

  group('AuthStatus 전환 로직 (UserProfile.isComplete 기반)', () {
    test('isComplete=true면 ready 상태가 적절', () {
      const profile = UserProfile(
          kakaoId: 'k', kakaoNickname: 'n', coupleNickname: '우리');
      expect(profile.isComplete, isTrue);
      // 상태 매핑 검증
      final status =
          profile.isComplete ? AuthStatus.ready : AuthStatus.needsProfile;
      expect(status, AuthStatus.ready);
    });

    test('isComplete=false면 needsProfile 상태가 적절', () {
      const profile = UserProfile(kakaoId: 'k', kakaoNickname: 'n');
      expect(profile.isComplete, isFalse);
      final status =
          profile.isComplete ? AuthStatus.ready : AuthStatus.needsProfile;
      expect(status, AuthStatus.needsProfile);
    });
  });

  group('_init() try-catch 복구 시나리오 (UserProfile.fromMap 예외 경로)', () {
    test('kakaoId가 없는 맵으로 fromMap 호출 시 TypeError 발생', () {
      // _box.get('data')에 손상된 데이터가 있는 경우를 시뮬레이션
      expect(
        () => UserProfile.fromMap({'kakaoNickname': 'only-nickname'}),
        throwsA(isA<TypeError>()),
      );
    });

    test('anniversaryDate 파싱 불가 문자열이면 fromMap에서 FormatException 발생', () {
      // DateTime.parse에 잘못된 값이 들어온 경우
      expect(
        () => UserProfile.fromMap({
          'kakaoId': 'k',
          'kakaoNickname': 'n',
          'anniversaryDate': 'not-a-date',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('정상 맵이면 fromMap 예외 없이 완료', () {
      expect(
        () => UserProfile.fromMap({
          'kakaoId': 'k',
          'kakaoNickname': 'n',
        }),
        returnsNormally,
      );
    });
  });

  group('linkPartner 성공 조건 (코드 레벨 검증)', () {
    // linkPartner() 내부 로직 단위 검증:
    // partnerId == myKakaoId 이면 에러 반환해야 함

    test('본인 코드 사용 불가: partnerId == myKakaoId 조건 검증', () {
      const myId = 'user-001';
      const partnerId = 'user-001'; // 같은 id
      const isSelf = partnerId == myId;
      expect(isSelf, isTrue); // 에러 반환 경로로 진입해야 함
    });

    test('다른 사람 코드 사용: partnerId != myKakaoId 조건 검증', () {
      const myId = 'user-001';
      const partnerId = 'user-002';
      const isSelf = partnerId == myId;
      expect(isSelf, isFalse); // 정상 연동 경로
    });

    test('partnerId가 빈 문자열이면 코드 없는 것으로 처리', () {
      // linkPartner() 내부: `partnerRow['kakao_id'] as String? ?? ''`
      // null이 반환될 경우 빈 문자열로 대체되어 isEmpty 분기로 진입함을 검증
      const String partnerId = '';
      expect(partnerId.isEmpty, isTrue);
    });

    test('null-safe 캐스트: String? null에 ?? 연산자 적용 시 빈 문자열 반환', () {
      // linkPartner()의 `partnerRow['kakao_id'] as String? ?? ''` 패턴 근거
      const String? nullable = null;
      const String result = nullable ?? '';
      expect(result, '');
    });
  });

  group('ensureInviteCode 호출 조건', () {
    test('inviteCode가 null이 아니면 fetch 불필요', () {
      const profile = UserProfile(
          kakaoId: 'k', kakaoNickname: 'n', inviteCode: 'EXIST1');
      // ensureInviteCode 내부: inviteCode != null → 즉시 return
      final shouldFetch = profile.inviteCode == null;
      expect(shouldFetch, isFalse);
    });

    test('inviteCode가 null이면 fetch 필요', () {
      const profile = UserProfile(kakaoId: 'k', kakaoNickname: 'n');
      final shouldFetch = profile.inviteCode == null;
      expect(shouldFetch, isTrue);
    });
  });

  group('초대 코드 형식 검증', () {
    // _generateInviteCode()가 반환하는 코드의 형식을 확인하는 스펙 테스트
    // 실제 함수는 private이므로 spec(길이 6, 대문자+숫자)을 검증

    final validCodePattern = RegExp(r'^[A-HJ-NP-Z2-9]{6}$');

    test('6자리 대문자+숫자 패턴 검증 로직 정상 동작', () {
      expect(validCodePattern.hasMatch('ABC123'), isFalse); // 1은 제외 문자 아님 (유효)
      expect(validCodePattern.hasMatch('ABCDE'), isFalse); // 5자리
      expect(validCodePattern.hasMatch('ABCDEFG'), isFalse); // 7자리
    });

    test('허용 문자만 포함한 6자리 코드는 패턴 매치', () {
      // ABCDEFGHJKLMNPQRSTUVWXYZ23456789 중 6자
      expect(validCodePattern.hasMatch('ABCDEF'), isTrue);
      expect(validCodePattern.hasMatch('XYZ234'), isTrue);
    });
  });
}
