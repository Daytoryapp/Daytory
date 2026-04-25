import 'package:date_app/src/features/calendar/calendar_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap() => const ProviderScope(
      child: MaterialApp(home: Scaffold(body: CalendarScreen())),
    );

void main() {
  group('CalendarScreen', () {
    testWidgets('renders title and filter icon', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('캘린더'), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('shows total count label for selected day', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.textContaining('총'), findsAtLeastNWidget(1));
    });

    testWidgets('opens filter bottom sheet on filter icon tap', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      expect(find.text('필터'), findsOneWidget);
      expect(find.text('초기화'), findsOneWidget);
      expect(find.text('적용'), findsOneWidget);
    });
  });
}
