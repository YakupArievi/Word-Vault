import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';

const Color primaryOrange = Color(0xFFFFA726);

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFCC80), // soft açık turuncu
              Color(0xFFFFA726), // ana turuncu
              Color(0xFFF57C00), // koyu vurgu
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// 🔥 LOGO + ANİMASYON
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Column(
                children: const [
                  Icon(
                    Icons.book_rounded,
                    size: 90,
                    color: Colors.white,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Word Vault",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 70),

            _button(
              text: "Login",
              filled: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ),
            ),

            const SizedBox(height: 16),

            _button(
              text: "Register Now",
              filled: false,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _button({
    required String text,
    required VoidCallback onTap,
    required bool filled,
  }) {
    return SizedBox(
      width: 260,
      height: 48,
      child: filled
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
              ),
              onPressed: onTap,
              child: Text(
                text,
                style: const TextStyle(fontSize: 16),
              ),
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onTap,
              child: Text(
                text,
                style: const TextStyle(fontSize: 16),
              ),
            ),
    );
  }
}
