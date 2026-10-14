import 'package:flutter/material.dart';
import 'manage_active_jobs_screen.dart';
import 'applications_screen.dart';
import 'post_new_job_screen.dart';
import 'company_bottom_nav_bar.dart';

class CompanyDashboardScreen extends StatelessWidget {
  const CompanyDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Company workspace')),
    bottomNavigationBar: const CompanyBottomNavBar(currentIndex: 0),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Build your next team',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'Publish roles, review applications and follow up with candidates.',
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Post a job'),
                subtitle: const Text(
                  'Describe the role, skills and experience',
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PostNewJobScreen()),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.work_outline),
                title: const Text('Manage jobs'),
                subtitle: const Text(
                  'Publish, unpublish or remove your listings',
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageActiveJobsScreen(),
                  ),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.people_outline),
                title: const Text('Review applicants'),
                subtitle: const Text(
                  'Only applicants who submitted to your jobs appear here',
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ApplicationsScreen(forEmployer: true),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
