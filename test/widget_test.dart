// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:premoda/main.dart';

void main() {
  testWidgets('Premoda app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PremodaApp());

    // Verify that the PREMODA title is displayed on welcome screen.
    expect(find.text('PREMODA'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });

  testWidgets('Navigate to Sign Up screen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PremodaApp());

    // Tap the Get Started button and navigate to Sign Up screen.
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify that the SIGN UP title is displayed.
    expect(find.text('SIGN UP'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Email'), findsAtLeastNWidgets(1));
  });

  testWidgets('Navigate to Log In screen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PremodaApp());

    // Tap the Log In button and navigate to Log In screen.
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    // Verify that the LOG IN title is displayed.
    expect(find.text('LOG IN'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Email'), findsAtLeastNWidgets(1));
  });
}
