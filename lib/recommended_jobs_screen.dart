import 'package:flutter/material.dart';
import 'services/job_service.dart';
import 'services/job_matching.dart';
import 'services/cv_analysis_store.dart';
import 'cv_upload_screen.dart';
import 'job_details_screen.dart';
import 'account_settings_screen.dart';
import 'applications_screen.dart';
import 'ai_interview_setup_screen.dart';

class RecommendedJobsScreen extends StatefulWidget {
  final CvAnalysis? analysis;
  const RecommendedJobsScreen({super.key, this.analysis});
  @override
  State<RecommendedJobsScreen> createState() => _RecommendedJobsScreenState();
}

class _RecommendedJobsScreenState extends State<RecommendedJobsScreen> {
  List<Map<String, dynamic>> _jobs = [];
  bool _loading = true;
  bool _remote = false;
  String? _error;
  String _query = '';
  CvAnalysis? get _analysis =>
      widget.analysis ?? CvAnalysisStore.instance.analysis;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final jobs = await JobService.instance.fetchJobs();
      if (!mounted) return;
      setState(() => _jobs = jobs);
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _error = 'Could not load jobs. Check your connection and retry.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobs = _jobs
        .where(
          (j) =>
              (!_remote || j['isRemote'] == true) &&
              '${j['title']} ${j['company']}'.toLowerCase().contains(_query),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find your next role'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AccountSettingsScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              _analysis?.profile ?? 'Explore available jobs',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            if (_analysis != null)
              Wrap(
                spacing: 8,
                children: _analysis!.skills
                    .map((s) => Chip(label: Text(s)))
                    .toList(),
              ),
            Wrap(
              spacing: 12,
              children: [
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CvUploadScreen()),
                  ),
                  child: const Text('Analyze CV'),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AiInterviewSetupScreen(),
                    ),
                  ),
                  child: const Text('Practice interview'),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ApplicationsScreen(),
                    ),
                  ),
                  child: const Text('My applications'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) =>
                  setState(() => _query = value.toLowerCase().trim()),
              decoration: const InputDecoration(
                labelText: 'Search title or company',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            SwitchListTile(
              title: const Text('Remote only'),
              value: _remote,
              onChanged: (value) => setState(() => _remote = value),
            ),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Column(
                children: [
                  Text(_error!),
                  TextButton(onPressed: _load, child: const Text('Retry')),
                ],
              )
            else if (jobs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No jobs match your search. New published roles will appear here.',
                ),
              )
            else
              ...jobs.map((job) {
                final skills = List<String>.from(job['skills'] ?? const []);
                final coverage = _analysis == null
                    ? null
                    : skillCoverage(_analysis!.skills, skills);
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(20),
                    title: Text('${job['title']}'),
                    subtitle: Text(
                      '${job['company']} • ${job['location']}\n${coverage == null ? 'No skill comparison available' : '${(coverage * 100).round()}% required-skill coverage'}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    isThreeLine: true,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JobDetailsScreen(
                          jobId: job['id'] as String?,
                          employerId: job['ownerId'] as String?,
                          jobTitle: job['title'] as String?,
                          jobCompany: job['company'] as String?,
                          jobLocation: job['location'] as String?,
                          jobDescription: job['description'] as String?,
                          jobSkills: skills,
                          jobQuestions: List<String>.from(
                            job['questions'] ?? [],
                          ),
                          jobEducation: job['education'] as String?,
                          jobMinExperience: (job['minExperience'] as num?)
                              ?.toInt(),
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
