import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'package:motus_lab/core/config/app_secrets.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isWindows) {
      return windows;
    }
    // Android is handled automatically by google-services.json
    throw UnsupportedError(
      'DefaultFirebaseOptions are not configured for this platform.',
    );
  }

  static final FirebaseOptions windows = FirebaseOptions(
    apiKey: AppSecrets.firebaseApiKey,
    appId: AppSecrets.firebaseAppId,
    messagingSenderId: AppSecrets.firebaseMessagingSenderId,
    projectId: AppSecrets.firebaseProjectId,
    authDomain: AppSecrets.firebaseAuthDomain,
    storageBucket: AppSecrets.firebaseStorageBucket,
  );
}
