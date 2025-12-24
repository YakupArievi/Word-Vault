import 'package:flutter/material.dart';
import 'package:word_vault/views/home/home_page.dart';
import 'package:word_vault/views/home/stats_page.dart';
import 'package:word_vault/views/home/study_center_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Sayfaları liste olarak tutuyoruz
  final List<Widget> _pages = [
    const HomePage(),
    const StudyCenterPage(),
    const StatsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Kelimelerim"),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_fill), label: "Çalış"),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: "İstatistik"),
        ],
      ),
    );
  }
}