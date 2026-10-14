import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'firebase_service.dart';
import 'record_parser.dart';

class JobService {
  JobService._();
  static final JobService instance = JobService._();
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  Future<List<Map<String, dynamic>>> fetchJobs({bool ownedOnly = false}) async {
    if (!FirebaseService.isInitialized) {
      throw StateError('Firebase is not configured.');
    }
    final uid = AuthService.instance.currentUser?.uid;
    if (uid == null) throw StateError('Sign in to browse jobs.');
    final query = ownedOnly
        ? _db.collection('jobs').where('ownerId', isEqualTo: uid)
        : _db.collection('jobs').where('isPublic', isEqualTo: true);
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => parseJobRecord(doc.id, doc.data()))
        .where(
          (job) =>
              job['ownerId'] is String &&
              (job['ownerId'] as String).trim().isNotEmpty,
        )
        .toList();
  }

  Future<void> saveJob(Map<String, dynamic> job) async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw StateError('Sign in to post a job.');
    if ((job['title'] ?? '').toString().trim().isEmpty) {
      throw ArgumentError('A title is required.');
    }
    await _db.collection('jobs').add({
      ...job,
      'ownerId': user.uid,
      'applicants': 0,
      'progress': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setPublished(String id, bool published) =>
      _db.collection('jobs').doc(id).update({'isPublic': published});
  Future<void> deleteJob(String id) => _db.collection('jobs').doc(id).delete();
}
