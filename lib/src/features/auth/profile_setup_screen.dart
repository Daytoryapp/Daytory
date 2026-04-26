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
  bool _loading = false;

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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppConstants.textPrimary,
          ),
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
                Center(
                  child: Column(
                    children: [
                      _ProfileImage(imageUrl: profile?.kakaoProfileImageUrl),
                      const SizedBox(height: 12),
                      Text(
                        profile?.kakaoNickname ?? '사용자',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppConstants.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                const Text(
                  '우리 커플 별명',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textPrimary,
                  ),
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
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return '별명을 입력해주세요';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  '처음 만난 날 (기념일)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '선택사항이에요',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppConstants.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppConstants.surface,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 18, color: AppConstants.textSecondary),
                        const SizedBox(width: 10),
                        Text(
                          _anniversaryDate != null
                              ? DateFormat('yyyy년 M월 d일')
                                  .format(_anniversaryDate!)
                              : '날짜를 선택하세요',
                          style: TextStyle(
                            fontSize: 15,
                            color: _anniversaryDate != null
                                ? AppConstants.textPrimary
                                : AppConstants.textSecondary,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          '시작하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
                placeholder: (context, url) => const ColoredBox(
                  color: AppConstants.pinkLight,
                  child: Center(child: Text('💕', style: TextStyle(fontSize: 30))),
                ),
                errorWidget: (context, url, error) => const ColoredBox(
                  color: AppConstants.pinkLight,
                  child: Center(child: Text('💕', style: TextStyle(fontSize: 30))),
                ),
              )
            : const ColoredBox(
                color: AppConstants.pinkLight,
                child: Center(child: Text('💕', style: TextStyle(fontSize: 30))),
              ),
      ),
    );
  }
}
