import 'package:flutter/material.dart';
import 'ai_interview_setup_screen.dart';
import 'services/application_service.dart';

class JobDetailsScreen extends StatefulWidget {
  final bool showActions, isCompanyView;
  final String? jobId,
      employerId,
      jobTitle,
      jobCompany,
      jobLocation,
      jobDescription,
      jobEducation;
  final List<String>? jobSkills, jobQuestions;
  final int? jobMinExperience;
  const JobDetailsScreen({
    super.key,
    this.showActions = true,
    this.isCompanyView = false,
    this.jobId,
    this.employerId,
    this.jobTitle,
    this.jobCompany,
    this.jobLocation,
    this.jobDescription,
    this.jobEducation,
    this.jobSkills,
    this.jobQuestions,
    this.jobMinExperience,
  });
  @override
  State<JobDetailsScreen> createState() => _JobDetailsState();
}

class _JobDetailsState extends State<JobDetailsScreen> {
  bool _busy = false;
  bool _applied = false;
  Future<void> _apply() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit application?'),
        content: const Text(
          'Your name, email and extracted CV skills will be shared with this employer. Your private practice answers are not shared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ApplicationService.instance.apply(
        widget.jobId!,
        widget.employerId!,
        widget.jobTitle ?? 'Job',
      );
      if (mounted) setState(() => _applied = true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Job details')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              widget.jobTitle ?? 'No job selected',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              '${widget.jobCompany ?? ''} • ${widget.jobLocation ?? 'Location not specified'}',
            ),
            const SizedBox(height: 24),
            Text(widget.jobDescription ?? 'No description supplied.'),
            const SizedBox(height: 24),
            Text('Education: ${widget.jobEducation ?? 'Not specified'}'),
            Text('Minimum experience: ${widget.jobMinExperience ?? 0} years'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: (widget.jobSkills ?? [])
                  .map((s) => Chip(label: Text(s)))
                  .toList(),
            ),
            const SizedBox(height: 24),
            if ((widget.jobQuestions ?? []).isNotEmpty) ...[
              Text(
                'Questions to prepare',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              for (final entry in widget.jobQuestions!.asMap().entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text('${entry.key + 1}. ${entry.value}'),
                ),
              const Text(
                'Employer preparation questions. The practice exercise uses its own question bank.',
              ),
              const SizedBox(height: 24),
            ],
            if (widget.showActions && !widget.isCompanyView) ...[
              FilledButton(
                onPressed:
                    _busy ||
                        _applied ||
                        widget.jobId == null ||
                        widget.employerId == null
                    ? null
                    : _apply,
                child: Text(
                  _applied
                      ? 'Application submitted'
                      : _busy
                      ? 'Submitting…'
                      : 'Apply for this role',
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AiInterviewSetupScreen(major: widget.jobTitle),
                  ),
                ),
                child: const Text('Practice for this role'),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
