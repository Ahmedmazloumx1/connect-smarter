import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';
import 'dart:convert';
import 'cv_analysis_store.dart';
import 'interview_store.dart';
import 'profile_image_manager.dart';
import '../models/cv_analysis.dart';

class ProfileSetupRequiredException implements Exception {
  const ProfileSetupRequiredException(this.profile);
  final Map<String, dynamic> profile;
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  User? get currentUser =>
      FirebaseService.isInitialized ? _auth.currentUser : null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<bool> validateSession() async {
    final user = currentUser;
    if (user == null) return false;
    try {
      await user.reload();
      return _auth.currentUser != null;
    } on FirebaseAuthException catch (error) {
      if (const [
        'user-not-found',
        'user-disabled',
        'user-token-expired',
        'invalid-user-token',
      ].contains(error.code)) {
        await signOut();
        return false;
      }
      rethrow;
    }
  }

  Future<void> registerWithProfile({
    required String email,
    required String password,
    required Map<String, dynamic> profile,
  }) async {
    clearSession();
    await _auth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    try {
      await completeProfile(profile);
    } catch (_) {
      // Auth and Firestore cannot commit atomically. Keep the authenticated
      // account recoverable instead of retrying account creation with this email.
      throw ProfileSetupRequiredException(Map.of(profile));
    }
  }

  Future<String> completeProfile(Map<String, dynamic> profile) async {
    final user = currentUser;
    if (user == null) throw StateError('Sign in to finish your account setup.');
    final role = profile['userType'];
    if (role != 'company' && role != 'job_seeker') {
      throw ArgumentError('Choose an account type.');
    }
    final ref = _firestore.collection('users').doc(user.uid);
    return _firestore.runTransaction((transaction) async {
      final existing = (await transaction.get(ref)).data()?['userType'];
      // A previous attempt may have committed even if its response was lost.
      if (existing == 'company' || existing == 'job_seeker') {
        return existing as String;
      }
      transaction.set(ref, {
        ...profile,
        'email': user.email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return role as String;
    });
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    clearSession();
    return _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
  }

  void clearSession() {
    CvAnalysisStore.instance.clear();
    InterviewStore.instance.clear();
    ProfileImageManager().profileImage.value = null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    clearSession();
  }

  Future<void> restoreProfile(String uid) async {
    clearSession();
    final profile = await getUserProfile(uid);
    final photo = profile?['photoBase64'];
    if (photo is String) {
      try {
        ProfileImageManager().profileImage.value = base64Decode(photo);
      } on FormatException {
        /* Old invalid image data must not block sign-in. */
      }
    }
    final cv = profile?['cvAnalysis'];
    if (cv is Map && cv['profile'] is String && cv['skills'] is List) {
      CvAnalysisStore.instance.save(
        CvAnalysis(
          profile: cv['profile'] as String,
          skills: (cv['skills'] as List).whereType<String>().toList(),
          matchReason: (cv['matchReason'] ?? '').toString(),
        ),
        cvFileName: cv['fileName'] is String ? cv['fileName'] as String : null,
        cvFileSizeBytes: cv['fileSizeBytes'] is int
            ? cv['fileSizeBytes'] as int
            : null,
      );
    }
  }

  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) return;
    final signedInAt = user.metadata.lastSignInTime;
    if (signedInAt == null ||
        DateTime.now().difference(signedInAt).inMinutes >= 5) {
      throw StateError(
        'Please sign out and sign in again before deleting your account.',
      );
    }
    // Delete in small batches to respect Firestore batch limits.
    for (final entry in {
      'interviews': 'candidateId',
      'jobs': 'ownerId',
      'notifications': 'recipientId',
    }.entries) {
      await _deleteWhere(entry.key, entry.value, user.uid);
    }
    await _deleteWhere('applications', 'candidateId', user.uid);
    await _deleteWhere('applications', 'employerId', user.uid);
    await _firestore.collection('users').doc(user.uid).delete();
    await user.delete();
    clearSession();
  }

  Future<void> _deleteWhere(String collection, String field, String uid) async {
    while (true) {
      final snapshot = await _firestore
          .collection(collection)
          .where(field, isEqualTo: uid)
          .limit(100)
          .get();
      if (snapshot.docs.isEmpty) break;
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  Future<void> saveUserProfile(String uid, Map<String, dynamic> data) {
    return _firestore.collection('users').doc(uid).set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<String?> getUserType(String uid) async {
    final data = await getUserProfile(uid);
    final role = data?['userType'];
    return role == 'company' || role == 'job_seeker' ? role as String : null;
  }

  String formatAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }
}
