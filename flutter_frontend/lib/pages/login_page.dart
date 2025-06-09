import 'package:flutter/foundation.dart'; // para usar kIsWeb
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'address_page.dart';

// Importações das páginas de login por e-mail e registro:
import 'login_email_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loading = false;
  String? _error;

  Future<void> _handleSignIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });

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
    // Tamanho da tela (para o layout mobile)
    final size = MediaQuery.of(context).size;
    // Detecta se estamos em Web
    final isWeb = kIsWeb;

    // ------------------------------------------------------
    // LAYOUT PARA WEB
    // ------------------------------------------------------
    if (isWeb) {
      // Definimos aqui a largura fixa que será usada para ambos os botões
      const double buttonWidth = 240;

      return Scaffold(
        body: Stack(
          children: [
            // Fundo cobrindo toda a tela
            Positioned.fill(
              child: Image.asset(
                'assets/images/fundo-login.jpg',
                fit: BoxFit.cover,
              ),
            ),

            // Card flutuante centralizado
            Center(
              child: SingleChildScrollView(
                child: Container(
                  width: 400, // Largura do card na Web
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
                      // === LOGOTIPO ===
                      Image.asset(
                        'assets/images/logo-login.png',
                        width: 200,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: 24),

                      // === ERRO (se houver) ===
                      if (_error != null) ...[
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // === BOTÃO “Continue with Google” OFICIAL ===
                      if (_loading)
                        SizedBox(
                          width: buttonWidth,
                          height: 50,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        Center(
                          child: GestureDetector(
                            onTap: _handleSignIn,
                            child: Image.asset(
                              'assets/images/web_light_sq_ctn@2x.png',
                              width: buttonWidth,
                              height: 50,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // === BOTÃO “Entrar com e-mail” ===
                      Center(
                        child: SizedBox(
                          width: buttonWidth,
                          height: 50,
                          child: OutlinedButton.icon(
                            icon: const Icon(
                              Icons.email,
                              color: Color(0xFF69182D),
                            ),
                            label: const Text(
                              'Entrar com e-mail',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF69182D),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginEmailPage(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFF69182D)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // === TEXTO “registre-se agora” ===
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Não tem conta? ',
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'registre-se agora',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF69182D),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
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

     // ------------------------------------------------------
      // LAYOUT PARA MOBILE (iOS/Android) COM BOTÃO “Continuar com Google” A LA EMAIL
      // ------------------------------------------------------
      final double buttonWidthMobile = size.width * 0.5;

      return Scaffold(
        // Remova o backgroundColor para não cobrir a imagem de fundo
        body: Stack(
          children: [
            // 1) IMAGEM DE FUNDO FULLSCREEN
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/fundo-login.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // 2) CONTEÚDO ANCORADO NA PARTE INFERIOR
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // === LOGOTIPO ===
                  Image.asset(
                    'assets/images/logo-login.png',
                    width: size.width * 0.5,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 24),

                  // === ÁREA COM ERRO + BOTÕES + LINK DE REGISTRO ===
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Mensagem de erro (se existir)
                        if (_error != null) ...[
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // === BOTÃO “Continuar com Google” ===
                        if (_loading)
                          SizedBox(
                            width: buttonWidthMobile,
                            height: 50,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else
                          Center(
                            child: SizedBox(
                              width: buttonWidthMobile,
                              height: 50,
                              child: OutlinedButton.icon(
                                // Ícone do Google à esquerda (ajuste o path do asset se necessário)
                                icon: Image.asset(
                                  'assets/images/web_light_sq_ctn@2x.png',
                                  width: 28,
                                  height: 28,
                                ),
                                label: const Text(
                                  'Continuar com Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () async {
                                  await _handleSignIn();
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Color(0xFF69182D),
                                  side: const BorderSide(color: Color(0xFF69182D)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // === BOTÃO “Entrar com e-mail” ===
                        Center(
                          child: SizedBox(
                            width: buttonWidthMobile,
                            height: 50,
                            child: OutlinedButton.icon(
                              icon: const Icon(
                                Icons.email,
                                color: Color(0xFF69182D),
                              ),
                              label: const Text(
                                'Entrar com e-mail',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF69182D),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginEmailPage(),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                side: const BorderSide(color: Color(0xFF69182D)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // === TEXTO “Não tem conta? Registre-se agora” ===
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Novo por aqui? ',
                              style: TextStyle(fontSize: 14, color: Colors.white),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Crie a sua conta',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  }
}
