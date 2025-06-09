// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'wine_list_page.dart';
import '../widgets/custom_navbar.dart';
import '../widgets/wineries_dropdown.dart';
// 1) Importa o WineFilterWidget
import '../widgets/wine_filter_widget.dart';
import 'filter_results_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Para que o body “se estenda por baixo” da AppBar (ver imagem de fundo):
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          color: Colors.transparent, // fundo transparente
          child: const CustomNavBar(),
        ),
      ),

      body: Stack(
        children: [
          // 1) Fundo ocupando 30% da altura total
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: size.height * 0.30,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/fundo-home.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // 2) Espaço de 30% (para não ficar sobre o fundo) + conteúdo principal
          Column(
            children: [
              // Espaço fixo de 30%
              SizedBox(height: size.height * 0.30),

              // 3) Conteúdo principal (70% restante) agora é rolável
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  // ——> Aqui substituímos:
                  //     child: Column( ... )
                  //     por:
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),

                        // ─── 3.1) WINE FILTER WIDGET (INCLUSÃO) ───────────────────
                        // Inserimos o WineFilterWidget antes do dropdown de castas.
                        WineFilterWidget(
                          onSearch: ({
                            required double minPrice,
                            required double maxPrice,
                            required double minRating,
                            required double maxRating,
                            String? wineType,
                          }) {
                            // Ao pressionar “Pesquisar” dentro do filtro,
                            // navegamos para a FilterResultsPage
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => FilterResultsPage(
                                  minPrice: minPrice,
                                  maxPrice: maxPrice,
                                  minRating: minRating,
                                  maxRating: maxRating,
                                  wineType: wineType,
                                ),
                              ),
                            );
                          },
                          // Você pode ajustar valores iniciais se desejar:
                          initialMinPrice: 0,
                          initialMaxPrice: 150,
                          initialMinRating: 1,
                          initialMaxRating: 5,
                          initialWineType: null,
                        ),

                        const SizedBox(height: 16),

                        // ─── 3.4) BOTÃO “Recomendados (para mim)” (original) ───────
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
                                    fetchMethod: 'recommend',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.local_bar,
                              color: Colors.white,
                              size: 24,
                            ),
                            label: const Text(
                              'Recomendados (para mim)',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFF69182D),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: const Color(0xFF69182D),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ─── 3.3) BOTÃO “Explorar” (igual ao original) ─────────────
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
                                    fetchMethod: 'getAllWines',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.explore,
                              color: Color(0xFF69182D),
                              size: 24,
                            ),
                            label: const Text(
                              'Explorar',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF69182D),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFF69182D),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        
                        // ─── 3.2) DROPDOWN DE CASTAS (MANTIDO COMO ESTAVA) ──────────
                        const CastasDropdownButton(),

                        

                        const SizedBox(height: 16),

                        // Se houver outros botões ou seções, basta replicar o padrão:
                        // const SizedBox(height: 16),
                        // OutroWidget(),
                        // ...

                        // ─── 3.5) “Espaço de segurança” para manter scroll fluido ─────
                        const SizedBox(height: 24),
                      ],
                    ),
                  ), // fim SingleChildScrollView
                ),
              ), // fim Expanded
            ],
          ), // fim Column principal
        ],
      ),
    );
  }
}
