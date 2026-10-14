import 'package:flutter/material.dart';
import 'account_settings_screen.dart';

class CompanySettingsScreen extends StatelessWidget {
  const CompanySettingsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const AccountSettingsScreen(company: true);
}
