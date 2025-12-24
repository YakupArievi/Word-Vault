import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔹 auth state stream (HATA BURADAYDI)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// 🔹 Login
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// 🔹 Register
  Future<void> register({
    required String email,
    required String password,
  }) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// 🔹 Şifremi unuttum
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// 🔹 Çıkış
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
