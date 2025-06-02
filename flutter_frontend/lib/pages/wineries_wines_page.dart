// lib/pages/wineries_wines_page.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/wine_model.dart';
import '../widgets/wine_list.dart';

class WineriesWinesPage extends StatefulWidget {
  final String title;
  final String winery;

  const WineriesWinesPage({
    super.key,
    required this.title,
    required this.winery,
  });

  @override
  State<WineriesWinesPage> createState() => _WineriesWinesPageState();
}

class _WineriesWinesPageState extends State<WineriesWinesPage> {
  List<Wine> _filteredWines = [];
  List<Wine> _displayedWines = [];
  bool _isLoading = true;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadAndFilterWines();
  }

  Future<void> _loadAndFilterWines() async {
    try {
      // 1) Busca todos os vinhos
      final resp = await ApiService.instance.getAllWines();
      final data = resp.data as List;
      final allWines = data.map((json) => Wine.fromJson(json)).toList();

      // 2) Filtra somente aqueles cuja propriedade 'winery' bata com widget.winery (case‐insensitive)
      _filteredWines = allWines
          .where((w) =>
              w.winery.toLowerCase() == widget.winery.toLowerCase())
          .toList();

      // 3) Inicialmente, displayed = filtered
      _displayedWines = List.from(_filteredWines);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String text) {
    _searchText = text;
    setState(() {
      if (_searchText.isEmpty) {
        _displayedWines = List.from(_filteredWines);
      } else {
        _displayedWines = _filteredWines.where((wine) {
          return wine.name
              .toLowerCase()
              .contains(_searchText.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Barra de pesquisa
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Pesquisar vinhos...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                // Lista rolável de vinhos filtrados + pesquisa aplicada
                Expanded(
                  child: WineList(wines: _displayedWines),
                ),
              ],
            ),
    );
  }
}
