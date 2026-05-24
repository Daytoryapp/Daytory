import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_app/src/core/constants/app_constants.dart';
import 'package:date_app/src/core/widgets/mood_widget.dart';
import 'package:date_app/src/features/auth/profile_setup_screen.dart';
import 'package:date_app/src/features/couple/couple_link_screen.dart';
import 'package:date_app/src/models/user_profile.dart';
import 'package:date_app/src/state/auth_state.dart';
import 'package:date_app/src/state/date_log_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MypageScreen extends ConsumerWidget {
  const MypageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs    = ref.watch(dateLogControllerProvider);
    final auth    = ref.watch(authStateProvider);
    final profile = auth.profile;

    final totalCount = logs.length;
    final totalCost  = logs.fold<double>(0, (s, l) => s + l.totalCost);
    final avgMood    = logs.isEmpty ? 0.0 : logs.fold<int>(0, (s, l) => s + l.moodScore) / logs.length;
    final topPlace   = _topPlace(logs.map((l) => l.placeName).toList());

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── 헤더 ──────────────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(
              '마이페이지',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppConstants.textPrimary, letterSpacing: -0.5),
            ),
          ),
          const SizedBox(height: 20),

          // ── 프로필 히어로 카드 ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _ProfileHeroCard(
              profile: profile,
              onEdit: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ProfileSetupScreen()),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── 파트너 섹션 ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(title: '파트너'),
                const SizedBox(height: 12),
                _PartnerCard(
                  profile: profile,
                  onUnlink: () => _confirmUnlink(context, ref),
                  onLink: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const CoupleLinkScreen()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── 기념일 마일스톤 ────────────────────────────────────────────────
          if (profile?.anniversaryDate != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(title: '기념일'),
                  const SizedBox(height: 12),
                  _MilestoneSection(anniversary: profile!.anniversaryDate!),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ── 우리의 기록 ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(title: '우리의 기록'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        iconColor: const Color(0xFF8AAEE8),
                        iconBg: const Color(0xFFDCE8FB),
                        icon: Icons.calendar_month_rounded,
                        label: '총 데이트',
                        value: '$totalCount회',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        iconColor: AppConstants.peach,
                        iconBg: const Color(0xFFFFF0D6),
                        icon: Icons.payments_rounded,
                        label: '총 비용',
                        value: '${NumberFormat('#,###').format(totalCost.toInt())}원',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _RabbitStatCard(
                        moodScore: avgMood.round().clamp(1, 5),
                        label: '평균 감정',
                        value: avgMood == 0 ? '-' : '${avgMood.toStringAsFixed(1)}점',
                        isEmpty: avgMood == 0,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        iconColor: AppConstants.coral,
                        iconBg: const Color(0xFFFFEDE0),
                        icon: Icons.place_rounded,
                        label: '자주 간 곳',
                        value: topPlace ?? '-',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── 앱 정보 ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(title: '앱 정보'),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppConstants.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  ),
                  child: const Column(
                    children: [
                      _SettingsTile(label: '버전', value: '0.1.0'),
                      Divider(height: 1, color: AppConstants.divider),
                      _SettingsTile(label: '개인정보처리방침', showArrow: true),
                      Divider(height: 1, color: AppConstants.divider),
                      _SettingsTile(label: '이용약관', showArrow: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── 로그아웃 ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton(
              onPressed: () => _confirmLogout(context, ref),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                side: const BorderSide(color: AppConstants.border),
                foregroundColor: AppConstants.textSecondary,
              ),
              child: const Text('로그아웃', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String? _topPlace(List<String> places) {
    if (places.isEmpty) return null;
    final freq = <String, int>{};
    for (final p in places) { freq[p] = (freq[p] ?? 0) + 1; }
    return freq.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  Future<void> _confirmUnlink(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('연결 해제'),
        content: const Text('파트너와의 연결을 해제할까요?\n기록은 삭제되지 않아요.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소', style: TextStyle(color: AppConstants.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('해제', style: TextStyle(color: AppConstants.pink, fontWeight: FontWeight.w600))),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authStateProvider.notifier).unlinkPartner();
    }
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃 하시겠어요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소', style: TextStyle(color: AppConstants.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(ctx, true),  child: const Text('로그아웃', style: TextStyle(color: AppConstants.pink))),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authStateProvider.notifier).logout();
    }
  }
}

// ── 프로필 히어로 카드 ──────────────────────────────────────────────────────
class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({required this.profile, required this.onEdit});
  final UserProfile? profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final ddays = profile?.anniversaryDate != null
        ? DateTime.now().difference(profile!.anniversaryDate!).inDays
        : null;
    final avatarEmoji = profile?.avatarEmoji ?? '🐰';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFEAF2), Color(0xFFFFF8F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [BoxShadow(color: AppConstants.pink.withAlpha(50), blurRadius: 20, offset: const Offset(0, 6))],
                  ),
                  child: ClipOval(
                    child: profile?.kakaoProfileImageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: profile!.kakaoProfileImageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _DefaultAvatar(emoji: avatarEmoji),
                            errorWidget: (_, __, ___) => _DefaultAvatar(emoji: avatarEmoji),
                          )
                        : _DefaultAvatar(emoji: avatarEmoji),
                  ),
                ),
                const SizedBox(height: 14),

                // 이름
                Text(
                  profile?.kakaoNickname ?? '사용자',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppConstants.textPrimary, letterSpacing: -0.3),
                ),

                // 커플 닉네임 뱃지
                if (profile?.coupleNickname != null && profile!.coupleNickname!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppConstants.pinkMid),
                    ),
                    child: Text(
                      '💕  ${profile!.coupleNickname}',
                      style: const TextStyle(fontSize: 13, color: AppConstants.pink, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],

                // 이름 + 나이
                if (profile?.name != null && profile!.name!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: profile!.name!,
                          style: const TextStyle(fontSize: 13, color: AppConstants.textSecondary, fontWeight: FontWeight.w500),
                        ),
                        if (profile!.birthdate != null)
                          TextSpan(
                            text: '  (${DateTime.now().year - profile!.birthdate!.year}세)',
                            style: const TextStyle(fontSize: 13, color: AppConstants.textSecondary),
                          ),
                      ],
                    ),
                  ),
                ] else if (profile?.birthdate != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '(${DateTime.now().year - profile!.birthdate!.year}세)',
                    style: const TextStyle(fontSize: 13, color: AppConstants.textSecondary),
                  ),
                ] else
                  const SizedBox.shrink(),

                // D+day 배지
                if (ddays != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _DdayBadge(days: ddays),
                      const SizedBox(width: 8),
                      _AnniversaryBadge(date: profile!.anniversaryDate!),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // 수정 버튼
          Positioned(
            top: 14,
            right: 14,
            child: GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  border: Border.all(color: AppConstants.pinkMid),
                ),
                child: const Text('수정', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConstants.pink)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar({this.emoji = '🐰'});
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppConstants.pinkLight,
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 40))),
    );
  }
}

