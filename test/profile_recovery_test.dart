import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grad_project/complete_profile_screen.dart';
import 'package:grad_project/cv_upload_screen.dart';

void main() {
  testWidgets('failed profile write preserves signup data and can be retried', (
    tester,
  ) async {
    var attempts = 0;
    final saved = <Map<String, dynamic>>[];
    await tester.pumpWidget(
      MaterialApp(
        home: CompleteProfileScreen(
          initialProfile: const {
            'userType': 'job_seeker',
            'firstName': 'Ada',
            'lastName': 'Lovelace',
            'major': 'Developer',
          },
          saveProfile: (profile) async {
            saved.add(profile);
            if (++attempts == 1) throw StateError('Offline');
            return 'job_seeker';
          },
        ),
      ),
    );
    await tester.tap(find.text('Save profile and continue'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Your account already exists'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Ada'), findsOneWidget);
    await tester.tap(find.text('Save profile and continue'));
    await tester.pumpAndSettle();
    expect(find.byType(CvUploadScreen), findsOneWidget);
    expect(saved.last['lastName'], 'Lovelace');
    expect(saved.last['major'], 'Developer');
    expect(attempts, 2);
  });

  testWidgets('missing name is validated before profile creation', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: CompleteProfileScreen(
          saveProfile: (_) async {
            calls++;
            return 'job_seeker';
          },
        ),
      ),
    );
    await tester.tap(find.text('Save profile and continue'));
    await tester.pump();
    expect(calls, 0);
    expect(find.text('Enter your name to continue.'), findsOneWidget);
  });

  testWidgets(
    'pending profile save prevents duplicates and tolerates leaving',
    (tester) async {
      final pending = Completer<String>();
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: CompleteProfileScreen(
            initialProfile: const {
              'userType': 'company',
              'companyName': 'Demo',
            },
            saveProfile: (_) {
              calls++;
              return pending.future;
            },
          ),
        ),
      );
      await tester.tap(find.text('Save profile and continue'));
      await tester.pump();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      pending.complete('company');
      await tester.pump();
      expect(calls, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
