import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:word_vault/services/auth.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false; // 🔹 Giriş işlemi sırasında butonun durumunu kontrol eder

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade400,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Word",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Vault",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : () async {
                      if (_emailController.text.isEmpty) return;
                      await _authService.resetPassword(_emailController.text.trim());
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Şifre sıfırlama maili gönderildi")),
                        );
                      }
                    },
                    child: const Text(
                      "Şifremi Unuttum?",
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : () async {
                      setState(() => _isLoading = true); // 🔹 Yükleniyor animasyonunu başlat
                      try {
                        // 🔹 Login işlemi
                        await _authService.signIn(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                        );

                        // 🔹 ÖNEMLİ: Giriş başarılı olduğunda StreamBuilder (AuthGate) 
                        // otomatik tetiklenecek. Ancak LoginPage stack'te (üstte) kaldığı için 
                        // onu kapatıp kök dizine (AuthGate'e) dönmemiz gerekir.
                        if (context.mounted) {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        }

                      } on FirebaseAuthException catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.message ?? "Giriş hatası")),
                        );
                      } finally {
                        if (mounted) setState(() => _isLoading = false); // 🔹 Yükleniyor bitir
                      }
                    },
                    child: _isLoading 
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text("Login", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Register",
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}