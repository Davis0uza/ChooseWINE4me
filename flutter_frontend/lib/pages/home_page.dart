import 'package:flutter/material.dart';
import 'wine_list_page.dart';
import '../widgets/custom_navbar.dart';
import '../widgets/wineries_dropdown.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNavBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dropdown de Castas (Wineries)
            const CastasDropdownButton(),
            const SizedBox(height: 16),
            // Botão Explorar padrão (Todos os Vinhos)
            ElevatedButton.icon(
              icon: const Icon(Icons.explore),
              label: const Text('Explorar'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const WineListPage(
                      title: 'Todos os Vinhos',
                      fetchMethod: 'getAllWines',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Botão Explorar padrão (Todos os Vinhos)
            ElevatedButton.icon(
              icon: const Icon(Icons.wine_bar),
              label: const Text('Sugere o vinho certo ( para mim )'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const WineListPage(
                      title: 'Recomendados',
                      fetchMethod: 'recommend',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}