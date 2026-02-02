import 'package:firebase_auth/firebase_auth.dart';

// อินเตอร์เฟซสำหรับจัดการการยืนยันตัวตน (Repository Interface)
abstract class IAuthRepository {
  Future<UserCredential?> signInWithEmail(String email, String password);
  Future<UserCredential?> signInWithGoogle();
  Future<void> signOut();
  User? get currentUser;
  Stream<User?> get authStateChanges;
}
