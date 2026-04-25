import 'package:date_app/src/features/stats/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap() => const ProviderScope(
      child: MaterialApp(home: Scaffold(body: StatsScreen())),
    );

void main() {
  group('StatsScreen', () {
    testWidgets('renders stat cards', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('통계'), findsOneWidget);
      expect(find.text('총 데이트 횟수'), findsOneWidget);
      expect(find.text('총 비용'), findsOneWidget);
      expect(find.text('평균 감정 점수'), findsOneWidget);
    });

    testWidgets('shows monthly breakdown section', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('월별 횟수'), findsOneWidget);
    });
  });
}
