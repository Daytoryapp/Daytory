import 'package:date_app/src/core/constants/app_constants.dart';
import 'package:date_app/src/state/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CoupleLinkScreen extends ConsumerStatefulWidget {
  const CoupleLinkScreen({super.key});

  @override
  ConsumerState<CoupleLinkScreen> createState() => _CoupleLinkScreenState();
}

class _CoupleLinkScreenState extends ConsumerState<CoupleLinkScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _loading = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(authStateProvider).profile?.inviteCode == null) {
        ref.read(authStateProvider.notifier).ensureInviteCode();
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 6) {
      setState(() => _errorMsg = '6자리 코드를 입력해주세요');
      return;
    }
    setState(() {
      _loading = true;
      _errorMsg = null;
    });
    try {
      final error = await ref.read(authStateProvider.notifier).linkPartner(code);
      if (!mounted) return;
      if (error != null) {
        setState(() {
          _loading = false;
          _errorMsg = error;
        });
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('파트너와 연동됐어요 💕')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMsg = '오류가 발생했어요. 다시 시도해주세요.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(authStateProvider).profile;
    final inviteCode = profile?.inviteCode ?? '---';

    return Scaffold(
      backgroundColor: AppConstants.surfaceWarm,
      appBar: AppBar(
        backgroundColor: AppConstants.surfaceWarm,
        elevation: 0,
        title: const Text(
          '커플 연동',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppConstants.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppConstants.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 내 초대 코드 섹션
            const Text(
              '내 초대 코드',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppConstants.textSecondary,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                border: Border.all(color: AppConstants.pinkMid),
              ),
              child: Column(
                children: [
                  Text(
                    inviteCode,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 8,
                      color: AppConstants.pink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.icon(
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: const Text('복사하기'),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: inviteCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('코드가 복사됐어요')),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppConstants.pink,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '파트너에게 이 코드를 공유해서 연동할 수 있어요',
              style: TextStyle(
                fontSize: 13,
                color: AppConstants.textSecondary,
              ),
            ),

            const SizedBox(height: 32),

            // 구분선
            const Row(
              children: [
                Expanded(child: Divider(color: AppConstants.border)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '또는',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppConstants.textSecondary,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: AppConstants.border)),
              ],
            ),

            const SizedBox(height: 32),

            // 파트너 코드 입력 섹션
            const Text(
              '파트너 코드 입력',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppConstants.textSecondary,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
                color: AppConstants.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '6자리 코드를 입력하세요',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                  color: AppConstants.textHint,
                ),
                counterText: '',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  borderSide: const BorderSide(color: AppConstants.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  borderSide: const BorderSide(color: AppConstants.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  borderSide: const BorderSide(color: AppConstants.pink, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),

            if (_errorMsg != null) ...[
              Text(
                _errorMsg!,
                style: const TextStyle(fontSize: 13, color: Colors.red),
              ),
              const SizedBox(height: 8),
            ],

            FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppConstants.pink,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      '연동하기',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
