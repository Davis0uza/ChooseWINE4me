// lib/pages/wine_list_page.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/wine_model.dart';
import '../widgets/wine_list.dart';

class WineListPage extends StatefulWidget {
  final String title;
  final String fetchMethod;

  const WineListPage({
    super.key,
    required this.title,
    required this.fetchMethod,
  });

  @override
  State<WineListPage> createState() => _WineListPageState();
}

class _WineListPageState extends State<WineListPage> {
  List<Wine> _allWines = [];
  List<Wine> _filteredWines = [];
  bool _isLoading = true;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    _loadWines();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWines() async {
    try {
      final wines = await _getWinesByMethod(widget.fetchMethod);
      setState(() {
        _allWines = wines;
        _filteredWines = wines;
        _isLoading = false;
      });
    } catch (e) {
      // tratamento de erro opcional
      setState(() { _isLoading = false; });
    }
  }

  Future<List<Wine>> _getWinesByMethod(String method) {
    switch (method) {
      case 'getAllWines':
        return _fetchAll();
      case 'searchWines':
        return _fetchSearch('');
      default:
        return _fetchAll();
    }
  }

  Future<List<Wine>> _fetchAll() async {
    final resp = await ApiService.instance.getAllWines();
    final data = resp.data as List;
    return data.map((json) => Wine.fromJson(json)).toList();
  }

  Future<List<Wine>> _fetchSearch(String query) async {
    final resp = await ApiService.instance.getAllWines();
    final data = resp.data as List;
    return data.map((json) => Wine.fromJson(json)).toList();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredWines = _allWines.where((wine) {
        return wine.name.toLowerCase().contains(query)
            || wine.type.toLowerCase().contains(query)
            || wine.country.toLowerCase().contains(query)
            || wine.winery.toLowerCase().contains(query)
            || wine.year.toLowerCase().contains(query);
      }).toList();
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar vinhos...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: WineList(wines: _filteredWines),
                ),
              ],
            ),
    );
  }
}
