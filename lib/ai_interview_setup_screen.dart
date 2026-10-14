import 'package:flutter/material.dart';
import 'ai_interview_screen.dart';
import 'services/cv_analysis_store.dart';

class AiInterviewSetupScreen extends StatefulWidget {
  final String? major;
  const AiInterviewSetupScreen({super.key, this.major});
  @override
  State<AiInterviewSetupScreen> createState() => _SetupState();
}

class _SetupState extends State<AiInterviewSetupScreen> {
  late final TextEditingController _role;
  @override
  void initState() {
    super.initState();
    _role = TextEditingController(
      text:
          widget.major ??
          CvAnalysisStore.instance.analysis?.profile ??
          'General',
    );
  }

  @override
  void dispose() {
    _role.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Interview practice')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(24),
          shrinkWrap: true,
          children: [
            const Icon(
              Icons.question_answer_outlined,
              size: 64,
              color: Colors.tealAccent,
            ),
            const SizedBox(height: 24),
            Text(
              'Prepare for your next interview',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Text(
              'Answer five practice questions in writing. You have two minutes per question. Feedback shows which reference concepts your answer mentions. It does not judge factual correctness or predict hiring outcomes.',
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _role,
              decoration: const InputDecoration(
                labelText: 'Role or specialty',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No camera or microphone is needed. Results are private to your account.',
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => AiInterviewScreen(
                    major: _role.text.trim().isEmpty
                        ? 'General'
                        : _role.text.trim(),
                  ),
                ),
              ),
              child: const Text('Start practice'),
            ),
          ],
        ),
      ),
    ),
  );
}
