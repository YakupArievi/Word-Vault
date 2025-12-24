import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/word_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  // Kelime Ekleme
  Future<void> addWord({required String word, required String translation, String? sentence}) async {
    await _db.collection('users').doc(_userId).collection('words').add({
      'targetWord': word,
      'translation': translation,
      'sentence': sentence,
      'isLearned': false,
      'correctCount': 0,
      'lastReview': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Kelimeleri Getirme
  Stream<List<WordModel>> getWords() {
    return _db.collection('users').doc(_userId).collection('words')
        .orderBy('createdAt', descending: true)
        .snapshots().map((snapshot) => snapshot.docs
        .map((doc) => WordModel.fromMap(doc.data(), doc.id)).toList());
  }

  // 🔹 DOĞRU BİLİNDİĞİNDE: Seviyeyi artır
  Future<void> markAsCorrect(String docId, int currentLevel) async {
    int nextLevel = currentLevel + 1;
    bool learned = nextLevel >= 3; // 3. seviyeye ulaşan "Öğrenildi" sayılır

    await _db.collection('users').doc(_userId).collection('words').doc(docId).update({
      'level': nextLevel,
      'correctCount': nextLevel, // UI'daki daire için
      'isLearned': learned,
      'lastReview': FieldValue.serverTimestamp(),
    });
  }

  // 🔹 HATA YAPILDIĞINDA: Seviyeyi 1'e düşür (Hemen yarın sorması için)
  Future<void> markAsWrong(String docId) async {
    await _db.collection('users').doc(_userId).collection('words').doc(docId).update({
      'level': 0, // 0'a çekiyoruz ki 1 gün sonra (yarın) tekrar sorsun
      'correctCount': 0,
      'isLearned': false,
      'lastReview': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteWord(String docId) async => 
      await _db.collection('users').doc(_userId).collection('words').doc(docId).delete();
}