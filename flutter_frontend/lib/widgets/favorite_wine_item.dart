// lib/widgets/favorite_wine_item.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wine_model.dart';
import '../services/api_service.dart';
import '../pages/wine_detail_page.dart';
import 'favorite_button.dart'; // <-- import do botão de favoritos

class FavoriteWineItem extends StatefulWidget {
  final Wine wine;
  const FavoriteWineItem({super.key, required this.wine});

  @override
  State<FavoriteWineItem> createState() => _FavoriteWineItemState();
}

class _FavoriteWineItemState extends State<FavoriteWineItem> {
  Future<void> _onTap() async {
    // 1) Pega o userId (mongo_user_id) das SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('mongo_user_id');

    if (userId != null) {
      try {
        // 2) Cria o histórico chamando a API
        await ApiService.instance.createHistory(
          userId: userId,
          wineId: widget.wine.id,
        );
      } catch (e) {
        // Se falhar, apenas prossegue (você pode logar ou exibir um alerta opcional)
      }
    }

    // IMPORTANTE: checa se o estado ainda está no widget tree
    if (!mounted) return;

    // 3) Navega para a página de detalhes, passando o wine.id
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WineDetailPage(wineId: widget.wine.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filledStars = widget.wine.rating.round();
    const maxStars = 5;

    return GestureDetector(
      onTap: _onTap,
      child: Card(
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
              child: widget.wine.imageUrl != null
                  ? FutureBuilder<Uint8List>(
                      future: ApiService.instance
                          .fetchProxyImage(widget.wine.imageUrl!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return Image.memory(snapshot.data!, fit: BoxFit.cover);
                        } else if (snapshot.hasError) {
                          return const Center(child: Icon(Icons.error));
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.local_drink, size: 32),
                    ),
            ),

            const SizedBox(width: 12),

            // Coluna 2: dados do vinho (título, região, etc.)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1) Nome do vinho
                  Text(
                    widget.wine.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 2) Nome da casta (winery)
                  Text(
                    widget.wine.winery,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),

                  // 3) Preço (agora aparece antes do país)
                  Text(
                    '${widget.wine.price.toStringAsFixed(2)}€',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 4) País
                  Text(
                    widget.wine.country,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),

                  // 5) Estrelas de classificação
                  Row(
                    children: [
                      for (int i = 0; i < maxStars; i++)
                        Icon(
                          i < filledStars ? Icons.star : Icons.star_border,
                          color: Colors.purple,
                          size: 16,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Coluna 3: agora é o botão de favoritos, em vez do preço
            FavoriteButton(wineId: widget.wine.id),
          ]),
        ),
      ),
    );
  }
}
