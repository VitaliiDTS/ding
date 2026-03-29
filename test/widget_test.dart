import 'package:ding/data/repositories/local_user_repository.dart';
import 'package:ding/data/services/shared_prefs_service.dart';
import 'package:ding/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MyApp(
        repository: LocalUserRepository(
          storage: SharedPrefsService(),
        ),
      ),
    );
    expect(find.text('Login'), findsOneWidget);
  });
}
