/// Transparent practice feedback. Keyword coverage is not a hiring decision.
class AnswerFeedback {
  final double score;
  final List<String> covered;
  final List<String> missing;
  const AnswerFeedback(this.score, this.covered, this.missing);
}

AnswerFeedback evaluateAnswer(String answer, List<String> hints) {
  final unique = hints
      .map((s) => s.trim().toLowerCase())
      .where((s) => s.isNotEmpty)
      .toSet();
  final covered = unique
      .where(
        (hint) => RegExp(
          '(?<![a-z0-9_])${RegExp.escape(hint)}(?![a-z0-9_])',
          caseSensitive: false,
        ).hasMatch(answer),
      )
      .toList();
  return AnswerFeedback(
    unique.isEmpty ? 0 : covered.length / unique.length,
    covered,
    unique.where((hint) => !covered.contains(hint)).toList(),
  );
}
