// lib/pages/filter_results_page.dart
import 'package:flutter/material.dart';

import '../models/wine_model.dart';
import '../services/api_service.dart';
import '../widgets/wine_list.dart';

class FilterResultsPage extends StatefulWidget {
  final double minPrice;
  final double maxPrice;
  final double minRating;
  final double maxRating;
  final String? wineType;

  const FilterResultsPage({
    Key? key,
    required this.minPrice,
    required this.maxPrice,
    required this.minRating,
    required this.maxRating,
    this.wineType,
  }) : super(key: key);

  @override
  State<FilterResultsPage> createState() => _FilterResultsPageState();
}

class _FilterResultsPageState extends State<FilterResultsPage> {
  List<Wine> _allFilteredWines = []; // lista após filtrar por critério (preço, rating, tipo)
  List<Wine> _displayedWines = [];   // lista final exibida, já filtrada pela search bar
  bool _isLoading = true;
  String? _errorMessage;

  // Texto atual da search bar
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchAndFilterWines();
  }

  Future<void> _fetchAndFilterWines() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1) Buscamos todos os vinhos (ou o endpoint que retorna vinhos, como getAllWines)
      final response = await ApiService.instance.getAllWines();
      // Supomos que getAllWines() retorne um Response<dynamic> onde data é List<dynamic> de JSONs
      final List<dynamic> raw = response.data as List<dynamic>;

      // 2) Convertemos cada item para Wine, se possível
      final List<Wine> fetched = raw
          .whereType<Map<String, dynamic>>()
          .map((json) => Wine.fromJson(json))
          .toList();

      // 3) Filtragem inicial por preço, rating e tipo
      final List<Wine> filtered = fetched.where((wine) {
        final bool priceOk = wine.price >= widget.minPrice &&
            wine.price <= widget.maxPrice;
        final bool ratingOk = wine.rating >= widget.minRating &&
            wine.rating <= widget.maxRating;
        final bool typeOk = widget.wineType == null ||
            wine.type.toLowerCase() == widget.wineType!.toLowerCase();
        return priceOk && ratingOk && typeOk;
      }).toList();

      setState(() {
        _allFilteredWines = filtered;
        // Inicialmente exibimos todos os filtrados, sem considerar texto de busca
        _displayedWines = List.from(filtered);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar vinhos: $e';
        _isLoading = false;
      });
    }
  }

  void _onSearchTextChanged(String novoTexto) {
    setState(() {
      _searchQuery = novoTexto.trim().toLowerCase();
      if (_searchQuery.isEmpty) {
        // Sem texto de busca, exibimos a lista filtrada original
        _displayedWines = List.from(_allFilteredWines);
      } else {
        // Filtramos por nome do vinho
        _displayedWines = _allFilteredWines.where((wine) {
          return wine.name.toLowerCase().contains(_searchQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados da Busca'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ─── SEARCH BAR ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar por nome...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _onSearchTextChanged,
            ),
          ),

          // ─── CORPO: lista de resultados ou loading/erro ───────────
          Expanded(
            child: _buildResultsBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_displayedWines.isEmpty) {
      return const Center(
        child: Text('Nenhum vinho encontrado para esses critérios.'),
      );
    }

    // Se houver resultados, exibimos com WineList
    return WineList(
      wines: _displayedWines,
      // Aqui não usamos `mode: 'favorite'`, a menos que queira destacar os favoritos.
      // Mode null = aparecem como WineItem; se quiser FavoriteWineItem, passe mode: 'favorite'.
      mode: null,
    );
  }
}
