// lib/widgets/wine_list.dart
import 'package:flutter/material.dart';
import '../models/wine_model.dart';
import 'wine_item.dart';
import 'favorite_wine_item.dart'; // <-- import do novo widget

/// Widget puro que recebe a lista de vinhos por parâmetro
/// e, opcionalmente, o modo 'favorite'.
class WineList extends StatelessWidget {
  final List<Wine> wines;
  final String? mode; // se vier 'favorite', usamos FavoriteWineItem

  const WineList({
    super.key,
    required this.wines,
    this.mode,
  });

  @override
  Widget build(BuildContext context) {
    if (wines.isEmpty) {
      return const Center(
        child: Text('Nenhum vinho disponível.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: wines.length,
      itemBuilder: (context, index) {
        final wine = wines[index];

        // Se foi passado o modo 'favorite', utilizamos o FavoriteWineItem
        if (mode != null && mode == 'favorite') {
          return FavoriteWineItem(wine: wine);
        }

        // Caso contrário, comportamento padrão
        return WineItem(wine: wine);
      },
    );
  }
}
