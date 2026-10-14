import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

class FirebaseService {
  FirebaseService._();
  static bool _initialized = false;
  static bool get isInitialized => _initialized;
  static Future<void> initialize() async {
    if (_initialized) return;
    const emulator = bool.fromEnvironment('FIREBASE_EMULATORS');
    const appId = String.fromEnvironment('FIREBASE_APP_ID');
    final options = emulator
        ? const FirebaseOptions(
            apiKey: 'demo-key',
            appId: '1:123456789:web:demo',
            messagingSenderId: '123456789',
            projectId: 'demo-connect-smarter',
          )
        : DefaultFirebaseOptions.currentPlatform;
    if (!emulator &&
        kIsWeb &&
        appId.isEmpty &&
        !options.appId.contains(':web:')) {
      throw StateError(
        'The Firebase web app ID is invalid. Run flutterfire configure for your web app, or use FIREBASE_EMULATORS=true.',
      );
    }
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: appId.isEmpty
            ? options
            : FirebaseOptions(
                apiKey: options.apiKey,
                appId: appId,
                messagingSenderId: options.messagingSenderId,
                projectId: options.projectId,
                authDomain: options.authDomain,
                storageBucket: options.storageBucket,
              ),
      );
    }
    if (emulator) {
      final defaultHost =
          !kIsWeb && defaultTargetPlatform == TargetPlatform.android
          ? '10.0.2.2'
          : '127.0.0.1';
      const configuredHost = String.fromEnvironment('FIREBASE_EMULATOR_HOST');
      final host = configuredHost.isEmpty ? defaultHost : configuredHost;
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: false,
      );
    }
    _initialized = true;
  }
}
