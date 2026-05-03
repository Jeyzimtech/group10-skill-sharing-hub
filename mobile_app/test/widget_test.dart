import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SkillSharingApp());

    // Verify that the Loading Screen is shown initially
    // Note: We use find.textContaining or a specific string from loading_screen.dart
    expect(find.textContaining('WELCOME TO THE'), findsOneWidget);

    // Wait for the loading timer (4.5s - 5s) to complete and transition to AuthScreen
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Now we should be on the Login screen
    expect(find.text('SIGN IN'), findsOneWidget);
  });
}
