import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SendEmailScreen extends StatefulWidget {
  final String recipientEmail, candidateName, role;
  const SendEmailScreen({
    super.key,
    this.recipientEmail = '',
    this.candidateName = 'Candidate',
    this.role = 'the role',
  });
  @override
  State<SendEmailScreen> createState() => _ComposeState();
}

class _ComposeState extends State<SendEmailScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _to, _subject, _body;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    _to = TextEditingController(text: widget.recipientEmail);
    _subject = TextEditingController(
      text: 'Your application for ${widget.role}',
    );
    _body = TextEditingController(
      text:
          'Hello ${widget.candidateName},\n\nThank you for your application for ${widget.role}. We would like to discuss the next steps with you.\n\nBest regards',
    );
  }

  @override
  void dispose() {
    _to.dispose();
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _openDraft() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final query = {'subject': _subject.text, 'body': _body.text}.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&');
      final opened = await launchUrl(
        Uri(scheme: 'mailto', path: _to.text.trim(), query: query),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            opened
                ? 'Draft opened. Review and send it from your mail app.'
                : 'No mail app found. Copy this draft into your email client.',
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open a mail app. Copy your draft manually.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Draft email')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Review the recipient and message. Sending takes place in your email app.',
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _to,
                decoration: const InputDecoration(labelText: 'To'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value != null &&
                        RegExp(
                          r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                        ).hasMatch(value.trim())
                    ? null
                    : 'Enter a valid email',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subject,
                decoration: const InputDecoration(labelText: 'Subject'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter a subject' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _body,
                decoration: const InputDecoration(labelText: 'Message'),
                minLines: 8,
                maxLines: 16,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter a message' : null,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy ? null : _openDraft,
                child: const Text('Open in mail app'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
