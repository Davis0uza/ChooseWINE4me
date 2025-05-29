// lib/pages/address_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'home_page.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _countryCtrl = TextEditingController();
  final _cityCtrl    = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _postalCtrl  = TextEditingController();

  bool _loading = false;
  final _authService = AuthService.instance;

  @override
  void dispose() {
    _countryCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    _postalCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final mongoUserId = await _authService.mongoUserId;
      if (mongoUserId == null) {
        throw Exception('ID de utilizador não encontrado.');
      }

      final payload = {
        'userId':  mongoUserId,
        'country': _countryCtrl.text.trim(),
        'city':    _cityCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'postal':  _postalCtrl.text.trim(),
      };

      final resp = await ApiService.instance.createAddress(payload);

      if (!mounted) return;

      if (resp.statusCode == 201) {
        final firebaseUser = FirebaseAuth.instance.currentUser!;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(user: firebaseUser)),
        );
      } else {
        throw Exception('Resposta inesperada: ${resp.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gravar morada: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registar Morada')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _countryCtrl,
                decoration: const InputDecoration(
                  labelText: 'País',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe o país' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityCtrl,
                decoration: const InputDecoration(
                  labelText: 'Cidade',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe a cidade' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Morada',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe a morada' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _postalCtrl,
                decoration: const InputDecoration(
                  labelText: 'Código Postal',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Informe o código postal'
                    : null,
              ),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onSubmit,
                        child: const Text('Avançar'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
