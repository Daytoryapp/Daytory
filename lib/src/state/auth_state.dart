import 'package:date_app/src/models/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

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

  Future<void> onKakaoLoginSuccess(User kakaoUser) async {
    final profile = kakaoUser.kakaoAccount?.profile;
    final partial = UserProfile(
      kakaoId: '${kakaoUser.id}',
      kakaoNickname: profile?.nickname ?? '사용자',
      kakaoProfileImageUrl: profile?.profileImageUrl,
    );
    await _box.put('data', partial.toMap());
    state = AuthState(status: AuthStatus.needsProfile, profile: partial);
  }

  Future<void> completeProfile({
    required String coupleNickname,
    DateTime? anniversaryDate,
  }) async {
    final updated = state.profile!.copyWith(
      coupleNickname: coupleNickname,
      anniversaryDate: anniversaryDate,
    );
    await _box.put('data', updated.toMap());
    state = AuthState(status: AuthStatus.ready, profile: updated);
  }

  Future<void> logout() async {
    try {
      await UserApi.instance.logout();
    } catch (_) {}
    await _box.delete('data');
    state = const AuthState(status: AuthStatus.loggedOut);
  }
}

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
