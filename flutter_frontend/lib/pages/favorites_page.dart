// lib/pages/favorites_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/wine_model.dart';
import '../services/api_service.dart';
import '../widgets/wine_list.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Wine> _favoriteWines = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  /// Função que busca os favoritos e atualiza o estado.
  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1) Pega o ID do usuário logado (mongo_user_id) das SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('mongo_user_id');

      if (userId == null) {
        throw Exception('Usuário não está logado');
      }

      // 2) Faz a chamada a getFavorites(), que retorna Response<dynamic>
      final response = await ApiService.instance.getFavorites();

      // 3) Extrai 'data' do Response e converte para List<dynamic>
      final List<dynamic> allFavorites = response.data as List<dynamic>;

      // 4) Filtra apenas aqueles cujo campo "user" bate com userId
      final List<Wine> wines = [];
      for (var favEntry in allFavorites) {
        if (favEntry is Map<String, dynamic>) {
          final String? entryUser = favEntry['user'] as String?;
          final dynamic wineData = favEntry['wine'];

          if (entryUser == userId && wineData is Map<String, dynamic>) {
            wines.add(Wine.fromJson(wineData));
          }
        }
      }

      setState(() {
        _favoriteWines = wines;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Favoritos'),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 1) Enquanto estiver carregando, mostra indicador
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2) Se ocorreu erro, exibe mensagem
    if (_errorMessage != null) {
      return Center(
        child: Text(
          'Erro ao carregar favoritos:\n$_errorMessage',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    // 3) Se não houver favoritos, avisa o usuário
    if (_favoriteWines.isEmpty) {
      return const Center(
        child: Text('Você ainda não favoritou nenhum vinho.'),
      );
    }

    // 4) Se chegou até aqui, exibe a lista com RefreshIndicator
    return RefreshIndicator(
      // Quando puxar para baixo, chama _loadFavorites()
      onRefresh: _loadFavorites,
      color: const Color(0xFF52335E), // cor do círculo de pull-to-refresh
      child: WineList(
        wines: _favoriteWines,
        mode: 'favorite',
      ),
    );
  }
}
