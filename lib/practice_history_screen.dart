import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'services/auth_service.dart';

class PracticeHistoryScreen extends StatefulWidget {
  const PracticeHistoryScreen({super.key});
  @override
  State<PracticeHistoryScreen> createState() => _HistoryState();
}

class _HistoryState extends State<PracticeHistoryScreen> {
  late Future<QuerySnapshot<Map<String, dynamic>>> _history;
  Future<QuerySnapshot<Map<String, dynamic>>> _load() => FirebaseFirestore
      .instance
      .collection('interviews')
      .where('candidateId', isEqualTo: AuthService.instance.currentUser!.uid)
      .get();
  @override
  void initState() {
    super.initState();
    _history = _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Private practice history'),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: () => setState(() => _history = _load()),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: _history,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: TextButton(
              onPressed: () => setState(() => _history = _load()),
              child: const Text('Could not load history. Retry'),
            ),
          );
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No saved practice sessions yet.'));
        }
        return ListView(
          padding: const EdgeInsets.all(24),
          children: docs.map((doc) {
            final data = doc.data();
            final value = data['overallScore'];
            final score = value is num
                ? '${(value * 100).round()}%'
                : 'Unknown';
            final created = data['createdAt'];
            final date = created is Timestamp
                ? created.toDate().toLocal().toString().split('.').first
                : 'Date unavailable';
            final results = data['questionResults'] is List
                ? data['questionResults'] as List
                : const [];
            return Card(
              child: ExpansionTile(
                title: Text(
                  '${data['major'] ?? 'Practice'} — $score concept coverage',
                ),
                subtitle: Text(date),
                children: results
                    .whereType<Map>()
                    .map(
                      (q) => ListTile(
                        title: Text('${q['question'] ?? ''}'),
                        subtitle: Text('${q['answer'] ?? 'Not recorded'}'),
                      ),
                    )
                    .toList(),
              ),
            );
          }).toList(),
        );
      },
    ),
  );
}
