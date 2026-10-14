import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'interview_result_screen.dart';
import 'services/interview_questions.dart';
import 'services/interview_scoring.dart';
import 'services/interview_store.dart';
import 'services/auth_service.dart';
import 'services/firebase_service.dart';

class AiInterviewScreen extends StatefulWidget {
  final String major;
  const AiInterviewScreen({super.key, this.major = 'General'});
  @override
  State<AiInterviewScreen> createState() => _AiInterviewScreenState();
}

class _AiInterviewScreenState extends State<AiInterviewScreen> {
  final _answer = TextEditingController();
  late final List<Map<String, dynamic>> _questions;
  final _results = <QuestionResult>[];
  Timer? _timer;
  int _remaining = 120;
  int _index = 0;
  bool _finished = false;
  @override
  void initState() {
    super.initState();
    _questions = questionsFor(widget.major);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _remaining = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _finished) return;
      if (_remaining <= 1) {
        _advance();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _advance({bool skip = false}) {
    if (_finished) return;
    _timer?.cancel();
    final answer = skip ? '' : _answer.text.trim();
    final hints = List<String>.from(_questions[_index]['hints'] as List);
    final feedback = evaluateAnswer(answer, hints);
    _results.add(
      QuestionResult(
        question: _questions[_index]['q'] as String,
        answered: answer.isNotEmpty,
        score: feedback.score,
        answer: answer,
        coveredConcepts: feedback.covered,
        missingConcepts: feedback.missing,
      ),
    );
    if (_index == _questions.length - 1) {
      _finish();
      return;
    }
    setState(() {
      _index++;
      _answer.clear();
    });
    _startTimer();
  }

  Future<void> _finish() async {
    setState(() => _finished = true);
    final average =
        _results.fold<double>(0, (total, q) => total + q.score) /
        _questions.length;
    final result = InterviewResult(
      major: widget.major,
      candidateName: 'You',
      overallScore: average,
      questionResults: List.unmodifiable(_results),
      timestamp: DateTime.now(),
    );
    InterviewStore.instance.save(result);
    bool saved = false;
    if (FirebaseService.isInitialized) {
      final user = AuthService.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('interviews')
              .add({
                'candidateId': user.uid,
                'major': widget.major,
                'overallScore': average,
                'method': 'practice-keyword-coverage-v1',
                'createdAt': FieldValue.serverTimestamp(),
                'questionResults': _results
                    .map(
                      (q) => {
                        'question': q.question,
                        'answer': q.answer,
                        'answered': q.answered,
                        'score': q.score,
                        'covered': q.coveredConcepts,
                        'missing': q.missingConcepts,
                      },
                    )
                    .toList(),
              })
              .timeout(const Duration(seconds: 10));
          saved = true;
        } catch (error) {
          debugPrint('Practice result remains local: $error');
        }
      }
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => InterviewResultScreen(
          score: average,
          result: result,
          savedToAccount: saved,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Interview practice')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              widget.major,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Text(
              'Question ${_index + 1} of ${_questions.length} • $_remaining seconds',
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: (_index + 1) / _questions.length),
            const SizedBox(height: 24),
            Text(
              _questions[_index]['q'] as String,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _answer,
              enabled: !_finished,
              minLines: 6,
              maxLines: 12,
              maxLength: 5000,
              decoration: const InputDecoration(
                labelText: 'Your answer',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton(
                  onPressed: _finished ? null : _advance,
                  child: Text(
                    _finished
                        ? 'Saving results…'
                        : _index == _questions.length - 1
                        ? 'Finish practice'
                        : 'Submit answer',
                  ),
                ),
                TextButton(
                  onPressed: _finished ? null : () => _advance(skip: true),
                  child: const Text('Skip question'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Practice feedback measures reference-concept coverage only. Camera, appearance and voice do not affect your score.',
            ),
          ],
        ),
      ),
    ),
  );
}
