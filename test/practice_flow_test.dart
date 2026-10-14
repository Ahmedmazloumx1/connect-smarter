import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grad_project/ai_interview_screen.dart';
import 'package:grad_project/ai_interview_setup_screen.dart';
import 'package:grad_project/services/interview_store.dart';
import 'package:grad_project/cv_analyze_screen.dart';
import 'package:grad_project/models/cv_analysis.dart';

void main() {
  testWidgets('practice flow shows feedback from actual answers', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: AiInterviewScreen(major: 'Flutter')),
    );
    await tester.enterText(
      find.byType(TextField),
      'A widget has immutable state and can rebuild.',
    );
    await tester.tap(find.text('Submit answer'));
    await tester.pump();
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('Skip question'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Practice feedback'), findsOneWidget);
    expect(InterviewStore.instance.result!.answeredCount, 1);
    expect(
      InterviewStore.instance.result!.questionResults.first.score,
      greaterThan(0),
    );
    expect(InterviewStore.instance.result!.questionResults.last.score, 0);
    expect(tester.takeException(), isNull);
  });
  testWidgets('leaving an interview disposes its timer', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AiInterviewScreen()));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 121));
    expect(tester.takeException(), isNull);
  });
  testWidgets('timeout records an unanswered question as zero', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AiInterviewScreen()));
    await tester.pump(const Duration(seconds: 120));
    expect(find.textContaining('Question 2 of 5'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('setup and CV result fit a small mobile viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: AiInterviewSetupScreen()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(
      MaterialApp(
        home: CvAnalyzeScreen(
          analysis: CvAnalysis(
            profile: 'Flutter Developer',
            skills: ['dart', 'flutter'],
            matchReason: 'Two skills found.',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Skills found in your document'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
