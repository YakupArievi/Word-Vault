import 'package:flutter/material.dart';
import 'package:word_vault/services/auth.dart';
import 'package:word_vault/services/firestore_service.dart';
import 'package:word_vault/models/word_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  String _searchQuery = "";
  
  // Filtreleme Durumu: 
  // 0: Hepsi, 1: Öğrenilecekler, 2: Öğrenilenler, 3: En Çok Hata Yaptıklarım
  int _filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Word Vault", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Arama Çubuğu
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Kelime ara...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),

          // 🚥 Filtreleme Butonları (Yatay Kaydırılabilir)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _buildFilterChip(0, "Hepsi", Icons.all_inclusive),
                const SizedBox(width: 8),
                _buildFilterChip(1, "Öğrenilecek", Icons.pending_actions),
                const SizedBox(width: 8),
                _buildFilterChip(2, "Öğrenilen", Icons.check_circle),
                const SizedBox(width: 8),
                _buildFilterChip(3, "Zorlandıklarım", Icons.warning_amber_rounded),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 📚 Kelime Listesi
          Expanded(
            child: StreamBuilder<List<WordModel>>(
              stream: _firestoreService.getWords(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Henüz kelime eklemedin."));
                }

                // 🔥 Filtreleme Mantığı
                final words = snapshot.data!.where((w) {
                  // Arama sorgusu kontrolü
                  bool matchesSearch = w.targetWord.toLowerCase().contains(_searchQuery) ||
                                      w.translation.toLowerCase().contains(_searchQuery);
                  
                  // Kategori filtresi kontrolü
                  bool matchesCategory = true;
                  if (_filterIndex == 1) {
                    matchesCategory = w.level < 3;
                  } else if (_filterIndex == 2) {
                    matchesCategory = w.level >= 3;
                  } else if (_filterIndex == 3) {
                    // Level'ı 0 olan ve en az bir kere çalışılmış olanlar (Hata yapılmış demektir)
                    matchesCategory = w.level == 0 && w.lastReview != null;
                  }

                  return matchesSearch && matchesCategory;
                }).toList();

                if (words.isEmpty) {
                  return const Center(child: Text("Sonuç bulunamadı."));
                }

                return ListView.builder(
                  itemCount: words.length,
                  itemBuilder: (context, index) {
                    final word = words[index];
                    bool isMastered = word.level >= 3;
                    bool isStruggling = word.level == 0 && word.lastReview != null;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: isMastered ? 0 : 2,
                      color: isStruggling ? Colors.red.shade50 : Colors.white,
                      child: ExpansionTile(
                        leading: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: word.level / 3, 
                              strokeWidth: 4,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isMastered ? Colors.green : (isStruggling ? Colors.red : Colors.orange),
                              ),
                            ),
                            Text("${word.level}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        title: Text(
                          word.targetWord,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: isMastered ? TextDecoration.lineThrough : null,
                            color: isMastered ? Colors.green.shade700 : (isStruggling ? Colors.red.shade900 : Colors.black),
                          ),
                        ),
                        subtitle: Text(word.translation),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                          onPressed: () => _showDeleteDialog(context, word.id),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(),
                                Row(
                                  children: [
                                    const Icon(Icons.lightbulb_outline, size: 18, color: Colors.orange),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text("Cümle: ${word.sentence ?? 'Örnek cümle yok.'}")),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.history, size: 18, color: Colors.blueGrey),
                                    const SizedBox(width: 8),
                                    Text(
                                      word.lastReview == null 
                                      ? "Henüz çalışılmadı" 
                                      : "Son Tekrar: ${word.lastReview!.day}.${word.lastReview!.month}.${word.lastReview!.year}",
                                      style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () => _showAddWordSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- Yardımcı Widgetlar ve Fonksiyonlar ---

  Widget _buildFilterChip(int index, String label, IconData icon) {
    bool isSelected = _filterIndex == index;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.orange),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      selectedColor: Colors.orange,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      backgroundColor: Colors.grey.shade200,
      onSelected: (bool selected) {
        setState(() => _filterIndex = index);
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Kelimeyi Sil"),
        content: const Text("Bu kelime hazinenizden kalıcı olarak silinecek."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
          TextButton(
            onPressed: () {
              _firestoreService.deleteWord(docId);
              Navigator.pop(context);
            },
            child: const Text("SİL", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddWordSheet(BuildContext context) {
    final wordController = TextEditingController();
    final meanController = TextEditingController();
    final sentenceController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20, right: 20, top: 20
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Yeni Kelime Ekle", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(controller: wordController, decoration: const InputDecoration(labelText: "İngilizce", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: meanController, decoration: const InputDecoration(labelText: "Türkçe", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: sentenceController, decoration: const InputDecoration(labelText: "Örnek Cümle (Opsiyonel)", border: OutlineInputBorder())),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 50)
              ),
              onPressed: () {
                if (wordController.text.isNotEmpty && meanController.text.isNotEmpty) {
                  _firestoreService.addWord(
                    word: wordController.text.trim(),
                    translation: meanController.text.trim(),
                    sentence: sentenceController.text.trim().isEmpty ? null : sentenceController.text.trim(),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("KAYDET", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}