import 'package:flutter/material.dart';
import 'services/application_service.dart';
import 'candidate_profile_screen.dart';

class ApplicationsScreen extends StatefulWidget {
  final bool forEmployer;
  const ApplicationsScreen({super.key, this.forEmployer = false});
  @override
  State<ApplicationsScreen> createState() => _ApplicationsState();
}

class _ApplicationsState extends State<ApplicationsScreen> {
  late Future<List<Map<String, dynamic>>> _items;
  @override
  void initState() {
    super.initState();
    _items = _load();
  }

  Future<List<Map<String, dynamic>>> _load() =>
      ApplicationService.instance.list(forEmployer: widget.forEmployer);
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.forEmployer ? 'Applicants' : 'My applications'),
      actions: [
        IconButton(
          onPressed: () => setState(() => _items = _load()),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: _items,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Could not load applications.'),
                TextButton(
                  onPressed: () => setState(() => _items = _load()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('No applications yet.'));
        }
        return ListView(
          padding: const EdgeInsets.all(20),
          children: items
              .map(
                (item) => Card(
                  child: ListTile(
                    title: Text('${item['jobTitle']}'),
                    subtitle: Text(
                      '${item['candidateName']} • ${item['status']}',
                    ),
                    trailing: widget.forEmployer
                        ? const Icon(Icons.chevron_right)
                        : null,
                    onTap: !widget.forEmployer
                        ? null
                        : () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CandidateProfileScreen(
                                  name: '${item['candidateName']}',
                                  role: '${item['profile']}',
                                  tags: List<String>.from(item['skills'] ?? []),
                                  email: '${item['email']}',
                                  applicationId: '${item['id']}',
                                  status: '${item['status']}',
                                ),
                              ),
                            );
                            if (mounted) setState(() => _items = _load());
                          },
                  ),
                ),
              )
              .toList(),
        );
      },
    ),
  );
}