class _DdayBadge extends StatelessWidget {
  const _DdayBadge({required this.days});
  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppConstants.pink,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('❤️', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 5),
          Text('D+$days', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }
}

class _AnniversaryBadge extends StatelessWidget {
  const _AnniversaryBadge({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppConstants.pinkMid),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cake_rounded, size: 12, color: AppConstants.textSecondary),
          const SizedBox(width: 4),
          Text('${date.month}/${date.day}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConstants.textSecondary)),
        ],
      ),
    );
  }
}

// ── 파트너 카드 ─────────────────────────────────────────────────────────────
class _PartnerCard extends StatelessWidget {
  const _PartnerCard({required this.profile, required this.onUnlink, required this.onLink});
  final UserProfile? profile;
  final VoidCallback onUnlink;
  final VoidCallback onLink;

  Widget _avatar({
    required String? imageUrl,
    required String emoji,
    required Color borderColor,
    required Color bgColor,
  }) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: ClipOval(
        child: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
              )
            : Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
      ),
    );
  }

  Widget _dottedConnector() {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              8,
              (i) => Container(
                width: 4,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: AppConstants.pinkMid,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text('💕', style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLinked = profile?.isLinked ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppConstants.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _avatar(
                imageUrl: profile?.kakaoProfileImageUrl,
                emoji: profile?.avatarEmoji ?? '🐰',
                borderColor: AppConstants.pinkMid,
                bgColor: AppConstants.pinkLight,
              ),
              _dottedConnector(),
              if (isLinked)
                _avatar(
                  imageUrl: profile?.partnerProfileImageUrl,
                  emoji: profile?.partnerAvatarEmoji ?? '🐰',
                  borderColor: AppConstants.pinkMid,
                  bgColor: AppConstants.pinkLight,
                )
              else
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppConstants.surface,
                    border: Border.all(color: AppConstants.border, width: 2),
                  ),
                  child: const Icon(Icons.person_add_rounded, size: 24, color: AppConstants.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            isLinked
                ? (profile?.partnerNickname ?? '파트너')
                : '아직 연결된 파트너가 없어요',
            style: const TextStyle(fontSize: 14, color: AppConstants.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 14),
          if (isLinked)
            OutlinedButton(
              onPressed: onUnlink,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                side: const BorderSide(color: AppConstants.pink),
                foregroundColor: AppConstants.pink,
              ),
              child: const Text('연결 해제'),
            )
          else
            FilledButton.icon(
              onPressed: onLink,
              icon: const Icon(Icons.link_rounded, size: 16),
              label: const Text('초대 코드로 연동하기'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                backgroundColor: AppConstants.pink,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

// ── 통계 카드 ───────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  const _StatCard({required this.iconColor, required this.iconBg, required this.icon, required this.label, required this.value});
  final Color iconColor;
  final Color iconBg;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(AppConstants.radiusS)),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 11, color: AppConstants.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConstants.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _RabbitStatCard extends StatelessWidget {
  const _RabbitStatCard({required this.moodScore, required this.label, required this.value, required this.isEmpty});
  final int moodScore;
  final String label;
  final String value;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    final bgColor = isEmpty ? AppConstants.surface : AppConstants.moodColors[moodScore];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isEmpty
              ? Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: Colors.white.withAlpha(160), borderRadius: BorderRadius.circular(AppConstants.radiusS)),
                  child: const Center(child: Text('💭', style: TextStyle(fontSize: 18))),
                )
              : MoodWidget(moodScore: moodScore, size: 36),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 11, color: AppConstants.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConstants.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ── 공통 위젯 ───────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConstants.textPrimary));
  }
}

