// lib/pages/address_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'home_page.dart';
import '../services/auth_service.dart';

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

  final _authService = AuthService.instance;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkAddresses();
  }

  Future<void> _checkAddresses() async {
    try {
      // 1) Recupera o userId diretamente do SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('mongo_user_id');
      if (userId == null) {
        throw Exception('Usuário não identificado.');
      }

      // 2) Chama o endpoint de busca de endereços
      final resp = await ApiService.instance.fetchAddresses(userId);
      if (resp.statusCode == 200) {
        final addresses = resp.data as List<dynamic>;
        if (addresses.isNotEmpty) {
          // Usuário já tem endereço cadastrado → vai para HomePage
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          }
          return;
        }
      } else {
        throw Exception('Erro ao buscar endereços: ${resp.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
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
    // Enquanto verifica endereços, mostra spinner
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Se ocorreu erro, mostra mensagem
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    // Nenhum endereço cadastrado: exibe o formulário
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Endereço')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
