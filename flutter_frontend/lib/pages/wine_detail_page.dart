// lib/pages/wine_detail_page.dart
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/wine_model.dart';
import '../widgets/favorite_button.dart';
import '../widgets/rating_distribution.dart';

class WineDetailPage extends StatefulWidget {
  final String wineId;

  const WineDetailPage({
    super.key,
    required this.wineId,
  });

  @override
  State<WineDetailPage> createState() => _WineDetailPageState();
}

class _WineDetailPageState extends State<WineDetailPage> {
  Wine? _wine;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWine();
  }

  Future<void> _fetchWine() async {
    try {
      final resp = await ApiService.instance.getWine(widget.wineId);
      final data = resp.data as Map<String, dynamic>;
      setState(() {
        _wine = Wine.fromJson(data);
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
    final screenWidth = MediaQuery.of(context).size.width;
    const double breakpoint = 600;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_wine == null) {
      return const Scaffold(
        body: Center(child: Text('Erro ao carregar detalhes do vinho.')),
      );
    }

    // Calcular tamanho da imagem (mantém o tamanho original)
    double imageWidth;
    if (screenWidth >= breakpoint) {
      imageWidth = kIsWeb ? screenWidth * 0.20 : screenWidth * 0.25;
    } else {
      imageWidth = screenWidth * 0.8 * 0.6; // 48% da largura total
    }
    final imageHeight = imageWidth * 4 / 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Vinho'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1) TÍTULO (NOME DO VINHO)
            Text(
              _wine!.name,
              style: TextStyle(
                color: Colors.purple.shade800,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // 2) Layout responsivo
            if (screenWidth >= breakpoint)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2.1) IMAGEM retangular, fundo branco
                  Container(
                    width: imageWidth,
                    height: imageHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _wine!.imageUrl != null && _wine!.imageUrl!.isNotEmpty
                          ? FutureBuilder<Uint8List>(
                              future: ApiService.instance.fetchProxyImage(_wine!.imageUrl!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.done &&
                                    snapshot.hasData) {
                                  return Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  );
                                } else if (snapshot.hasError) {
                                  return const Center(child: Icon(Icons.error));
                                } else {
                                  return const Center(child: CircularProgressIndicator());
                                }
                              },
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.local_drink, size: 40, color: Colors.grey),
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 2.2 + 2.3) Agrupar INFORMAÇÕES e RATING lado a lado,
                  // deixando cada um com altura natural (sem forçar plena altura)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // INFO BLOCK
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _buildInfoBlock(),
                        ),

                        const SizedBox(width: 12),

                        // RATING DISTRIBUTION (mesma altura do info block)
                        RatingDistribution(wineId: widget.wineId),
                      ],
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 2.1) IMAGEM em telas pequenas
                  Container(
                    width: double.infinity,
                    height: imageHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _wine!.imageUrl != null && _wine!.imageUrl!.isNotEmpty
                          ? FutureBuilder<Uint8List>(
                              future: ApiService.instance.fetchProxyImage(_wine!.imageUrl!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.done &&
                                    snapshot.hasData) {
                                  return Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  );
                                } else if (snapshot.hasError) {
                                  return const Center(child: Icon(Icons.error));
                                } else {
                                  return const Center(child: CircularProgressIndicator());
                                }
                              },
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.local_drink, size: 40, color: Colors.grey),
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 2.2 + 2.3) Info + Rating empilhados em Column
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.purple.withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _buildInfoBlock(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RatingDistribution(wineId: widget.wineId),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Constrói o bloco de informações: classificação, casta, país, álcool, preço e botões
  Widget _buildInfoBlock() {
    final List<Widget> children = [];

    children.add(const Text(
      'Classificação:',
      style: TextStyle(fontSize: 14),
    ));
    children.add(const SizedBox(height: 6));

    children.add(Row(
      children: [
        Text(
          _wine!.rating.toStringAsFixed(1),
          style: const TextStyle(
            color: Colors.purple,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(
          Icons.star,
          size: 16,
          color: Colors.purple,
        ),
      ],
    ));
    children.add(const SizedBox(height: 10));

    if (_wine!.winery.trim().toLowerCase() != 'n/a') {
      children.add(Text(
        _wine!.winery,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ));
      children.add(const SizedBox(height: 4));
    }

    children.add(Text(
      _wine!.country,
      style: const TextStyle(fontSize: 12),
    ));
    children.add(const SizedBox(height: 4));

    if (_wine!.alcoholLevel > 0) {
      children.add(Text(
        'Nível de álcool: ${_wine!.alcoholLevel.toStringAsFixed(1)}%',
        style: const TextStyle(fontSize: 12),
      ));
      children.add(const SizedBox(height: 4));
    }

    if (_wine!.price > 0) {
      children.add(Text(
        '€${_wine!.price.toStringAsFixed(2)}',
        style: TextStyle(
          color: Colors.purple.shade800,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ));
      children.add(const SizedBox(height: 12));
    } else {
      children.add(const SizedBox(height: 6));
    }

    // Botões "Avaliar" e "Favorito" lado a lado
    children.add(Row(
      children: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.purple.shade800, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onPressed: () {},
          child: Text(
            'Avaliar',
            style: TextStyle(color: Colors.purple.shade800, fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        FavoriteButton(wineId: widget.wineId),
      ],
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
