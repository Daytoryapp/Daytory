import 'dart:math';

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
    try {
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
    } catch (_) {
      _box.delete('data');
      state = const AuthState(status: AuthStatus.loggedOut);
    }
  }

  static String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> onKakaoLoginSuccess(kakao.User kakaoUser) async {
    try {
      final kProfile = kakaoUser.kakaoAccount?.profile;
      final kakaoId = kakaoUser.id.toString();

      await Supabase.instance.client.from('users').upsert({
        'kakao_id': kakaoId,
        'nickname': kProfile?.nickname ?? '사용자',
        'profile_image': kProfile?.profileImageUrl,
      }, onConflict: 'kakao_id');

      final existing = await Supabase.instance.client
          .from('users')
          .select()
          .eq('kakao_id', kakaoId)
          .maybeSingle();

      String? inviteCode = existing?['invite_code'] as String?;
      if (inviteCode == null || inviteCode.isEmpty) {
        inviteCode = _generateInviteCode();
        await Supabase.instance.client
            .from('users')
            .update({'invite_code': inviteCode})
            .eq('kakao_id', kakaoId);
      }

      final String? partnerKakaoId = existing?['partner_kakao_id'] as String?;
      String? partnerNickname;
      String? partnerProfileImageUrl;
      String? partnerGender;

      if (partnerKakaoId != null) {
        final partnerRow = await Supabase.instance.client
            .from('users')
            .select()
            .eq('kakao_id', partnerKakaoId)
            .maybeSingle();
        partnerNickname = partnerRow?['nickname'] as String?;
        partnerProfileImageUrl = partnerRow?['profile_image'] as String?;
        partnerGender = partnerRow?['gender'] as String?;
      }

      final userProfile = UserProfile(
        kakaoId: kakaoId,
        kakaoNickname: kProfile?.nickname ?? '사용자',
        kakaoProfileImageUrl: kProfile?.profileImageUrl,
        coupleNickname: existing?['couple_nickname'] as String?,
        anniversaryDate: existing?['anniversary'] != null
            ? DateTime.tryParse(existing!['anniversary'] as String)
            : null,
        gender: existing?['gender'] as String?,
        name: existing?['name'] as String?,
        birthdate: existing?['birthdate'] != null
            ? DateTime.tryParse(existing!['birthdate'] as String)
            : null,
        inviteCode: inviteCode,
        partnerKakaoId: partnerKakaoId,
        partnerNickname: partnerNickname,
        partnerProfileImageUrl: partnerProfileImageUrl,
        partnerGender: partnerGender,
      );

      await _box.put('data', userProfile.toMap());
      state = AuthState(
        status: userProfile.isComplete ? AuthStatus.ready : AuthStatus.needsProfile,
        profile: userProfile,
      );
    } catch (_) {
      state = const AuthState(status: AuthStatus.loggedOut);
    }
  }

  Future<void> completeProfile({
    required String coupleNickname,
    DateTime? anniversaryDate,
    String? gender,
    String? name,
    DateTime? birthdate,
  }) async {
    final updated = state.profile!.copyWith(
      coupleNickname: coupleNickname,
      anniversaryDate: anniversaryDate,
      gender: gender,
      name: name,
      birthdate: birthdate,
    );

    // gender, name, birthdate 컬럼이 아직 없을 수 있으므로 폴백 처리
    try {
      await Supabase.instance.client.from('users').update({
        'couple_nickname': coupleNickname,
        'anniversary': anniversaryDate?.toIso8601String(),
        if (gender != null) 'gender': gender,
        if (name != null) 'name': name,
        if (birthdate != null) 'birthdate': birthdate.toIso8601String(),
      }).eq('kakao_id', updated.kakaoId);
    } catch (_) {
      // 신규 컬럼 미존재 시 기본 필드만 재시도
      await Supabase.instance.client.from('users').update({
        'couple_nickname': coupleNickname,
        'anniversary': anniversaryDate?.toIso8601String(),
      }).eq('kakao_id', updated.kakaoId);
    }

    await _box.put('data', updated.toMap());
    state = AuthState(status: AuthStatus.ready, profile: updated);
  }

  /// 파트너 초대 코드로 연동. 성공 시 null 반환, 실패 시 에러 메시지 반환.
  Future<String?> linkPartner(String code) async {
    try {
      final normalizedCode = code.trim().toUpperCase();
      final myKakaoId = state.profile?.kakaoId;
      if (myKakaoId == null) return '로그인이 필요해요';

      final partnerRow = await Supabase.instance.client
          .from('users')
          .select()
          .eq('invite_code', normalizedCode)
          .maybeSingle();

      if (partnerRow == null) return '코드를 찾을 수 없어요';

      final partnerId = partnerRow['kakao_id'] as String? ?? '';
      if (partnerId.isEmpty) return '코드를 찾을 수 없어요';
      if (partnerId == myKakaoId) return '본인 코드는 사용할 수 없어요';

      final String? partnerExistingPartnerId = partnerRow['partner_kakao_id'] as String?;
      if (partnerExistingPartnerId != null && partnerExistingPartnerId != myKakaoId) {
        return '이미 다른 파트너와 연결된 코드예요';
      }

      await Supabase.instance.client
          .from('users')
          .update({'partner_kakao_id': partnerId})
          .eq('kakao_id', myKakaoId);

      await Supabase.instance.client
          .from('users')
          .update({'partner_kakao_id': myKakaoId})
          .eq('kakao_id', partnerId);

      final String? partnerNickname = partnerRow['nickname'] as String?;
      final String? partnerProfileImageUrl = partnerRow['profile_image'] as String?;
      final String? partnerGender = partnerRow['gender'] as String?;

      final updated = state.profile!.copyWith(
        partnerKakaoId: partnerId,
        partnerNickname: partnerNickname,
        partnerProfileImageUrl: partnerProfileImageUrl,
        partnerGender: partnerGender,
      );

      await _box.put('data', updated.toMap());
      state = AuthState(status: state.status, profile: updated);

      return null;
    } catch (e) {
      return '연동 중 오류가 발생했어요. 다시 시도해주세요.';
    }
  }

  Future<void> refreshProfileFromSupabase() async {
    final myKakaoId = state.profile?.kakaoId;
    if (myKakaoId == null) return;
    try {
      final existing = await Supabase.instance.client
          .from('users')
          .select()
          .eq('kakao_id', myKakaoId)
          .maybeSingle();
      if (existing == null) return;

      final String? partnerKakaoId = existing['partner_kakao_id'] as String?;
      if (partnerKakaoId == state.profile?.partnerKakaoId) return;

      String? partnerNickname;
      String? partnerProfileImageUrl;
      String? partnerGender;

      if (partnerKakaoId != null) {
        final partnerRow = await Supabase.instance.client
            .from('users')
            .select()
            .eq('kakao_id', partnerKakaoId)
            .maybeSingle();
        partnerNickname = partnerRow?['nickname'] as String?;
        partnerProfileImageUrl = partnerRow?['profile_image'] as String?;
        partnerGender = partnerRow?['gender'] as String?;
      }

      final updated = state.profile!.copyWith(
        partnerKakaoId: partnerKakaoId,
        partnerNickname: partnerNickname,
        partnerProfileImageUrl: partnerProfileImageUrl,
        partnerGender: partnerGender,
      );
      await _box.put('data', updated.toMap());
      state = AuthState(status: state.status, profile: updated);
    } catch (_) {}
  }

  Future<void> ensureInviteCode() async {
    try {
      final myKakaoId = state.profile?.kakaoId;
      if (myKakaoId == null || state.profile?.inviteCode != null) return;

      final row = await Supabase.instance.client
          .from('users')
          .select('invite_code')
          .eq('kakao_id', myKakaoId)
          .maybeSingle();

      String? inviteCode = row?['invite_code'] as String?;
      if (inviteCode == null || inviteCode.isEmpty) {
        inviteCode = _generateInviteCode();
        await Supabase.instance.client
            .from('users')
            .update({'invite_code': inviteCode})
            .eq('kakao_id', myKakaoId);
      }

      final updated = state.profile!.copyWith(inviteCode: inviteCode);
      await _box.put('data', updated.toMap());
      state = AuthState(status: state.status, profile: updated);
    } catch (_) {}
  }

  /// 파트너 연결 해제.
  Future<void> unlinkPartner() async {
    try {
      final myKakaoId = state.profile?.kakaoId;
      final partnerKakaoId = state.profile?.partnerKakaoId;
      if (myKakaoId == null) return;

      await Supabase.instance.client
          .from('users')
          .update({'partner_kakao_id': null})
          .eq('kakao_id', myKakaoId);

      if (partnerKakaoId != null) {
        await Supabase.instance.client
            .from('users')
            .update({'partner_kakao_id': null})
            .eq('kakao_id', partnerKakaoId)
            .eq('partner_kakao_id', myKakaoId);
      }

      final updated = state.profile!.copyWith(clearPartner: true);
      await _box.put('data', updated.toMap());
      state = AuthState(status: state.status, profile: updated);
    } catch (_) {}
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
