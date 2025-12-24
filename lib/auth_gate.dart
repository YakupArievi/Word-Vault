import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:word_vault/pages/home_page.dart';
import 'package:word_vault/pages/welcome_page.dart';
import '../services/auth.dart'; 


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Bağlantı bekleniyor (Loading ekranı)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Kullanıcı giriş yapmış mı?
        if (snapshot.hasData && snapshot.data != null) {
          return const HomePage();
        }

        // Giriş yapmamışsa başlangıç ekranına gönder
        return const WelcomePage();
      },
    );
  }
}