import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:word_vault/views/home/main_screen.dart'; // Burası MainScreen olmalı
import 'package:word_vault/views/auth/welcome_page.dart';
import 'package:word_vault/services/auth.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData && snapshot.data != null) {
          // Giriş yapılmışsa navigasyonlu ana ekrana git
          return const MainScreen(); 
        }

        return const WelcomePage();
      },
    );
  }
}