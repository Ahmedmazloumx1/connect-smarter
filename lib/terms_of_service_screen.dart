import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Terms of use')),
    body: const SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: SelectableText(
        'Connect Smarter helps candidates manage professional profiles, explore jobs, submit applications and prepare for interviews. Employers can publish jobs and review applications submitted to them.\n\n'
        'Provide accurate account and professional information. Use only CVs, images and job content that you are entitled to share. Keep account credentials private, and do not use the service to impersonate people, post misleading opportunities, or access another user’s private information.\n\n'
        'CV skill comparisons and interview feedback are guidance based on the information supplied. Candidates should review their extracted skills, and employers remain responsible for their hiring decisions. An application does not guarantee an interview or job offer.\n\n'
        'Before submitting an application, review the information shared with the employer. Email composition opens a draft in your mail application; you review and send it there. You can manage or delete your account from Account settings.',
      ),
    ),
  );
}
