// lib/widgets/rating_form.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class RatingForm extends StatefulWidget {
  /// ID do vinho que será avaliado (ObjectId em string)
  final String wineId;

  /// Callback disparado após criar/atualizar/deletar para recarregar dados
  final VoidCallback onRatingChanged;

  const RatingForm({
    super.key,
    required this.wineId,
    required this.onRatingChanged,
  });

  @override
  State<RatingForm> createState() => _RatingFormState();
}

class _RatingFormState extends State<RatingForm> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _hasExisting = false;
  String? _existingRatingId;
  int _ratingValue = 0; // 1..5
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchExistingRating();
  }

  Future<void> _fetchExistingRating() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('mongo_user_id');
    if (userId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasExisting = false;
        });
      }
      return;
    }

    try {
      final resp = await ApiService.instance.getRatings();
      final dataList = (resp.data as List).cast<Map<String, dynamic>>();

      String? foundId;
      int foundValue = 0;
      String foundComment = '';

      for (final item in dataList) {
        final rawWine = item['wine'] as Map<String, dynamic>?;
        final rawUser = item['user'] as Map<String, dynamic>?;
        if (rawWine != null && rawUser != null) {
          final wid = rawWine['_id'] as String;
          final uid = rawUser['_id'] as String;
          if (wid == widget.wineId && uid == userId) {
            foundId = item['_id'] as String;
            foundValue = (item['rating'] as num).toInt();
            foundComment = (item['comment'] as String?) ?? '';
            break;
          }
        }
      }

      if (mounted) {
        if (foundId != null) {
          _hasExisting = true;
          _existingRatingId = foundId;
          _ratingValue = foundValue;
          _commentController.text = foundComment;
        }
        setState(() {
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasExisting = false;
        });
      }
    }
  }

  Widget _buildStars() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final idx = i + 1;
        final filled = idx <= _ratingValue;
        return GestureDetector(
          onTap: () {
            setState(() {
              _ratingValue = idx;
            });
          },
          child: Icon(
            filled ? Icons.star : Icons.star_border,
            color: Colors.purple,
            size: 32,
          ),
        );
      }),
    );
  }

  Future<void> _handleConfirm() async {
    if (_ratingValue == 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione entre 1 e 5 estrelas.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('mongo_user_id');
      if (userId == null) throw Exception('Usuário não identificado');

      final commentText = _commentController.text.trim();

      if (_hasExisting && _existingRatingId != null) {
        await ApiService.instance.updateRating(
          id: _existingRatingId!,
          rating: _ratingValue.toDouble(),
          comment: commentText.isNotEmpty ? commentText : null,
        );
      } else {
        await ApiService.instance.createRating(
          user: userId,
          wineId: widget.wineId,
          rating: _ratingValue.toDouble(),
          comment: commentText.isNotEmpty ? commentText : null,
        );
      }

      if (mounted) {
        widget.onRatingChanged();
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao submeter avaliação.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _handleDelete() async {
    if (!_hasExisting || _existingRatingId == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ApiService.instance.deleteRating(id: _existingRatingId!);

      if (mounted) {
        _hasExisting = false;
        _existingRatingId = null;
        _ratingValue = 0;
        _commentController.clear();
        widget.onRatingChanged();
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao apagar avaliação.')),
        );
      }
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStars(),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                maxLength: 230,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Escreva um comentário (opcional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_hasExisting) ...[
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: _isSubmitting ? null : _handleDelete,
                    ),
                    const SizedBox(width: 8),
                  ],
                  OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            if (mounted) Navigator.of(context).pop();
                          },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade800,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      _hasExisting ? 'Atualizar' : 'Confirmar',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
