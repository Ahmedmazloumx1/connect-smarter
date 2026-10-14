import 'package:flutter/material.dart';
import 'models/cv_analysis.dart';
import 'recommended_jobs_screen.dart';
import 'ai_interview_setup_screen.dart';
import 'services/auth_service.dart';

class CvAnalyzeScreen extends StatelessWidget {
  final CvAnalysis analysis;
  final bool savedToAccount;
  const CvAnalyzeScreen({
    super.key,
    required this.analysis,
    this.savedToAccount = false,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('CV analysis')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              analysis.profile,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(analysis.matchReason),
            const SizedBox(height: 24),
            const Text('Skills found in your document'),
            Wrap(
              spacing: 8,
              children: analysis.skills
                  .map((s) => Chip(label: Text(s)))
                  .toList(),
            ),
            if (analysis.skills.isEmpty)
              const Text(
                'No known skills found. You can still practice interviews.',
              ),
            const SizedBox(height: 24),
            Text(
              savedToAccount
                  ? 'Saved to your account.'
                  : 'This analysis is available in this session only.',
            ),
            const SizedBox(height: 24),
            if (AuthService.instance.currentUser != null)
              FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecommendedJobsScreen(analysis: analysis),
                  ),
                ),
                child: const Text('Browse jobs'),
              ),
            OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AiInterviewSetupScreen(major: analysis.profile),
                ),
              ),
              child: const Text('Practice interview'),
            ),
          ],
        ),
      ),
    ),
  );
}
