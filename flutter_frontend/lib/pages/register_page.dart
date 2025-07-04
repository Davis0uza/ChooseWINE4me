// lib/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:dio/dio.dart';

import '../services/api_service.dart';
import 'login_email_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para cada campo
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Controle de visibilidade das senhas
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _isLoading = false;
  String? _errorText;

  // =============================================================
  // LÓGICA DE REGISTRO (mantida igual, apenas adaptada aos novos campos)
  // =============================================================
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final resp = await ApiService.instance.registerUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (resp.statusCode == 201) {
        // 1) Disparo de evento no Analytics
        await FirebaseAnalytics.instance.logEvent(
          name: 'user_registered',
          parameters: {
            'method': 'email',
            'email': _emailController.text.trim(),
          },
        );

        // 2) Após registro bem-sucedido, enviar para LoginEmailPage
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginEmailPage()),
            (_) => false,
          );
        }
      } else {
        // Se retornou erro (< 201), exibe mensagem vinda da API
        setState(() {
          _errorText = resp.data['error'] ?? 'Erro ${resp.statusCode}';
        });
      }
    } on DioException catch (e) {
      // Em caso de falha de rede ou DioException
      setState(() {
        _errorText = e.response?.data['error']?.toString() ?? 'Erro de rede: ${e.message}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  // =============================================================================

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 48),

              // --- LOGOTIPO no topo (mobile) ---
              Image.asset(
                'assets/images/logo-login.png',
                width: size.width * 0.5, // 50% da largura da tela
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 24),

              // --- FORMULÁRIO ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Campo de Nome
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            (value == null || value.isEmpty) ? 'Insere o teu nome' : null,
                      ),

                      const SizedBox(height: 16),

                      // Campo de E-mail
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Insere o teu e-mail';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'E-mail inválido';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Campo de Senha
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Insere uma senha';
                          }
                          if (value.length < 6) {
                            return 'A senha deve ter ao menos 6 caracteres';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Campo de Confirmar Senha
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirmar Senha',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirma a tua senha';
                          }
                          if (value != _passwordController.text) {
                            return 'As senhas não coincidem';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Mensagem de erro (se existir)
                      if (_errorText != null) ...[
                        Text(
                          _errorText!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Botão “Registar” (com indicador de loading)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF69182D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Registar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Link “Já tens conta? Voltar ao login”
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Já tens conta? Voltar ao login',
                          style: TextStyle(
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            color: Color(0xFF69182D),
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
      ),
    );
  }
}
