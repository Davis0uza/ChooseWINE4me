import 'package:flutter/foundation.dart'; // para kIsWeb
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../services/api_service.dart';
import 'package:dio/dio.dart';

// Importa a sua AddressPage:
import 'address_page.dart';

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

  // === MANTIVEMOS A LÓGICA DE LOGIN exata daqui, mas corrigimos a navegação final ===
  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) return;

    setState(() {
      _loading   = true;
      _errorText = null;
    });

    try {
      final resp = await ApiService.instance.loginWithEmail(
        email:    _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      if (resp.statusCode == 200) {
        // Evento no Analytics
        await FirebaseAnalytics.instance.logEvent(
          name: 'login_email',
          parameters: {'method': 'email'},
        );
        // Aqui mudamos para navegar PARA A AddressPage, removendo todas as rotas anteriores:
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AddressPage()),
            (_) => false,
          );
        }
      } else {
        // Exibe mensagem de erro retornada pela API (ou genérica)
        setState(() {
          _errorText = resp.data['error'] ?? 'Falha ao autenticar';
        });
      }
    } on DioException catch (e) {
      // Caso ocorra erro de rede / Dio
      setState(() {
        _errorText = e.response?.data['error']?.toString()
            ?? 'Erro de rede: ${e.message}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }
  // =============================================================================

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size  = MediaQuery.of(context).size;
    final isWeb = kIsWeb;

    // =============================================================
    // 1) LAYOUT PARA WEB: fundo + card centralizado
    // =============================================================
    if (isWeb) {
      return Scaffold(
        body: Stack(
          children: [
            // Imagem de fundo cobrindo toda a janela
            Positioned.fill(
              child: Image.asset(
                'assets/images/fundo-login.jpg',
                fit: BoxFit.cover,
              ),
            ),

            // Card branco semitransparente centralizado
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

                      // --- CAMPO DE E-MAIL ---
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Color(0xFF52335E),
                          ),
                          labelText: 'E-mail',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // --- CAMPO DE SENHA ---
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Color(0xFF52335E),
                          ),
                          labelText: 'Senha',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // --- TEXTO DE ERRO (se houver) ---
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

                      // --- BOTÃO “Entrar” COM LOADING ---
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
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
                                  'Entrar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // --- LINK PARA VOLTAR AO LOGIN PRINCIPAL ---
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          '← Voltar ao login',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF52335E),
                            decoration: TextDecoration.underline,
                          ),
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
    // 2) LAYOUT PARA MOBILE (iOS/Android): topo com fundo + form
    // =============================================================
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Fundo no topo (50% da altura) ---
            Container(
              width: double.infinity,
              height: size.height * 0.5,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/fundo-login.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- Logotipo abaixo do fundo ---
            Image.asset(
              'assets/images/logo-login.png',
              width: size.width * 0.5, // 50% da largura da tela
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 24),

            // --- Formulário de E-mail/Senha ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // E-mail
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.email,
                        color: Color(0xFF52335E),
                      ),
                      labelText: 'E-mail',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Senha
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Color(0xFF52335E),
                      ),
                      labelText: 'Senha',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Texto de erro (se houver)
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

                  // Botão “Entrar”
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
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
                              'Entrar',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Link “Voltar ao login” (pop)
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      '← Voltar ao login',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF52335E),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
