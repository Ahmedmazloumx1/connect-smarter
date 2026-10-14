import 'package:flutter/material.dart';
import 'services/job_service.dart';
import 'job_details_screen.dart';

class ManageActiveJobsScreen extends StatefulWidget {
  const ManageActiveJobsScreen({super.key});
  @override
  State<ManageActiveJobsScreen> createState() => _ManageJobsState();
}

class _ManageJobsState extends State<ManageActiveJobsScreen> {
  late Future<List<Map<String, dynamic>>> _jobs;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    _jobs = JobService.instance.fetchJobs(ownedOnly: true);
  }

  void _reload() =>
      setState(() => _jobs = JobService.instance.fetchJobs(ownedOnly: true));
  Future<void> _change(Map<String, dynamic> job, {bool delete = false}) async {
    if (delete) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete listing?'),
          content: const Text(
            'Existing applications remain available. This listing will be removed.',
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
      if (confirm != true || !mounted) return;
    }
    setState(() => _busy = true);
    try {
      if (delete) {
        await JobService.instance.deleteJob(job['id'] as String);
      } else {
        await JobService.instance.setPublished(
          job['id'] as String,
          job['isPublic'] != true,
        );
      }
      if (mounted) _reload();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not update listing. Please retry.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Manage jobs'),
      actions: [
        IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
      ],
    ),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: _jobs,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: TextButton(
              onPressed: _reload,
              child: const Text('Unable to load. Retry'),
            ),
          );
        }
        final jobs = snapshot.data ?? [];
        if (jobs.isEmpty) {
          return const Center(child: Text('No jobs posted yet.'));
        }
        return ListView(
          padding: const EdgeInsets.all(20),
          children: jobs
              .map(
                (job) => Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('${job['title']}'),
                        subtitle: Text(
                          job['isPublic'] == true ? 'Published' : 'Private',
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JobDetailsScreen(
                              isCompanyView: true,
                              jobTitle: job['title'] as String?,
                              jobDescription: job['description'] as String?,
                              jobCompany: job['company'] as String?,
                              jobSkills: List<String>.from(job['skills'] ?? []),
                              jobQuestions: List<String>.from(
                                job['questions'] ?? [],
                              ),
                              jobLocation: job['location'] as String?,
                              jobEducation: job['education'] as String?,
                              jobMinExperience: job['minExperience'] as int?,
                            ),
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 16,
                        children: [
                          TextButton(
                            onPressed: _busy ? null : () => _change(job),
                            child: Text(
                              job['isPublic'] == true ? 'Unpublish' : 'Publish',
                            ),
                          ),
                          TextButton(
                            onPressed: _busy
                                ? null
                                : () => _change(job, delete: true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    ),
  );
}
