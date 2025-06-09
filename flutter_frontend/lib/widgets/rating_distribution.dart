// lib/widgets/rating_distribution.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/wine_model.dart';

class RatingDistribution extends StatefulWidget {
  final String wineId;

  const RatingDistribution({super.key, required this.wineId});

  @override
  State<RatingDistribution> createState() => _RatingDistributionState();
}

class _RatingDistributionState extends State<RatingDistribution> {
  bool _isLoading = true;
  double _averageRating = 0.0;
  Map<int, int> _ratingCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
  int _totalRatings = 0;

  @override
  void initState() {
    super.initState();
    _loadRatingsData();
  }

  Future<void> _loadRatingsData() async {
    try {
      // 1) Buscar dados do vinho para obter nota média
      final wineResp = await ApiService.instance.getWine(widget.wineId);
      final wineData = wineResp.data as Map<String, dynamic>;
      final wine = Wine.fromJson(wineData);
      final avg = wine.rating;

      // 2) Buscar todos os ratings e filtrar pelo wineId
      final ratingsResp = await ApiService.instance.getRatings();
      final ratingsList = (ratingsResp.data as List).cast<Map<String, dynamic>>();

      final filtered = <Map<String, dynamic>>[];
      for (var r in ratingsList) {
        final dynamic rawWine = r['wine'];
        if (rawWine == null) continue;

        String idString = '';
        if (rawWine is String) {
          idString = rawWine;
        } else if (rawWine is Map<String, dynamic>) {
          final nestedId = rawWine['_id'];
          if (nestedId is String) {
            idString = nestedId;
          }
        }

        if (idString == widget.wineId) {
          filtered.add(r);
        }
      }

      // Contar quantas vezes cada nota aparece
      final counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      for (var r in filtered) {
        final v = (r['rating'] as num).toInt();
        if (counts.containsKey(v)) {
          counts[v] = counts[v]! + 1;
        }
      }

      setState(() {
        _averageRating = avg;
        _ratingCounts = counts;
        _totalRatings = filtered.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    // Dimensões ajustadas (30% menores que antes)
    const double barWidth = 100;
    const double barHeight = 10;
    const double labelFontSize = 12;
    const double countFontSize = 12;
    const double avgFontSize = 20;
    const double starSize = 20;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.purple.shade200, width: 1),
      ),
      child: _totalRatings == 0
          ? Center(
              child: Text(
                'Sem avaliações para este vinho.',
                style: TextStyle(
                  fontSize: labelFontSize,
                  color: Colors.grey.shade600,
                ),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Média e estrela
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _averageRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: avgFontSize,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF69182D),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.star,
                      size: starSize,
                      color: Color(0xFF69182D),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Lista vertical de barras (notas 5→1)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    final ratingValue = 5 - index; // 5,4,3,2,1
                    final count = _ratingCounts[ratingValue] ?? 0;
                    final proportion = _totalRatings > 0 ? count / _totalRatings : 0.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Número da nota
                          Text(
                            ratingValue.toString(),
                            style: TextStyle(
                              fontSize: labelFontSize,
                              color: Color(0xFF69182D),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Barra horizontal
                          Stack(
                            children: [
                              // Fundo da barra (tom claro)
                              Container(
                                width: barWidth,
                                height: barHeight,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 255, 219, 229),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              // Parte preenchida
                              Container(
                                width: barWidth * proportion,
                                height: barHeight,
                                decoration: BoxDecoration(
                                  color: Color(0xFF69182D),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 6),
                          // Contagem daquela nota
                          Text(
                            count.toString(),
                            style: TextStyle(
                              fontSize: countFontSize,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
    );
  }
}
