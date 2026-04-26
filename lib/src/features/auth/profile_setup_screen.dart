import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_app/src/core/constants/app_constants.dart';
import 'package:date_app/src/state/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  DateTime? _anniversaryDate;
  String? _gender;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(authStateProvider).profile;
    if (profile?.coupleNickname != null) {
      _nicknameController.text = profile!.coupleNickname!;
    }
    _anniversaryDate = profile?.anniversaryDate;
    _gender = profile?.gender;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _anniversaryDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppConstants.pink),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _anniversaryDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authStateProvider.notifier).completeProfile(
            coupleNickname: _nicknameController.text.trim(),
            anniversaryDate: _anniversaryDate,
            gender: _gender,
          );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(authStateProvider).profile;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          '프로필 설정',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConstants.textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 프로필 이미지
                Center(
                  child: Column(
                    children: [
                      _ProfileImage(imageUrl: profile?.kakaoProfileImageUrl),
                      const SizedBox(height: 12),
                      Text(
                        profile?.kakaoNickname ?? '사용자',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConstants.textPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── 성별 선택 ─────────────────────────────────────────────────
                const Text(
                  '성별',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConstants.textPrimary),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _GenderCard(
                        emoji: '🐰',
                        label: '여자',
                        selected: _gender == 'female',
                        onTap: () => setState(() => _gender = 'female'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GenderCard(
                        emoji: '🦊',
                        label: '남자',
                        selected: _gender == 'male',
                        onTap: () => setState(() => _gender = 'male'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── 커플 별명 ─────────────────────────────────────────────────
                const Text(
                  '우리 커플 별명',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConstants.textPrimary),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    hintText: '예: 뚜르미, 콩닥콩닥...',
                    hintStyle: const TextStyle(color: AppConstants.textSecondary),
                    filled: true,
                    fillColor: AppConstants.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: const BorderSide(color: AppConstants.pink),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return '별명을 입력해주세요';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // ── 기념일 ────────────────────────────────────────────────────
                const Text(
                  '처음 만난 날 (기념일)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConstants.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  '선택사항이에요',
                  style: TextStyle(fontSize: 12, color: AppConstants.textSecondary),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppConstants.surface,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 18, color: AppConstants.textSecondary),
                        const SizedBox(width: 10),
                        Text(
                          _anniversaryDate != null
                              ? DateFormat('yyyy년 M월 d일').format(_anniversaryDate!)
                              : '날짜를 선택하세요',
                          style: TextStyle(
                            fontSize: 15,
                            color: _anniversaryDate != null ? AppConstants.textPrimary : AppConstants.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                FilledButton(
                  onPressed: _loading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppConstants.pink,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                  ),
                  child: _loading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('시작하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
                if (Navigator.of(context).canPop()) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                      side: const BorderSide(color: AppConstants.border),
                      foregroundColor: AppConstants.textSecondary,
                    ),
                    child: const Text('뒤로 가기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── 성별 선택 카드 ───────────────────────────────────────────────────────────
class _GenderCard extends StatelessWidget {
  const _GenderCard({required this.emoji, required this.label, required this.selected, required this.onTap});
  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: selected ? AppConstants.pinkLight : AppConstants.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(
            color: selected ? AppConstants.pink : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: selected ? 42 : 36)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppConstants.pink : AppConstants.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 프로필 이미지 ────────────────────────────────────────────────────────────
class _ProfileImage extends StatelessWidget {
  const _ProfileImage({this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppConstants.pink, width: 2),
      ),
      child: ClipOval(
        child: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => const ColoredBox(color: AppConstants.pinkLight, child: Center(child: Text('💕', style: TextStyle(fontSize: 30)))),
                errorWidget: (_, __, ___) => const ColoredBox(color: AppConstants.pinkLight, child: Center(child: Text('💕', style: TextStyle(fontSize: 30)))),
              )
            : const ColoredBox(
                color: AppConstants.pinkLight,
                child: Center(child: Text('💕', style: TextStyle(fontSize: 30))),
              ),
      ),
    );
  }
}
