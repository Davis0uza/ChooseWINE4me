// lib/widgets/wine_info_actions.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wine_model.dart';
import '../services/api_service.dart';
import '../widgets/favorite_button.dart';
import 'rating_form.dart';

class WineInfoActions extends StatefulWidget {
  final Wine wine;

  const WineInfoActions({
    super.key,
    required this.wine,
  });

  @override
  State<WineInfoActions> createState() => _WineInfoActionsState();
}

class _WineInfoActionsState extends State<WineInfoActions> {
  late Wine _wineData;
  bool _hasRated = false;
  bool _isLoadingRatingStatus = true;

  @override
  void initState() {
    super.initState();
    _wineData = widget.wine;
    _checkIfUserHasRated();
  }

  Future<void> _checkIfUserHasRated() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('mongo_user_id');
    if (userId == null) {
      if (mounted) {
        setState(() {
          _hasRated = false;
          _isLoadingRatingStatus = false;
        });
      }
      return;
    }

    bool found = false;
    try {
      final resp = await ApiService.instance.getRatings();
      final dataList = (resp.data as List).cast<Map<String, dynamic>>();
      for (final item in dataList) {
        final rawWine = item['wine'] as Map<String, dynamic>?;
        final rawUser = item['user'] as Map<String, dynamic>?;
        if (rawWine != null && rawUser != null) {
          final wid = rawWine['_id'] as String;
          final uid = rawUser['_id'] as String;
          if (wid == _wineData.id && uid == userId) {
            found = true;
            break;
          }
        }
      }
    } catch (_) {
      found = false;
    }

    if (mounted) {
      setState(() {
        _hasRated = found;
        _isLoadingRatingStatus = false;
      });
    }
  }

  Future<void> _reloadWineData() async {
    try {
      final resp = await ApiService.instance.getWine(_wineData.id);
      final data = resp.data as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _wineData = Wine.fromJson(data);
        });
      }
    } catch (_) {
      // Se falhar em recarregar, ignoramos
    }
  }

  void _openRatingForm() {
    showDialog(
      context: context,
      builder: (_) => RatingForm(
        wineId: _wineData.id,
        onRatingChanged: () async {
          await _reloadWineData();
          await _checkIfUserHasRated();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRatingStatus) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ───── INFORMAÇÕES DO VINHO ─────
        const Text(
          'Classificação:',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              _wineData.rating.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.purple,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.star, size: 16, color: Colors.purple),
          ],
        ),
        const SizedBox(height: 10),
        if (_wineData.winery.trim().toLowerCase() != 'n/a') ...[
          Text(
            _wineData.winery,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          _wineData.country,
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 4),
        if (_wineData.alcoholLevel > 0) ...[
          Text(
            'Nível de álcool: ${_wineData.alcoholLevel.toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
        ],
        if (_wineData.price > 0) ...[
          Text(
            '€${_wineData.price.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.purple.shade800,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
        ] else
          const SizedBox(height: 6),

        // ───── BOTÕES “Avaliar/Avaliado” E “Favorito” ─────
        Row(
          children: [
            OutlinedButton(
              onPressed: _openRatingForm,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: _hasRated ? Colors.purple.shade800 : Colors.purple),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor:
                    _hasRated ? Colors.purple.shade800 : Colors.transparent,
              ),
              child: Text(
                _hasRated ? 'Avaliado' : 'Avaliar',
                style: TextStyle(
                  color: _hasRated ? Colors.white : Colors.purple.shade800,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FavoriteButton(wineId: _wineData.id),
          ],
        ),
      ],
    );
  }
}
