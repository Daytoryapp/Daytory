import 'package:date_app/src/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DateApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DateApp()));
  });
}
