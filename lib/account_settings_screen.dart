import 'practice_history_screen.dart';
import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'services/firebase_service.dart';
import 'edit_profile_screen.dart';
import 'company_profile_editor_screen.dart';
import 'main.dart';

class AccountSettingsScreen extends StatefulWidget {
  final bool company;
  const AccountSettingsScreen({super.key, this.company = false});
  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettingsScreen> {
  bool _busy = false;
  Future<void> _action(
    Future<void> Function() action, {
    bool exit = false,
    String? success,
  }) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      if (exit) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const StartScreen()),
          (_) => false,
        );
      } else if (success != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(success)));
      }
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

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account and data?'),
        content: const Text(
          'This removes your profile, jobs, applications and practice history. Sign in again first if your session is older than five minutes. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _action(AuthService.instance.deleteAccount, exit: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseService.isInitialized
        ? AuthService.instance.currentUser
        : null;
    return Scaffold(
      appBar: AppBar(title: const Text('Account settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            user?.email ?? 'Sign in to manage your account',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          if (user != null) ...[
            if (!widget.company)
              ListTile(
                title: const Text('Practice history'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PracticeHistoryScreen(),
                  ),
                ),
              ),
            ListTile(
              title: const Text('Edit profile'),
              leading: const Icon(Icons.edit_outlined),
              onTap: _busy
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => widget.company
                            ? const CompanyProfileEditorScreen()
                            : const EditProfileScreen(),
                      ),
                    ),
            ),
            ListTile(
              title: const Text('Reset password'),
              subtitle: const Text(
                'Send a secure reset link to your sign-in email',
              ),
              onTap: _busy
                  ? null
                  : () => _action(
                      () => AuthService.instance.sendPasswordReset(user.email!),
                      success:
                          'Password reset email requested. Check your inbox.',
                    ),
            ),
            ListTile(
              title: const Text('Sign out'),
              onTap: _busy
                  ? null
                  : () => _action(AuthService.instance.signOut, exit: true),
            ),
            ListTile(
              title: const Text(
                'Delete account',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: _busy ? null : _delete,
            ),
          ] else
            const Text('Sign in to manage your profile and save results.'),
          if (_busy) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}
