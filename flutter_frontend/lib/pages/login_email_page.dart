import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../services/api_service.dart';
import 'package:dio/dio.dart';

class LoginEmailPage extends StatefulWidget {
  const LoginEmailPage({super.key});
  @override
  State<LoginEmailPage> createState() => _LoginEmailPageState();
}

class _LoginEmailPageState extends State<LoginEmailPage> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading       = false;
  String? _errorText;

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) return;

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      final resp = await ApiService.instance.loginWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      // Se tiveres sucesso…
      if (resp.statusCode == 200) {
        // 1) Evento Analytics
        await FirebaseAnalytics.instance.logEvent(
          name: 'login_email',
          parameters: {'method': 'email'},
        );
        // 2) Navega para AuthGate ('/')
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/');
        }
      } else {
        setState(() {
          _errorText = resp.data['error'] ?? 'Falha ao autenticar';
        });
      }
    } on DioException catch (e) {
      setState(() {
        _errorText = e.response?.data['error']?.toString()
            ?? 'Erro de rede: ${e.message}';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar com E-mail')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(_errorText!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Entrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
