import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/word_model.dart';
import '../../services/firestore_service.dart';

class FlashcardPage extends StatefulWidget {
  final List<WordModel> words;
  const FlashcardPage({super.key, required this.words});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  int _currentIndex = 0;
  bool _isFront = true;
  bool _isAnswered = false;
  bool _isCorrect = false; // Kullanıcının bilip bilmediğini tutar
  final TextEditingController _answerController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  void _checkAnswer(String correctAnswer) async {
    if (_answerController.text.trim().isEmpty) return;

    String userAnswer = _answerController.text.trim().toLowerCase();
    String target = correctAnswer.trim().toLowerCase();
    final word = widget.words[_currentIndex];

    bool isRight = userAnswer == target;

    setState(() {
      _isAnswered = true;
      _isCorrect = isRight;
      _isFront = false; // Cevap sonrası kartı otomatik çevir
    });

    if (isRight) {
      // Doğru bildi: Puan artır ve zaman damgası ekle
      await _firestoreService.markAsCorrect(word.id, word.correctCount);
    } else {
      // Yanlış bildi: Puanı sıfırla
      await _firestoreService.markAsWrong(word.id);
    }
  }

  void _nextCard() {
    if (_currentIndex < widget.words.length - 1) {
      setState(() {
        _currentIndex++;
        _isFront = true;
        _isAnswered = false;
        _isCorrect = false;
        _answerController.clear();
      });
    } else {
      // Kelimeler bittiğinde ana sayfaya dönmeden önce bir tebrik gösterilebilir
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.words[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Yaz ve Öğren (${_currentIndex + 1}/${widget.words.length})"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              // 🔹 3D Animasyonlu Kart
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final rotate = Tween(begin: pi, end: 0.0).animate(animation);
                  return AnimatedBuilder(
                    animation: rotate,
                    child: child,
                    builder: (context, child) {
                      final isUnder = (ValueKey(_isFront) != child!.key);
                      final value = isUnder ? min(rotate.value, pi / 2) : rotate.value;
                      return Transform(
                        transform: Matrix4.rotationY(value),
                        alignment: Alignment.center,
                        child: child,
                      );
                    },
                  );
                },
                child: _isFront 
                  ? _buildFrontCard(word.translation) 
                  : _buildBackCard(word.targetWord, word.sentence ?? "Örnek cümle eklenmemiş."),
              ),
              
              const SizedBox(height: 40),

              // 🔹 Giriş Alanı ve Etkileşim
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    if (!_isAnswered) ...[
                      TextField(
                        controller: _answerController,
                        autofocus: true,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: "İngilizcesini yazın...",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.orange, width: 2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onSubmitted: (value) => _checkAnswer(word.targetWord),
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 4,
                        ),
                        onPressed: () => _checkAnswer(word.targetWord),
                        child: const Text("KONTROL ET", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ] else ...[
                      // Cevap verildikten sonra çıkan buton
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isCorrect ? Colors.green : Colors.redAccent,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: _nextCard,
                        icon: const Icon(Icons.arrow_forward, color: Colors.white),
                        label: Text(
                          _currentIndex < widget.words.length - 1 ? "SONRAKİ KELİME" : "TESTİ BİTİR",
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Kartın Ön Yüzü (Soru: Türkçe Anlam)
  Widget _buildFrontCard(String text) {
    return Container(
      key: const ValueKey(true),
      width: 320, height: 220,
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.orange.shade200, width: 3),
        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
      ),
      child: Center(
        child: Text(text, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange), textAlign: TextAlign.center),
      ),
    );
  }

  // 🔹 Kartın Arka Yüzü (Cevap: İngilizce Kelime + Cümle)
  Widget _buildBackCard(String title, String sentence) {
    return Container(
      key: const ValueKey(false),
      width: 320, height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: _isCorrect ? Colors.green : Colors.red, width: 3),
        boxShadow: [BoxShadow(color: (_isCorrect ? Colors.green : Colors.red).withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_isCorrect ? Icons.check_circle : Icons.cancel, color: _isCorrect ? Colors.green : Colors.red, size: 40),
          const SizedBox(height: 10),
          Text(title, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _isCorrect ? Colors.green : Colors.red)),
          const Divider(indent: 50, endIndent: 50, height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(sentence, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black54, fontSize: 16), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}