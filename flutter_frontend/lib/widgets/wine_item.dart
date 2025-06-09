// lib/widgets/wine_item.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wine_model.dart';
import '../services/api_service.dart';
import '../pages/wine_detail_page.dart';

/// Item de vinho com redesign minimal
class WineItem extends StatefulWidget {
  final Wine wine;
  const WineItem({Key? key, required this.wine}) : super(key: key);

  @override
  State<WineItem> createState() => _WineItemState();
}

class _WineItemState extends State<WineItem> {
  /// Ao tocar, registra histórico e navega
  Future<void> _onTap() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('mongo_user_id');

    if (userId != null) {
      try {
        await ApiService.instance.createHistory(
          userId: userId,
          wineId: widget.wine.id,
        );
      } catch (_) {}
    }
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => WineDetailPage(wineId: widget.wine.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Imagem via proxy
            SizedBox(
              width: 60,
              height: 120,
              child: widget.wine.imageUrl != null
                  ? FutureBuilder<Uint8List>(
                      future: ApiService.instance.fetchProxyImage(widget.wine.imageUrl!),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.done && snap.hasData) {
                          return Image.memory(snap.data!, fit: BoxFit.cover);
                        } else if (snap.hasError) {
                          return const Center(child: Icon(Icons.error));
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.local_drink, size: 32),
                    ),
            ),
            const SizedBox(width: 16),

            // Info: nome, winery, país e preço (condicional)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nome
                  Text(
                    widget.wine.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Winery (se não for 'N/A')
                  if (widget.wine.winery.toUpperCase() != 'N/A') ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.wine.winery,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Color(0xFF69182D),
                            fontStyle: FontStyle.italic,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  // País
                  const SizedBox(height: 4),
                  Text(
                    widget.wine.country,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Preço (somente se > 0)
                  if (widget.wine.price > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${widget.wine.price.toStringAsFixed(2)}€',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 134, 45, 69),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Botão de rating
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF69182D), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: Colors.transparent,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.wine.rating.toString(),
                    style: const TextStyle(
                      color: Color(0xFF69182D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.star, size: 16, color: Color(0xFF69182D)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}