import 'package:flutter/material.dart';
import 'applications_screen.dart';

class CompanyNotificationsScreen extends StatelessWidget {
  const CompanyNotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const ApplicationsScreen(forEmployer: true);
}
