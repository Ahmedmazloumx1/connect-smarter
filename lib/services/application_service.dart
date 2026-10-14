import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'cv_analysis_store.dart';
import 'record_parser.dart';

class ApplicationService {
  static final instance = ApplicationService();
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  Future<void> apply(String jobId, String employerId, String title) async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw StateError('Sign in to apply.');
    final cv = CvAnalysisStore.instance.analysis;
    if (cv == null) throw StateError('Analyze your CV before applying.');
    final profile = await AuthService.instance.getUserProfile(user.uid);
    final name =
        '${recordText(profile?['firstName'])} ${recordText(profile?['lastName'])}'
            .trim();
    final ref = _db.collection('applications').doc('${jobId}_${user.uid}');
    await _db.runTransaction((transaction) async {
      if ((await transaction.get(ref)).exists) {
        throw StateError('You already applied for this job.');
      }
      transaction.set(ref, {
        'candidateId': user.uid,
        'employerId': employerId,
        'jobId': jobId,
        'jobTitle': recordText(
          title,
          fallback: 'Unavailable listing',
          maxLength: 200,
        ),
        'candidateName': recordText(
          name,
          fallback: 'Candidate',
          maxLength: 200,
        ),
        'email': user.email ?? '',
        'profile': recordText(
          cv.profile,
          fallback: 'General Professional',
          maxLength: 200,
        ),
        'skills': recordTextList(cv.skills),
        'status': 'submitted',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<List<Map<String, dynamic>>> list({required bool forEmployer}) async {
    final uid = AuthService.instance.currentUser?.uid;
    if (uid == null) throw StateError('Please sign in.');
    final snapshot = await _db
        .collection('applications')
        .where(forEmployer ? 'employerId' : 'candidateId', isEqualTo: uid)
        .get();
    return snapshot.docs
        .map((d) => parseApplicationRecord(d.id, d.data()))
        .toList();
  }

  Future<void> updateStatus(String id, String status) =>
      _db.collection('applications').doc(id).update({'status': status});
}
