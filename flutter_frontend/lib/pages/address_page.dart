// lib/pages/address_page.dart

import 'package:flutter/foundation.dart'; // para kIsWeb
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
      // 1) Recupera o userId do SharedPreferences
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
          // Usuário já tem endereço registo → vai para HomePage
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
            return;
          }
        }
      } else {
        // Se o statusCode não for 200, consideramos erro
        throw Exception('Falha na verificação: ${resp.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted && _error == null) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1) Recupera o mongoUserId via AuthService
      final mongoUserId = await _authService.mongoUserId;
      if (mongoUserId == null) {
        throw Exception('ID de utilizador não encontrado.');
      }

      // 2) Monta o payload e chama o endpoint de criação de endereço
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
        // Se registo deu certo, navega para HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        throw Exception('Resposta inesperada: ${resp.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _countryCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    _postalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size  = MediaQuery.of(context).size;
    final isWeb = kIsWeb;

    // =============================================================
    // 1) Se estiver CHECANDO endereços, exibe Spinner em tela limpa
    // =============================================================
    if (_loading && _error == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // =============================================================
    // 2) Se houve erro na checagem, exibe mensagem centralizada
    // =============================================================
    if (_error != null && _loading == false) {
      return Scaffold(
        body: Center(
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // =============================================================
    // 3) Layout para WEB
    // =============================================================
    if (isWeb) {
      return Scaffold(
        body: Stack(
          children: [
            // 3.1) Imagem de fundo cobrindo 100% da janela
            Positioned.fill(
              child: Image.asset(
                'assets/images/fundo-login.jpg',
                fit: BoxFit.cover,
              ),
            ),

            // 3.2) Card flutuante centralizado contendo logo + título + formulário
            Center(
              child: SingleChildScrollView(
                child: Container(
                  width: 400, // largura fixa do card na web
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- LOGOTIPO ---
                      Image.asset(
                        'assets/images/logo-login.png',
                        width: 200,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: 24),

                      // --- TÍTULO DA PÁGINA ---
                      const Text(
                        'Adicione a Morada',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // --- FORMULÁRIO ---
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _countryCtrl,
                              decoration: const InputDecoration(
                                labelText: 'País',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Informe o país'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _cityCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Cidade',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Informe a cidade'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _addressCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Morada',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Informe a morada'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _postalCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Código Postal',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Informe o código postal'
                                  : null,
                            ),
                            const SizedBox(height: 24),

                            // --- Se houver erro na submissão, exibe aqui ---
                            if (_error != null) ...[
                              Text(
                                _error!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                            ],

                            // --- BOTÃO “Avançar” (loading/desabilitado) ---
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _onSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF52335E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Avançar',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // =============================================================
    // 4) Layout para MOBILE (iOS/Android): logo + formulário (sem fundo)
    // =============================================================
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Registar Morada'),
        backgroundColor: const Color(0xFF52335E),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // --- LOGOTIPO no topo (50% da largura da tela) ---
            Image.asset(
              'assets/images/logo-login.png',
              width: size.width * 0.5,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 24),

            // --- FORMULÁRIO ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _countryCtrl,
                      decoration: const InputDecoration(
                        labelText: 'País',
                        prefixIcon: Icon(Icons.public),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Informe o país'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cityCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Cidade',
                        prefixIcon: Icon(Icons.location_city),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Informe a cidade'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Morada',
                        prefixIcon: Icon(Icons.home),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Informe a morada'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _postalCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Código Postal',
                        prefixIcon: Icon(Icons.local_post_office),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Informe o código postal'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // --- Se houver erro na submissão, exibe aqui ---
                    if (_error != null) ...[
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // --- BOTÃO “Avançar” (loading/desabilitado) ---
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF52335E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Avançar',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
