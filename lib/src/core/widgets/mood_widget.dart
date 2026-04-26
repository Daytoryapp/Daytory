import 'package:date_app/src/core/widgets/rabbit_mood_widget.dart';
import 'package:date_app/src/state/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 로그인한 사용자의 gender에 따라 자동으로 토끼(female) 또는 여우(male) 감정 위젯을 선택
class MoodWidget extends ConsumerWidget {
  const MoodWidget({super.key, required this.moodScore, this.size = 36.0});
  final int moodScore;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMale = ref.watch(authStateProvider).profile?.gender == 'male';
    return RabbitMoodWidget(moodScore: moodScore, size: size, isMale: isMale);
  }
}
