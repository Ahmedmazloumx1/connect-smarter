import 'package:flutter/material.dart';
import 'send_email_screen.dart';
import 'services/application_service.dart';

class CandidateProfileScreen extends StatefulWidget {
  final String name, role, email, status;
  final String? applicationId, imageAsset;
  final int matchScore;
  final double interviewScore;
  final List<String> tags;
  const CandidateProfileScreen({
    super.key,
    this.name = 'Candidate',
    this.role = 'Not provided',
    this.email = '',
    this.status = 'submitted',
    this.applicationId,
    this.imageAsset,
    this.matchScore = 0,
    this.interviewScore = 0,
    this.tags = const [],
  });
  @override
  State<CandidateProfileScreen> createState() => _CandidateState();
}

class _CandidateState extends State<CandidateProfileScreen> {
  late String _status;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    _status = widget.status;
  }

  Future<void> _setStatus(String status) async {
    setState(() => _busy = true);
    try {
      await ApplicationService.instance.updateStatus(
        widget.applicationId!,
        status,
      );
      if (mounted) setState(() => _status = status);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not update application. Please retry.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Applicant profile')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(widget.name, style: Theme.of(context).textTheme.headlineMedium),
        Text(widget.role),
        const SizedBox(height: 16),
        Text(widget.email),
        Text('Application: $_status'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: widget.tags.map((s) => Chip(label: Text(s))).toList(),
        ),
        const SizedBox(height: 24),
        const Text(
          'Skills were extracted from the applicant’s CV. Review their experience directly; no automated hiring recommendation is made.',
        ),
        const SizedBox(height: 24),
        if (widget.applicationId != null)
          Wrap(
            spacing: 12,
            children: [
              FilledButton(
                onPressed: _busy ? null : () => _setStatus('shortlisted'),
                child: const Text('Shortlist'),
              ),
              OutlinedButton(
                onPressed: _busy ? null : () => _setStatus('rejected'),
                child: const Text('Reject'),
              ),
            ],
          ),
        TextButton(
          onPressed: widget.email.isEmpty
              ? null
              : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SendEmailScreen(
                      recipientEmail: widget.email,
                      candidateName: widget.name,
                      role: widget.role,
                    ),
                  ),
                ),
          child: const Text('Draft email'),
        ),
      ],
    ),
  );
}
