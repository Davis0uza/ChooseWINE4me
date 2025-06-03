// lib/widgets/favorite_button.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class FavoriteButton extends StatefulWidget {
  final String wineId;

  const FavoriteButton({super.key, required this.wineId});

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isFavorited = false;
  String? _favoriteId;
  String? _userId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initFavorite();
  }

  Future<void> _initFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getString('mongo_user_id');
    if (storedUserId == null) {
      setState(() {
        _loading = false;
      });
      return;
    }
    _userId = storedUserId;

    try {
      final resp = await ApiService.instance.getFavorites();
      final data = resp.data as List;
      for (var favJson in data) {
        if (favJson['user'] == _userId && favJson['wineId'] == widget.wineId) {
          setState(() {
            _isFavorited = true;
            _favoriteId = favJson['_id'] ?? favJson['id'];
          });
          break;
        }
      }
    } catch (e) {
      // Ignora erro ao buscar favoritos
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_userId == null) return;

    if (!_isFavorited) {
      try {
        final resp = await ApiService.instance.createFavorite(
          userId: _userId!,
          wineId: widget.wineId,
        );
        final created = resp.data as Map<String, dynamic>;
        setState(() {
          _isFavorited = true;
          _favoriteId = created['_id'] ?? created['id'];
        });
      } catch (e) {
        // Lidar com erro de criação (opcional)
      }
    } else {
      if (_favoriteId == null) return;
      try {
        await ApiService.instance.deleteFavorite(_favoriteId!);
        setState(() {
          _isFavorited = false;
          _favoriteId = null;
        });
      } catch (e) {
        // Lidar com erro de deleção (opcional)
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        width: 48,
        height: 48,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.purple.shade800),
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(8),
      ),
      onPressed: _toggleFavorite,
      child: Icon(
        _isFavorited ? Icons.favorite : Icons.favorite_border,
        color: Colors.purple.shade800,
        size: 24,
      ),
    );
  }
}
