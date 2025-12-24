import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth.dart';
import 'auth/login_page.dart';

class AuthWrapper extends StatelessWidget {
  AuthWrapper({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text("HOME PAGE")),
          );
        }

        return const LoginPage();
      },
    );
  }
}
