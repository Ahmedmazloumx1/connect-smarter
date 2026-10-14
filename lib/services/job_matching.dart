/// Fraction of required skills explicitly found in a CV. Null means no rubric.
double? skillCoverage(List<String> candidate, List<String> required) {
  final requirements = required
      .map((s) => s.trim().toLowerCase())
      .where((s) => s.isNotEmpty)
      .toSet();
  if (requirements.isEmpty) return null;
  final skills = candidate.map((s) => s.trim().toLowerCase()).toSet();
  return requirements.where(skills.contains).length / requirements.length;
}
