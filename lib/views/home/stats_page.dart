import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/word_model.dart';
import '../../services/firestore_service.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("İlerlemem", style: TextStyle(fontWeight: FontWeight.bold)),
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
            return const Center(child: Text("Veri bulunamadı. Önce kelime ekle!"));
          }

          final words = snapshot.data!;
          // Seviyelere göre sayıları hesapla
          int lvl0 = words.where((w) => w.level == 0).length;
          int lvl1 = words.where((w) => w.level == 1).length;
          int lvl2 = words.where((w) => w.level == 2).length;
          int lvl3Plus = words.where((w) => w.level >= 3).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  "Kelime Dağılımı",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 30),
                
                // 🔹 Pasta Grafiği
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        _section(lvl0.toDouble(), "Yeni", Colors.grey),
                        _section(lvl1.toDouble(), "Lvl 1", Colors.orange),
                        _section(lvl2.toDouble(), "Lvl 2", Colors.blue),
                        _section(lvl3Plus.toDouble(), "Lvl 3+", Colors.green),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // 🔹 Detay Kartları
                _buildInfoCard("Yeni Kelimeler", lvl0, Colors.grey, "Henüz çalışılmadı"),
                _buildInfoCard("Seviye 1", lvl1, Colors.orange, "Yarın tekrar edilecek"),
                _buildInfoCard("Seviye 2", lvl2, Colors.blue, "3 gün sonra tekrar"),
                _buildInfoCard("Öğrenildi", lvl3Plus, Colors.green, "Hafızaya alındı!"),
                
                const SizedBox(height: 30),
                Divider(),
                Text(
                  "Toplam Hazine: ${words.length} Kelime",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  PieChartSectionData _section(double value, String title, Color color) {
    return PieChartSectionData(
      value: value == 0 ? 0.1 : value, // Değer 0 ise çok ince bir çizgi göster
      title: value > 0 ? title : "",
      color: color,
      radius: 60,
      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildInfoCard(String title, int count, Color color, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, radius: 15),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Text(
          count.toString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}