// ── 기념일 마일스톤 ──────────────────────────────────────────────────────────

const _kMilestones = [100, 200, 300, 365, 500, 700, 730, 1000, 1095, 1460, 1825];

class _MilestoneSection extends StatelessWidget {
  const _MilestoneSection({required this.anniversary});
  final DateTime anniversary;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final anniversaryDay = DateTime(anniversary.year, anniversary.month, anniversary.day);
    final ddays = today.difference(anniversaryDay).inDays;

    // 다음 마일스톤
    final next = _kMilestones.where((m) => m > ddays).toList();
    final nextMilestone = next.isNotEmpty ? next.first : null;
    final daysLeft = nextMilestone != null ? nextMilestone - ddays : null;

    // 지난 마일스톤
    final past = _kMilestones.where((m) => m <= ddays).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (nextMilestone != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFEAF2), Color(0xFFFFF8F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
            ),
            child: Row(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'D+$nextMilestone까지',
                      style: const TextStyle(fontSize: 13, color: AppConstants.textSecondary, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '$daysLeft일 남았어요',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppConstants.pink, letterSpacing: -0.3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        if (past.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: past.reversed.take(6).map((m) {
              final label = m % 365 == 0 ? '${m ~/ 365}주년' : 'D+$m';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppConstants.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(color: AppConstants.pinkMid),
                ),
                child: Text(
                  '✓ $label',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConstants.pink),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.label, this.value = '', this.showArrow = false});
  final String label;
  final String value;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppConstants.textPrimary)),
          const Spacer(),
          if (value.isNotEmpty) Text(value, style: const TextStyle(fontSize: 14, color: AppConstants.textSecondary)),
          if (showArrow) const Icon(Icons.chevron_right, size: 18, color: AppConstants.textSecondary),
        ],
      ),
    );
  }
}
