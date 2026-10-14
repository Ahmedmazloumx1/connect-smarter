import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Privacy policy')),
    body: const SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: SelectableText(
        'Connect Smarter stores your account details, profile, saved CV analysis and application history in Firebase. Original CV files are processed to extract skills and are not retained by the application.\n\n'
        'Your profile and interview practice history are private to your account. When you submit an application, the employer receives the name, email, professional profile and skills shown in the application confirmation. Your private practice answers are not included.\n\n'
        'Profile images are saved when you submit your profile changes. You can edit your details, request a password reset, or delete your account and its associated application data from Account settings. Account deletion requires a recent sign-in.\n\n'
        'Keep your password private and upload only documents you have permission to use. CV analysis and interview feedback are provided to help you prepare; they do not make hiring decisions.',
      ),
    ),
  );
}
