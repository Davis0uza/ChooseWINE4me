import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Widget que exibe um botão "Castas" com ícones e, ao ser pressionado,
/// mostra/oculta uma lista flutuante de vinícolas (wineries).
class CastasDropdownButton extends StatefulWidget {
  const CastasDropdownButton({super.key});

  @override
  State<CastasDropdownButton> createState() => _CastasDropdownButtonState();
}

class _CastasDropdownButtonState extends State<CastasDropdownButton> {
  bool _isExpanded = false;
  late Future<List<String>> _wineriesFuture;

  @override
  void initState() {
    super.initState();
    // Carrega lista de wineries (castas)
    _wineriesFuture = ApiService.instance
        .getWineries()
        .then((resp) => List<String>.from(resp.data as List));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _isExpanded ? Theme.of(context).primaryColorLight : null,
          ),
          onPressed: () => setState(() => _isExpanded = !_isExpanded),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.home),
              const SizedBox(width: 4),
              const Icon(Icons.local_bar),
              const SizedBox(width: 8),
              const Text('Castas'),
              if (_isExpanded) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.grey.shade200,
                  child: const Icon(
                    Icons.close,
                    size: 12,
                    color: Colors.black,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_isExpanded)
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 300,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: FutureBuilder<List<String>>(
              future: _wineriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Erro ao carregar castas'),
                  );
                } else {
                  final wineries = snapshot.data!;
                  return ListView.builder(
                    itemCount: wineries.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(wineries[index]),
                        onTap: () {
                          // Ação opcional ao selecionar uma casta
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
      ],
    );
  }
}
