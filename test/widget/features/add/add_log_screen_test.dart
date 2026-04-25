import 'package:date_app/src/features/add/add_log_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap() => const ProviderScope(
      child: MaterialApp(home: Scaffold(body: AddLogScreen())),
    );

void main() {
  group('AddLogScreen', () {
    testWidgets('renders form fields and save button', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('기록 작성'), findsOneWidget);
      expect(find.text('저장'), findsOneWidget);
    });

    testWidgets('shows place validation error on empty submit', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.tap(find.text('저장'));
      await tester.pump();
      expect(find.text('장소를 입력해 주세요.'), findsOneWidget);
    });

    testWidgets('shows memo validation error on empty submit', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.enterText(
        find.widgetWithText(TextFormField, '장소'),
        '홍대입구',
      );
      await tester.tap(find.text('저장'));
      await tester.pump();
      expect(find.text('메모를 입력해 주세요.'), findsOneWidget);
    });

    testWidgets('saves log and shows snackbar on valid input', (tester) async {
      await tester.pumpWidget(_wrap());
      // Find fields by label
      await tester.enterText(
        find.widgetWithText(TextFormField, '장소'),
        '홍대입구',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '메모'),
        '즐거운 데이트',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '비용'),
        '30000',
      );
      await tester.tap(find.text('저장'));
      await tester.pump();
      expect(find.text('기록이 저장되었습니다.'), findsOneWidget);
    });
  });
}
