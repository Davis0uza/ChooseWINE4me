// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'wine_list_page.dart';
import '../widgets/custom_navbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNavBar(),
      body: Center(
        child: ElevatedButton.icon(
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
      ),
    );
  }
}