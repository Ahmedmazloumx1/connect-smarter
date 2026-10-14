import 'package:flutter/material.dart';
import 'services/interview_store.dart';
import 'ai_interview_setup_screen.dart';
import 'recommended_jobs_screen.dart';

class InterviewResultScreen extends StatelessWidget {
  final double score;
  final InterviewResult? result;
  final bool savedToAccount;
  const InterviewResultScreen({
    super.key,
    this.score = 0,
    this.result,
    this.savedToAccount = false,
  });
  @override
  Widget build(BuildContext context) {
    final report = result ?? InterviewStore.instance.result;
    return Scaffold(
      appBar: AppBar(title: const Text('Practice feedback')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                report == null
                    ? 'No result yet'
                    : '${(report.overallScore * 100).round()}% concept coverage',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              const Text(
                'This deterministic practice score counts reference concepts mentioned in your written answers. It does not verify correctness or determine job eligibility.',
              ),
              const SizedBox(height: 8),
              Text(
                savedToAccount
                    ? 'Saved privately to your account.'
                    : 'Available in this session only. Your result was not saved to an account.',
              ),
              const SizedBox(height: 24),
              if (report != null)
                ...report.questionResults.map(
                  (q) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q.question,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(q.answered ? q.answer : 'Not answered'),
                          const SizedBox(height: 12),
                          Text(
                            'Covered: ${q.coveredConcepts.isEmpty ? 'None' : q.coveredConcepts.join(', ')}',
                          ),
                          Text(
                            'Review: ${q.missingConcepts.isEmpty ? 'All reference concepts mentioned' : q.missingConcepts.join(', ')}',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AiInterviewSetupScreen(major: report?.major),
                  ),
                ),
                child: const Text('Practice again'),
              ),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RecommendedJobsScreen(),
                  ),
                ),
                child: const Text('Browse jobs'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
