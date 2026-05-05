import 'package:flutter_test/flutter_test.dart';
<<<<<<< Updated upstream
import 'package:mobile_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SkillSharingApp());
    expect(find.textContaining('WELCOME TO THE'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('SIGN IN'), findsOneWidget);
=======
import 'package:mobile_app/loading_screen.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build loading screen without scheduling navigation timers
    await tester.pumpWidget(const MaterialApp(home: LoadingScreen(skipNavigation: true)));

    // Verify that the loading screen is shown initially
    expect(find.text('CONNECTING MINDS'), findsOneWidget);
>>>>>>> Stashed changes
  });
}
