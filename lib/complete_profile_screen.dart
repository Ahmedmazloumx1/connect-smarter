import 'package:flutter/material.dart';
import 'company_dashboard_screen.dart';
import 'cv_upload_screen.dart';
import 'services/auth_service.dart';

/// Recovery after Auth succeeds but the separate profile write fails.
class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({
    super.key,
    this.initialProfile = const {},
    this.saveProfile,
  });
  final Map<String, dynamic> initialProfile;
  final Future<String> Function(Map<String, dynamic>)? saveProfile;

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfileScreen> {
  late final TextEditingController _name;
  late String _role;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _role = widget.initialProfile['userType'] == 'company'
        ? 'company'
        : 'job_seeker';
    _name = TextEditingController(
      text:
          (widget.initialProfile[_role == 'company'
                      ? 'companyName'
                      : 'firstName'] ??
                  '')
              .toString(),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Enter your name to continue.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final save = widget.saveProfile ?? AuthService.instance.completeProfile;
      final role = await save({
        ...widget.initialProfile,
        'userType': _role,
        _role == 'company' ? 'companyName' : 'firstName': _name.text.trim(),
      });
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => role == 'company'
              ? const CompanyDashboardScreen()
              : const CvUploadScreen(),
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Your profile could not be saved. Check your connection and retry. Your account already exists; use Sign in / Resume if you leave this screen.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Finish account setup')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Your sign-in account is ready. Save your profile to continue. If a connection failed, retry here without creating another account.',
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: _role,
              decoration: const InputDecoration(labelText: 'Account type'),
              items: const [
                DropdownMenuItem(value: 'job_seeker', child: Text('Candidate')),
                DropdownMenuItem(value: 'company', child: Text('Company')),
              ],
              onChanged: _busy || widget.initialProfile['userType'] != null
                  ? null
                  : (value) => setState(() => _role = value!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              enabled: !_busy,
              maxLength: 100,
              decoration: InputDecoration(
                labelText: _role == 'company' ? 'Company name' : 'First name',
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.orangeAccent),
                ),
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(_busy ? 'Saving…' : 'Save profile and continue'),
            ),
          ],
        ),
      ),
    ),
  );
}
