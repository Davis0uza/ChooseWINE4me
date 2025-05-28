// lib/widgets/wine_list.dart
import 'package:flutter/material.dart';
import '../models/wine_model.dart';
import '../services/api_service.dart';
import 'wine_item.dart';

class WineList extends StatefulWidget {
  const WineList({super.key});

  @override
  State<WineList> createState() => _WineListState();
}

class _WineListState extends State<WineList> {
  late Future<List<Wine>> _winesFuture;

  @override
  void initState() {
    super.initState();
    _winesFuture = _fetchWines();
  }

  Future<List<Wine>> _fetchWines() async {
    final resp = await ApiService.instance.getAllWines(); // ⚠️ ajuste se necessário :contentReference[oaicite:2]{index=2}
    final List data = resp.data as List;
    return data.map((json) => Wine.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Wine>>(
      future: _winesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }
        final wines = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: wines.length,
          itemBuilder: (context, index) {
            return WineItem(wine: wines[index]);
          },
        );
      },
    );
  }
}
