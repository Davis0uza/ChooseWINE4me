import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'address_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loading = false;
  String? _error;

  Future<void> _handleSignIn() async {
    setState(() { _loading = true; _error = null; });
    try {
      final user = await AuthService.instance.signInWithGoogle();
      if (user != null && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AddressPage()),
          (_) => false,
        );
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
            ],
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: Text(_loading ? 'Entrando...' : 'Entrar com Google'),
              onPressed: _loading ? null : _handleSignIn,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.email),
              label: const Text('Entrar com e-mail'),
              onPressed: () {
                // seu fluxo de e-mail…
              },
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
            TextButton(
              onPressed: () {
                // seu fluxo de registro…
              },
              child: const Text('registre-se agora'),
            ),
          ],
        ),
      ),
    );
  }
}
