import 'package:flutter_test/flutter_test.dart';
import 'package:hello_simple/gallery_store.dart';
import 'package:hello_simple/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('يعرض معرض الصور وعلامة Flutter', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = await GalleryStore.create();
    await tester.pumpWidget(HelloApp(store: store));
    await tester.pumpAndSettle();

    expect(find.textContaining('معرض'), findsOneWidget);
    expect(find.textContaining('Flutter'), findsOneWidget);
  });
}
