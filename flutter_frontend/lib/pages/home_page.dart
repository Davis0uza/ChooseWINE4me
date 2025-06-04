import 'package:flutter/material.dart';
import 'wine_list_page.dart';
import '../widgets/custom_navbar.dart';
import '../widgets/wineries_dropdown.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Para que o body “se estenda por baixo” da AppBar, de modo
      // que o fundo inicie já no topo do dispositivo:
      extendBodyBehindAppBar: true,
      // Substituímos a AppBar pelo CustomNavBar, mas precisamos
      // que ele fique transparente para vermos a imagem por trás:
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          color: Colors.transparent, // fundo transparente
          child: const CustomNavBar(),
        ),
      ),

      body: Stack(
        children: [
          // 1) Container com imagem de fundo ocupando 30% da altura TOTAL
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: size.height * 0.30,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/fundo-login.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // 2) Conteúdo principal abaixo (empurra a Column inteira para baixo
          //    na mesma proporção de 30% para que não fique por trás da AppBar
          //    nem sobreponha a parte do fundo que não deve ser coberta).
          Column(
            children: [
              // Criamos um espaçamento fixo de 30% para “sair” debaixo da imagem:
              SizedBox(height: size.height * 0.30),
              // A partir daqui, o restante dos widgets ocupa os 70% restantes:
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),

                      // ─────────── WineriesDropdown ───────────
                      // Mantemos exatamente o mesmo widget que você já tinha
                      const CastasDropdownButton(),

                      const SizedBox(height: 32),

                      // ───────────── Botões ─────────────

                      // 2.1) BOTÃO “Explorar” — contorno roxo, fundo transparente
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WineListPage(
                                  title: 'Explorar',
                                  fetchMethod: 'explore',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.explore,
                            color: Color(0xFF52335E),
                            size: 24,
                          ),
                          label: const Text(
                            'Explorar',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF52335E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF52335E),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 2.2) BOTÃO “Recomendados (para mim)” — fundo roxo, texto branco
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WineListPage(
                                  title: 'Recomendados (para mim)',
                                  fetchMethod: 'recommend_for_me',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.local_bar,
                            color: Colors.white, // ícone branco sobre fundo roxo
                            size: 24,
                          ),
                          label: const Text(
                            'Recomendados (para mim)',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white, // texto branco
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF52335E),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor: const Color(0xFF52335E),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Se precisar de mais botões, basta seguir o padrão acima.

                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
