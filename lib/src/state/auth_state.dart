import 'package:date_app/src/models/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus { loading, loggedOut, needsProfile, ready }

class AuthState {
  final AuthStatus status;
  final UserProfile? profile;

  const AuthState({required this.status, this.profile});
}

class AuthNotifier extends StateNotifier<AuthState> {
  static const _boxName = 'user_profile';

  Box<Map> get _box => Hive.box<Map>(_boxName);

  AuthNotifier() : super(const AuthState(status: AuthStatus.loading)) {
    _init();
  }

  void _init() {
    final raw = _box.get('data');
    if (raw != null) {
      final profile = UserProfile.fromMap(Map<String, dynamic>.from(raw));
      state = AuthState(
        status: profile.isComplete ? AuthStatus.ready : AuthStatus.needsProfile,
        profile: profile,
      );
    } else {
      state = const AuthState(status: AuthStatus.loggedOut);
    }
  }

  Future<void> onKakaoLoginSuccess(kakao.User kakaoUser) async {
    final kProfile = kakaoUser.kakaoAccount?.profile;
    final kakaoId = kakaoUser.id.toString();

    // Supabase upsert (기본 정보만)
    await Supabase.instance.client.from('users').upsert({
      'kakao_id': kakaoId,
      'nickname': kProfile?.nickname ?? '사용자',
      'profile_image': kProfile?.profileImageUrl,
    }, onConflict: 'kakao_id');

    // Supabase에서 기존 프로필 조회 (couple_nickname, anniversary 포함)
    final existing = await Supabase.instance.client
        .from('users')
        .select()
        .eq('kakao_id', kakaoId)
        .maybeSingle();

    final userProfile = UserProfile(
      kakaoId: kakaoId,
      kakaoNickname: kProfile?.nickname ?? '사용자',
      kakaoProfileImageUrl: kProfile?.profileImageUrl,
      coupleNickname: existing?['couple_nickname'] as String?,
      anniversaryDate: existing?['anniversary'] != null
          ? DateTime.tryParse(existing!['anniversary'] as String)
          : null,
      gender: existing?['gender'] as String?,
    );

    await _box.put('data', userProfile.toMap());
    state = AuthState(
      status: userProfile.isComplete ? AuthStatus.ready : AuthStatus.needsProfile,
      profile: userProfile,
    );
  }

  Future<void> completeProfile({
    required String coupleNickname,
    DateTime? anniversaryDate,
    String? gender,
  }) async {
    final updated = state.profile!.copyWith(
      coupleNickname: coupleNickname,
      anniversaryDate: anniversaryDate,
      gender: gender,
    );

    // gender 컬럼이 아직 없을 수 있으므로 폴백 처리
    try {
      await Supabase.instance.client.from('users').update({
        'couple_nickname': coupleNickname,
        'anniversary': anniversaryDate?.toIso8601String(),
        if (gender != null) 'gender': gender,
      }).eq('kakao_id', updated.kakaoId);
    } catch (_) {
      // gender 컬럼 미존재 시 해당 필드 제외하고 재시도
      await Supabase.instance.client.from('users').update({
        'couple_nickname': coupleNickname,
        'anniversary': anniversaryDate?.toIso8601String(),
      }).eq('kakao_id', updated.kakaoId);
    }

    await _box.put('data', updated.toMap());
    state = AuthState(status: AuthStatus.ready, profile: updated);
  }

  Future<void> logout() async {
    try {
      await kakao.UserApi.instance.logout();
    } catch (_) {}
    await _box.delete('data');
    state = const AuthState(status: AuthStatus.loggedOut);
  }
}

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
