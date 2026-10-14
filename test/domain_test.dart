import 'package:flutter_test/flutter_test.dart';
import 'package:grad_project/services/interview_scoring.dart';
import 'package:grad_project/services/interview_questions.dart';
import 'package:grad_project/services/job_matching.dart';
import 'package:grad_project/services/auth_service.dart';
import 'package:grad_project/services/cv_analysis_store.dart';
import 'package:grad_project/models/cv_analysis.dart';

void main() {
  test('blank answers receive no credit', () {
    expect(evaluateAnswer('', ['state', 'widget']).score, 0);
  });
  test('concept coverage is deterministic and ignores case', () {
    final result = evaluateAnswer('A WIDGET has immutable state.', [
      'widget',
      'state',
      'rebuild',
    ]);
    expect(result.score, closeTo(2 / 3, .0001));
    expect(result.missing, ['rebuild']);
    expect(
      evaluateAnswer('A WIDGET has immutable state.', [
        'widget',
        'state',
        'rebuild',
      ]).score,
      result.score,
    );
  });
  test('substrings and repeated hints cannot inflate scores', () {
    expect(evaluateAnswer('javascript', ['java']).score, 0);
    expect(
      evaluateAnswer('state state state', ['state', 'state', 'build']).score,
      .5,
    );
    expect(evaluateAnswer('anything', []).score, 0);
  });
  test('question bank has five unique questions and handles missing roles', () {
    for (final role in ['', 'Flutter Developer', 'Unknown role', 'Design']) {
      final questions = questionsFor(role);
      expect(questions.length, 5);
      expect(questions.map((q) => q['q']).toSet().length, 5);
    }
  });
  test('skill comparison uses actual requirements, not preset percentages', () {
    expect(skillCoverage(['Flutter', 'Dart'], ['flutter', 'firebase']), .5);
    expect(skillCoverage([], ['Flutter']), 0);
    expect(skillCoverage(['Flutter'], []), isNull);
  });
  test('clearing account session clears CV metadata without Firebase', () {
    CvAnalysisStore.instance.save(
      CvAnalysis(
        profile: 'Developer',
        skills: ['dart'],
        matchReason: 'Evidence',
      ),
      cvFileName: 'private.pdf',
    );
    AuthService.instance.clearSession();
    expect(CvAnalysisStore.instance.hasAnalysis, false);
    expect(CvAnalysisStore.instance.cvFileName, isNull);
  });
}
