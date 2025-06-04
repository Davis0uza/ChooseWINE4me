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
  bool _isSubmitting = false;

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
      final data = (resp.data as List).cast<Map<String, dynamic>>();

      String? foundFavId;
      for (var favJson in data) {
        final rawUser = favJson['user'] as String?; // agora é String
        final rawWine = favJson['wine'] as Map<String, dynamic>?;
        if (rawUser != null && rawWine != null) {
          final uid = rawUser;
          final wid = rawWine['_id'] as String;
          if (uid == _userId && wid == widget.wineId) {
            foundFavId = favJson['_id'] as String;
            break;
          }
        }
      }

      setState(() {
        _favoriteId = foundFavId;
        _isFavorited = foundFavId != null;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _isFavorited = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_userId == null || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (!_isFavorited) {
        // ───── CRIAR FAVORITO ─────
        final resp = await ApiService.instance.createFavorite(
          userId: _userId!,
          wineId: widget.wineId,
        );
        final created = resp.data as Map<String, dynamic>;
        setState(() {
          _isFavorited = true;
          _favoriteId = created['_id'] as String;
        });
      } else {
        // ───── DELETAR FAVORITO ─────
        if (_favoriteId != null) {
          await ApiService.instance.deleteFavorite(_favoriteId!);
          setState(() {
            _isFavorited = false;
            _favoriteId = null;
          });
        }
      }
    } catch (_) {
      // opcional: mostrar feedback de erro
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    // Decoração circular ao redor do ícone
    return GestureDetector(
      onTap: _toggleFavorite,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isFavorited
              ? Colors.purple.withAlpha((0.1 * 255).round())
              : Colors.transparent,
          border: Border.all(
            color: Colors.purple,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Icon(
            _isFavorited ? Icons.favorite : Icons.favorite_border,
            color: _isFavorited ? Colors.purple : Colors.purple,
            size: 20,
          ),
        ),
      ),
    );
  }
}
