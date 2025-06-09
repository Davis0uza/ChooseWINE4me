// lib/widgets/wineries_dropdown.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../pages/wineries_wines_page.dart';

/// Este widget agora é um Column “inline”:
/// 1) Exibe o botão principal “Vinícolas” (com ícone de taça de vinho).
/// 2) Quando expandido, insere a lista logo abaixo, empurrando o que vier depois.
class CastasDropdownButton extends StatefulWidget {
  const CastasDropdownButton({super.key});

  @override
  State<CastasDropdownButton> createState() => _CastasDropdownButtonState();
}

class _CastasDropdownButtonState extends State<CastasDropdownButton> {
  bool _isExpanded = false;
  late Future<List<String>> _wineriesFuture;

  @override
  void initState() {
    super.initState();
    // Usa getWineries() do seu ApiService (que retorna Future<Response>)
    // e converte em Future<List<String>>.
    _wineriesFuture = ApiService.instance.getWineries().then((resp) {
      if (resp.data is List) {
        return List<String>.from(resp.data as List<dynamic>);
      } else if (resp.data is Map<String, dynamic> &&
                 resp.data['wineries'] is List) {
        return List<String>.from((resp.data['wineries'] as List<dynamic>));
      } else {
        return <String>[];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─────────────────────────────── BOTÃO PRINCIPAL ───────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            icon: const Icon(
              Icons.wine_bar,
              color: Color(0xFF69182D),
              size: 24,
            ),
            label: const Text(
              'Vinícolas',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF69182D),
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF69182D), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              backgroundColor: Colors.transparent,
            ),
          ),
        ),

        // ──────────── AQUI, SE EXPANDIDO, INSERIMOS A LISTA “inline” ────────────
        if (_isExpanded)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            // Limitamos altura para não estourar toda a tela
            constraints: const BoxConstraints(maxHeight: 300),
            child: FutureBuilder<List<String>>(
              future: _wineriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'Erro ao carregar vinícolas',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                } else {
                  final wineries = snapshot.data!;
                  if (wineries.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text('Nenhuma vinícola encontrada'),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: wineries.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final wineryName = wineries[index];
                      return ListTile(
                        title: Text(wineryName),
                        onTap: () {
                          // Ao selecionar, navegamos para a WineriesWinesPage,
                          // usando exatamente os parâmetros obrigatórios.
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WineriesWinesPage(
                                title: 'Vinícola: $wineryName',
                                winery: wineryName,
                              ),
                            ),
                          );
                          // Fecha o dropdown após a navegação
                          setState(() {
                            _isExpanded = false;
                          });
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),

        // Adicionamos espaçamento extra para separar visualmente desta seção se necessário:
        if (_isExpanded) const SizedBox(height: 16),
      ],
    );
  }
}
