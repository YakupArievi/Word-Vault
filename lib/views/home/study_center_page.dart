import 'package:flutter/material.dart';
import 'package:word_vault/services/firestore_service.dart';
import 'package:word_vault/models/word_model.dart';
import 'package:word_vault/views/home/flashcard_page.dart';

class StudyCenterPage extends StatelessWidget {
  const StudyCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Çalışma Merkezi"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: StreamBuilder<List<WordModel>>(
        stream: firestoreService.getWords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Henüz kelime eklemediniz."));
          }

          // 🔥 SENİN KRİTİK FİLTRELEME MANTIĞIN - HİÇBİR ŞEYİ BOZMADIK
          final studyList = snapshot.data!.where((w) {
            if (w.level == 0) return true;
            if (w.lastReview == null) return true;
            final diff = DateTime.now().difference(w.lastReview!);
            if (w.level == 1) return diff.inDays >= 1;
            if (w.level == 2) return diff.inDays >= 3;
            if (w.level >= 3) return diff.inDays >= 7;
            return false;
          }).toList();

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  studyList.isEmpty ? Icons.verified : Icons.rocket_launch,
                  size: 100,
                  color: Colors.orange,
                ),
                const SizedBox(height: 20),
                Text(
                  studyList.isEmpty ? "Harika! Bugün Bitti" : "Öğrenme Zamanı",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  studyList.isEmpty 
                      ? "Tüm tekrarlarını başarıyla tamamladın." 
                      : "Bugün çalışman gereken ${studyList.length} kelime var.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: studyList.isEmpty ? null : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlashcardPage(words: studyList),
                      ),
                    );
                  },
                  child: const Text(
                    "ÇALIŞMAYA BAŞLA", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}