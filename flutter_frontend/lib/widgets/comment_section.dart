// lib/widgets/comment_section.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CommentSection extends StatefulWidget {
  /// O ID do vinho cujos comentários devem ser exibidos.
  final String wineId;

  const CommentSection({super.key, required this.wineId});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _allComments = [];
  bool _isLoading = true;
  bool _hasError = false;
  int _visibleCount = 4; // quantos comentários mostrar inicialmente

  @override
  void initState() {
    super.initState();
    _fetchComments();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_isLoading &&
        !_hasError &&
        _visibleCount < _allComments.length &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100) {
      // Quando chegar perto do fim, exibe mais 4 comentários (até o máximo)
      setState(() {
        _visibleCount = (_visibleCount + 4).clamp(0, _allComments.length);
      });
    }
  }

  Future<void> _fetchComments() async {
    try {
      final resp = await ApiService.instance.getRatings(); // usa getRatings
      final data = (resp.data as List).cast<Map<String, dynamic>>();

      final List<Map<String, dynamic>> filtered = [];
      for (final item in data) {
        final rawWine = item['wine'] as Map<String, dynamic>?;
        final comment = item['comment'] as String?;
        if (rawWine != null &&
            rawWine['_id'] == widget.wineId &&
            comment != null &&
            comment.trim().isNotEmpty) {
          // Extrai nome do usuário
          final user = item['user'];
          final userName =
              (user is Map<String, dynamic> && user['name'] != null)
                  ? (user['name'] as String)
                  : 'Anônimo';

          // Extrai valor da nota (rating)
          final rawRating = item['rating'];
          final ratingValue = (rawRating is num ? rawRating.toInt() : 0);

          // Data de criação
          final createdAtStr = item['createdAt'] as String?;
          DateTime? createdAt;
          if (createdAtStr != null) {
            createdAt = DateTime.tryParse(createdAtStr);
          }

          filtered.add({
            'commentId': item['_id'] as String,
            'userName': userName,
            'ratingValue': ratingValue,
            'comment': comment.trim(),
            'createdAt': createdAt,
          });
        }
      }

      // Ordenar por data decrescente (mais recente primeiro)
      filtered.sort((a, b) {
        final da = a['createdAt'] as DateTime?;
        final db = b['createdAt'] as DateTime?;
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return db.compareTo(da);
      });

      setState(() {
        _allComments.addAll(filtered);
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  String _formatDateTime(DateTime dt) {
    // Formatar manualmente como "dd/MM/yyyy – HH:mm"
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year.toString();
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year – $hour:$minute';
  }

  Widget _buildStarRow(int ratingValue) {
    // Retorna uma linha de 5 estrelas: as first `ratingValue` cheias e o restante vazias
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < ratingValue ? Icons.star : Icons.star_border,
          color: Color(0xFF69182D),
          size: 16,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hasError) {
      return const Center(child: Text('Erro ao carregar comentários.'));
    }
    if (_allComments.isEmpty) {
      return const Center(child: Text('Ainda não há comentários.'));
    }

    // Mostra apenas até _visibleCount itens
    final displayList =
        _allComments.take(_visibleCount).toList(growable: false);

    return ListView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount:
          displayList.length + (_visibleCount < _allComments.length ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < displayList.length) {
          final commentData = displayList[index];
          final userName = commentData['userName'] as String;
          final ratingValue = commentData['ratingValue'] as int;
          final comment = commentData['comment'] as String;
          final createdAt = commentData['createdAt'] as DateTime?;
          final formattedDate =
              createdAt != null ? _formatDateTime(createdAt) : '';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome do usuário + estrelas
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    _buildStarRow(ratingValue),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment,
                  style: const TextStyle(fontSize: 14),
                ),
                if (formattedDate.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                const Divider(),
              ],
            ),
          );
        } else {
          // Item extra que mostra indicador de carregamento,
          // enquanto houver mais comentários a exibir.
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
