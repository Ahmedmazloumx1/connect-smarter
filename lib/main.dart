import 'package:flutter/material.dart';
import 'services/firebase_service.dart';
import 'services/auth_service.dart';
import 'complete_profile_screen.dart';
import 'login_screen.dart';
import 'user_sign_up_screen.dart';
import 'create_company_account_screen.dart';
import 'company_dashboard_screen.dart';
import 'recommended_jobs_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Connect Smarter',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00BFA5),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0A0E21),
    ),
    home: const StartScreen(),
  );
}

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});
  @override
  State<StartScreen> createState() => _StartState();
}

class _StartState extends State<StartScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _openAccount({bool signup = false, bool company = false}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await FirebaseService.initialize().timeout(const Duration(seconds: 15));
      if (!signup) {
        await AuthService.instance.validateSession();
      }
      final user = AuthService.instance.currentUser;
      Widget page;
      if (user != null && !signup) {
        await AuthService.instance.restoreProfile(user.uid);
        final role = await AuthService.instance.getUserType(user.uid);
        page = role == null
            ? const CompleteProfileScreen()
            : role == 'company'
            ? const CompanyDashboardScreen()
            : const RecommendedJobsScreen();
      } else {
        page = signup
            ? company
                  ? const CreateCompanyAccountScreen()
                  : const UserSignUpScreen()
            : const LoginScreen();
      }
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => page),
      );
    } catch (error) {
      debugPrint('Account connection failed: $error');
      if (mounted) {
        setState(
          () => _error =
              'We could not connect to your account. Check your connection and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openPage(Widget page) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF091D26), Color(0xFF0A0E21), Color(0xFF11162D)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.hub_outlined,
                      size: 32,
                      color: Colors.tealAccent,
                    ),
                    SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'Connect Smarter',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 56),
                Text(
                  'Your next opportunity\nstarts here.',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Bring your skills into focus, prepare for interviews, and connect with employers. One account keeps your profile, applications, and progress together.',
                  style: TextStyle(
                    fontSize: 17,
                    color: Color(0xFFB6C6D3),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _openAccount,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(_busy ? 'Connecting…' : 'Sign in'),
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.orangeAccent),
                    ),
                  ),
                const SizedBox(height: 40),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final candidate = _AccountCard(
                      icon: Icons.person_outline,
                      title: 'For candidates',
                      description:
                          'Build your profile, discover roles that fit your skills, and track every application.',
                      button: 'Create a candidate account',
                      onPressed: _busy
                          ? null
                          : () => _openAccount(signup: true),
                    );
                    final employer = _AccountCard(
                      icon: Icons.business_outlined,
                      title: 'For employers',
                      description:
                          'Publish open positions, review applicants, and manage your hiring workflow.',
                      button: 'Create a company account',
                      onPressed: _busy
                          ? null
                          : () => _openAccount(signup: true, company: true),
                    );
                    if (constraints.maxWidth >= 720) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: candidate),
                          const SizedBox(width: 20),
                          Expanded(child: employer),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        candidate,
                        const SizedBox(height: 16),
                        employer,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),
                const Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  children: [
                    _Feature(
                      icon: Icons.description_outlined,
                      text: 'CV skill analysis',
                    ),
                    _Feature(
                      icon: Icons.question_answer_outlined,
                      text: 'Interview preparation',
                    ),
                    _Feature(
                      icon: Icons.lock_outline,
                      text: 'Private account history',
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                const Divider(),
                Wrap(
                  spacing: 16,
                  children: [
                    TextButton(
                      onPressed: () => _openPage(const PrivacyPolicyScreen()),
                      child: const Text('Privacy policy'),
                    ),
                    TextButton(
                      onPressed: () => _openPage(const TermsOfServiceScreen()),
                      child: const Text('Terms of use'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.button,
    required this.onPressed,
  });
  final IconData icon;
  final String title, description, button;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: Card(
      margin: EdgeInsets.zero,
      color: const Color(0xFF142431),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.tealAccent, size: 32),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(color: Color(0xFFB6C6D3), height: 1.6),
            ),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: onPressed, child: Text(button)),
          ],
        ),
      ),
    ),
  );
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 20, color: Colors.tealAccent),
      const SizedBox(width: 8),
      Flexible(child: Text(text)),
    ],
  );
}
