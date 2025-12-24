import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_gate.dart'; // AuthGate'i import etmeyi unutma

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Word Vault",
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      // Uygulama açıldığında direkt AuthGate çalışır
      home: const AuthGate(), 
    );
  }
}