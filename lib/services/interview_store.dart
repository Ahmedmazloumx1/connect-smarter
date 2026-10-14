/// Private session state. Employer screens never read this store.
library;

class QuestionResult {
  final String question;

  /// Was the question answered (not skipped)?
  final bool answered;
  final String answer;
  final List<String> coveredConcepts;
  final List<String> missingConcepts;

  /// Fraction of reference concepts mentioned, from 0.0 to 1.0.
  final double score;

  const QuestionResult({
    this.answer = '',
    this.coveredConcepts = const [],
    this.missingConcepts = const [],
    required this.question,
    required this.answered,
    required this.score,
  });
}

class InterviewResult {
  final String major;
  final String candidateName;

  // Scores (0.0 – 1.0)
  final double overallScore;

  final List<QuestionResult> questionResults;
  final DateTime timestamp;

  const InterviewResult({
    required this.major,
    required this.candidateName,
    required this.overallScore,
    required this.questionResults,
    required this.timestamp,
  });

  int get totalQuestions => questionResults.length;
  int get answeredCount => questionResults.where((q) => q.answered).length;
}

class InterviewStore {
  InterviewStore._();
  static final InterviewStore instance = InterviewStore._();

  InterviewResult? _result;

  bool get hasResult => _result != null;
  InterviewResult? get result => _result;

  void save(InterviewResult result) => _result = result;

  void clear() => _result = null;
}
