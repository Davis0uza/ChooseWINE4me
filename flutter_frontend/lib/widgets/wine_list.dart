// lib/widgets/wine_list.dart
import 'package:flutter/material.dart';
import '../models/wine_model.dart';
import 'wine_item.dart';

/// Widget puro que recebe a lista de vinhos por parâmetro
class WineList extends StatelessWidget {
  final List<Wine> wines;
  const WineList({super.key, required this.wines});

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
        return WineItem(wine: wines[index]);
      },
    );
  }
}