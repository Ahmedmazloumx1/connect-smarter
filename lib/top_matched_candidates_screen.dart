import 'package:flutter/material.dart';
import 'applications_screen.dart';

class TopMatchedCandidatesScreen extends StatelessWidget {
  const TopMatchedCandidatesScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const ApplicationsScreen(forEmployer: true);
}
