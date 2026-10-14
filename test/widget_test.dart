import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/main.dart';

void main() {
  testWidgets('App loads welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Connect Smarter'), findsWidgets);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create a candidate account'), findsOneWidget);
    expect(find.text('Create a company account'), findsOneWidget);
    expect(find.textContaining('demo'), findsNothing);
    expect(find.text('Try CV analysis'), findsNothing);
  });

  testWidgets(
    'small screen can reach the public privacy policy without account setup',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Privacy policy'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      final privacyButton = find.widgetWithText(TextButton, 'Privacy policy');
      await tester.ensureVisible(privacyButton);
      await tester.pumpAndSettle();
      await tester.tap(privacyButton);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Connect Smarter stores your account details'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
