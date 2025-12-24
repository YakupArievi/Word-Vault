import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:word_vault/auth_gate.dart';
import 'package:word_vault/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    
    // Bildirim Servisi Başlatma
    final notifyService = NotificationService();
    await notifyService.init();
    
    // Hatırlatıcıyı kur (Hata olursa catch bloğuna düşer ama uygulama kapanmaz)
    await notifyService.scheduleDailyQuizReminder(20, 0);
  } catch (e) {
    debugPrint("Başlatma sırasında hata oluştu: $e");
  }
  
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const AuthGate(), 
    );
  }
}