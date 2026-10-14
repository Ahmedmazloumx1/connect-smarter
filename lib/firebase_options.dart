// Configured for the user's Firebase project: connect-smarter-ahmed-2026.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return web;
      default:
        throw UnsupportedError('Firebase is not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC8OfvbTeHmqz1_2T2r7qcDKxik8_GkhoM',
    appId: '1:552774756925:web:e4a28a77c846fdc6d35854',
    messagingSenderId: '552774756925',
    projectId: 'connect-smarter-ahmed-2026',
    authDomain: 'connect-smarter-ahmed-2026.firebaseapp.com',
    storageBucket: 'connect-smarter-ahmed-2026.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC0mdncouUOfvThghmXstBuuAb_PigOows',
    appId: '1:552774756925:android:dce42e2ab4b0c454d35854',
    messagingSenderId: '552774756925',
    projectId: 'connect-smarter-ahmed-2026',
    storageBucket: 'connect-smarter-ahmed-2026.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA7ekbeptRJya4COKbEwm9Yj4PsO94X2Tw',
    appId: '1:552774756925:ios:9cd14cbb106fcb7ed35854',
    messagingSenderId: '552774756925',
    projectId: 'connect-smarter-ahmed-2026',
    iosBundleId: 'com.example.gradProject',
  );

  static const FirebaseOptions macos = ios;
}
