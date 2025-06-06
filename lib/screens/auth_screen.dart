import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/cloud_sync_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isSignUp) {
        await AuthService.instance.createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
        // Auto sync after successful registration
        await CloudSyncService.instance.syncToCloud();
      } else {
        await AuthService.instance.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
        // Auto sync after successful login
        await CloudSyncService.instance.syncFromCloud();
      }

      if (mounted) {
        Navigator.of(context).pop(true); // Return success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Şifre sıfırlamak için e-posta adresini girin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    try {
      await AuthService.instance
          .sendPasswordResetEmail(_emailController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Şifre sıfırlama e-postası gönderildi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? 'Hesap Oluştur' : 'Giriş Yap'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cloud,
                  size: 80,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 24),
                Text(
                  'Bulut Senkronizasyonu',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Verilerinizi güvenle saklayın ve cihazlar arası senkronize edin',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  key: const Key('email_field'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-posta',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'E-posta adresi gereklidir';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Geçerli bir e-posta adresi girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('password_field'),
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şifre gereklidir';
                    }
                    if (_isSignUp && value.length < 6) {
                      return 'Şifre en az 6 karakter olmalıdır';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_isSignUp ? 'Hesap Oluştur' : 'Giriş Yap'),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                        });
                      },
                      child: Text(
                          _isSignUp ? 'Zaten hesabım var' : 'Hesap oluştur'),
                    ),
                    if (!_isSignUp)
                      TextButton(
                        onPressed: _resetPassword,
                        child: const Text('Şifremi unuttum'),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              'Bulut Senkronizasyonu Hakkında',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Profillerinizi güvenle bulutta saklayın\n'
                          '• Cihazlar arası otomatik senkronizasyon\n'
                          '• Veri kaybına karşı koruma\n'
                          '• İsteğe bağlı hizmet - çevrimdışı da çalışır',
                          style: TextStyle(color: Colors.blue.shade700),
                        ),
                      ],
                    ),
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
