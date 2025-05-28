// lib/widgets/wine_item.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/wine_model.dart';
import '../services/api_service.dart';

class WineItem extends StatelessWidget {
  final Wine wine;
  const WineItem({super.key, required this.wine});

  @override
  Widget build(BuildContext context) {
    final filledStars = wine.rating.round();
    const maxStars = 5;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          // Coluna 1: imagem via proxy
          SizedBox(
            width: 60,
            height: 120,
            child: wine.imageUrl != null
              ? FutureBuilder<Uint8List>(
                  future: ApiService.instance.fetchProxyImage(wine.imageUrl!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || snapshot.data == null) {
                      return Image.asset(
                        'assets/images/wine-placeholder.png',
                        fit: BoxFit.cover,
                      );
                    }
                    return Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    );
                  },
                )
              : Image.asset(
                  'assets/images/wine-placeholder.png',
                  fit: BoxFit.cover,
                ),
          ),

          const SizedBox(width: 12),

          // Coluna 2: classificação + tipo + país + vinícola
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E9FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Classificação:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(maxStars, (i) {
                      return Icon(
                        i < filledStars ? Icons.star : Icons.star_border,
                        size: 16,
                        color: const Color(0xFF9B51E0),
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Text(wine.type),
                  Text(wine.country),
                  Text(wine.winery),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Coluna 3: nome e preço
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  wine.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9B51E0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${wine.price.toStringAsFixed(2)}€',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
