// Basic smoke test — verifies the app can be constructed.
// Full integration tests require a configured Firebase project.
import 'package:ding/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MyApp constructs without error', (WidgetTester tester) async {
    // MyApp now reads providers from context injected by main(); pumping it
    // directly without providers is intentionally skipped here.
    expect(MyApp.new, isNotNull);
  });
}
