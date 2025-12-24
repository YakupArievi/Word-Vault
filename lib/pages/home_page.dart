import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:word_vault/services/auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    // 🔹 Mevcut kullanıcının bilgilerini alalım
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Word Vault", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.orange,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Çıkış Yap",
            onPressed: () async {
              await authService.signOut();
              // AuthGate otomatik olarak bizi WelcomePage'e atacaktır.
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Hoş geldin 👋", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300)),
            const SizedBox(height: 8),
            // 🔹 Kullanıcının emailini gösteriyoruz
            Text(
              user?.email ?? "Kullanıcı adı bulunamadı",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            const SizedBox(height: 40),
            const Icon(Icons.menu_book_rounded, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            const Text("Kelime hazineni geliştirmeye başla!"),
          ],
        ),
      ),
    );
  }
}