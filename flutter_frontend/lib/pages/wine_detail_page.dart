// lib/pages/wine_detail_page.dart

import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/wine_model.dart';
import '../widgets/wine_info_actions.dart';
import '../widgets/rating_distribution.dart';
import '../widgets/comment_section.dart';
import '../widgets/wine_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isLoadingWine = true;
  List<Wine> _recommendations = [];
  bool _isRecLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWineAndRecommendations();
  }

  Future<void> _loadWineAndRecommendations() async {
    await _fetchWine();
    await _fetchRecommendations();
  }

  Future<void> _fetchWine() async {
    try {
      final resp = await ApiService.instance.getWine(widget.wineId);
      final data = resp.data as Map<String, dynamic>;
      setState(() {
        _wine = Wine.fromJson(data);
      });
    } catch (_) {
      // falhou em buscar, _wine fica nulo
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingWine = false;
        });
      }
    }
  }

  Future<void> _fetchRecommendations() async {
    // Aqui supomos que a rota reccomend já existe e retorna List<Wine> para o usuário logado
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('mongo_user_id');
    if (userId == null) {
      setState(() {
        _isRecLoading = false;
      });
      return;
    }
    try {
      final resp = await ApiService.instance.reccomend(userId);
      final dataList = (resp.data as List).cast<Map<String, dynamic>>();
      setState(() {
        _recommendations =
            dataList.map((json) => Wine.fromJson(json)).toList();
      });
    } catch (_) {
      // falhou em buscar recomendações
    } finally {
      if (mounted) {
        setState(() {
          _isRecLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double breakpoint = 600;

    if (_isLoadingWine) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_wine == null) {
      return const Scaffold(
        body: Center(child: Text('Erro ao carregar detalhes do vinho.')),
      );
    }

    // Calcular largura da imagem (proporção 3:4)
    double imageWidth;
    if (screenWidth >= breakpoint) {
      imageWidth = screenWidth * 0.25; // 25% da largura em web
    } else {
      imageWidth = screenWidth * 0.8; // 48% da largura em mobile
    }
    final imageHeight = imageWidth * 4 / 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── TÍTULO CENTRALIZADO ───
                Text(
                  _wine!.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                if (screenWidth >= breakpoint)
                  // ─── LAYOUT WEB ───
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1) IMAGEM
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
                                        width: imageWidth,
                                        height: imageHeight,
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

                      const SizedBox(width: 24),

                      // 2) BLOCO INFO + AÇÕES + FORMULÁRIO (embed WineInfoActions + RatingDistribution)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 2.1) Info + Botões (“Avaliar”/“Avaliado” + “Favorito”)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.purple.withAlpha(30),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: WineInfoActions(wine: _wine!),
                            ),

                            const SizedBox(height: 24),

                            // 2.2) RatingDistribution (gráfico de barras)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.purple.shade200),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Primeiro o gráfico de distribuição de ratings
                                  RatingDistribution(wineId: widget.wineId),

                                  const SizedBox(height: 24), // espaçamento entre os dois blocos

                                  // Depois a seção de comentários
                                  CommentSection(wineId: widget.wineId),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  // ─── LAYOUT MOBILE ───
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1) IMAGEM
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
                                        width: imageWidth,
                                        height: imageHeight,
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

                      const SizedBox(height: 16),

                      // 2.1) Info + Botões
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.purple.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: WineInfoActions(wine: _wine!),
                      ),

                      const SizedBox(height: 24),

                      // 2.2) RatingDistribution
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.purple.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Primeiro o gráfico de distribuição de ratings
                            RatingDistribution(wineId: widget.wineId),

                            const SizedBox(height: 24), // espaçamento entre os dois blocos

                            // Depois a seção de comentários
                            CommentSection(wineId: widget.wineId),
                          ],
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 32),

                // 3) TÍTULO "Recomendados"
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Recomendados',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.wine_bar, color: Colors.purple.shade800, size: 24),
                  ],
                ),

                const SizedBox(height: 16),

                // 4) Lista de recomendados
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.purple.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _isRecLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _recommendations.isEmpty
                          ? const Center(child: Text('Sem recomendações.'))
                          : SizedBox(
                              height: 300,
                              child: WineList(wines: _recommendations),
                            ),
                ),
                const SizedBox(height: 24),

                            
              ],
            ),
          ),
        ),
      ),
    );
  }
}
