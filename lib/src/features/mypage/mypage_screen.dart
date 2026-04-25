import 'package:date_app/src/core/constants/app_constants.dart';
import 'package:date_app/src/state/date_log_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MypageScreen extends ConsumerWidget {
  const MypageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(dateLogControllerProvider);
    final totalCount = logs.length;
    final totalCost = logs.fold<double>(0, (s, l) => s + l.totalCost);
    final avgMood = logs.isEmpty ? 0.0 : logs.fold<int>(0, (s, l) => s + l.moodScore) / logs.length;
    final topPlace = _topPlace(logs.map((l) => l.placeName).toList());

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          const Text('마이페이지', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppConstants.textPrimary, letterSpacing: -0.5)),
          const SizedBox(height: 24),

          // 프로필 카드
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppConstants.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusXL),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppConstants.pinkLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppConstants.pink, width: 2),
                  ),
                  child: const Center(child: Text('💕', style: TextStyle(fontSize: 28))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('로그인이 필요해요', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConstants.textPrimary)),
                      const SizedBox(height: 4),
                      const Text('카카오 로그인으로 파트너와 공유하세요', style: TextStyle(fontSize: 12, color: AppConstants.textSecondary)),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => _showKakaoComingSoon(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE500),
                            borderRadius: BorderRadius.circular(AppConstants.radiusS),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🟡', style: TextStyle(fontSize: 14)),
                              SizedBox(width: 6),
                              Text('카카오 로그인', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF3C1E1E))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 파트너 섹션
          _SectionTitle(title: '파트너'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              border: Border.all(color: AppConstants.border),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.favorite_border_rounded, size: 18, color: AppConstants.textSecondary),
                    SizedBox(width: 8),
                    Text('아직 연결된 파트너가 없어요', style: TextStyle(fontSize: 14, color: AppConstants.textSecondary)),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _showKakaoComingSoon(context),
                  icon: const Icon(Icons.link_rounded, size: 16),
                  label: const Text('초대 코드 생성하기'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 42),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                    side: const BorderSide(color: AppConstants.border),
                    foregroundColor: AppConstants.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 통계 섹션
          _SectionTitle(title: '우리의 기록'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _StatBox(emoji: '📅', label: '총 데이트', value: '$totalCount회')),
              const SizedBox(width: 10),
              Expanded(child: _StatBox(emoji: '💸', label: '총 비용', value: '${NumberFormat('#,###').format(totalCost.toInt())}원')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _StatBox(emoji: avgMood == 0 ? '💭' : AppConstants.moodEmojis[avgMood.round().clamp(1, 5)], label: '평균 감정', value: avgMood == 0 ? '-' : '${avgMood.toStringAsFixed(1)}점')),
              const SizedBox(width: 10),
              Expanded(child: _StatBox(emoji: '📍', label: '자주 간 곳', value: topPlace ?? '-')),
            ],
          ),

          const SizedBox(height: 32),

          // 앱 정보
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
            ),
            child: Column(
              children: [
                _InfoTile(label: '버전', value: '0.1.0'),
                const Divider(height: 20),
                _InfoTile(label: '개인정보처리방침', value: '', trailing: const Icon(Icons.chevron_right, size: 16, color: AppConstants.textSecondary)),
                const Divider(height: 20),
                _InfoTile(label: '이용약관', value: '', trailing: const Icon(Icons.chevron_right, size: 16, color: AppConstants.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _topPlace(List<String> places) {
    if (places.isEmpty) return null;
    final freq = <String, int>{};
    for (final p in places) {
      freq[p] = (freq[p] ?? 0) + 1;
    }
    return freq.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  void _showKakaoComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('카카오 로그인은 준비 중이에요 🔜')),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConstants.textPrimary));
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.emoji, required this.label, required this.value});
  final String emoji;
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
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, color: AppConstants.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConstants.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value, this.trailing});
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppConstants.textPrimary)),
        const Spacer(),
        if (value.isNotEmpty) Text(value, style: const TextStyle(fontSize: 14, color: AppConstants.textSecondary)),
        if (trailing != null) trailing!,
      ],
    );
  }
}
