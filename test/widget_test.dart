import 'package:flutter_test/flutter_test.dart';
import 'package:hello_simple/main.dart';

void main() {
  testWidgets('يعرض نص الترحيب', (WidgetTester tester) async {
    await tester.pumpWidget(const HelloApp());
    expect(find.textContaining('Flutter'), findsOneWidget);
  });
}
