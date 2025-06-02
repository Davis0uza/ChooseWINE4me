// lib/widgets/custom_navbar.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Navbar simples com fundo transparente e dois botões circulares:
/// - Esquerda: inicial do usuário (extraída de SharedPreferences)
/// - Direita: ícone de favoritos (navega para '/')
class CustomNavBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomNavBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  String _initial = '?';

  @override
  void initState() {
    super.initState();
    _loadUserInitial();
  }

  Future<void> _loadUserInitial() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    final trimmed = name.trim();
    if (trimmed.isNotEmpty) {
      setState(() {
        _initial = trimmed[0].toUpperCase();
      });
    }
  }

  void _navigateHome() {
    Navigator.of(context).pushNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botão de perfil com inicial do usuário
          const SizedBox(width: 2),
          GestureDetector(
            onTap: _navigateHome,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFEADFFD),
              child: Text(
                _initial,
                style: const TextStyle(
                  color: Color(0xFF9B51E0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Botão de favoritos
          GestureDetector(
            onTap: _navigateHome,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEADFFD),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border,
                color: Color(0xFF9B51E0),
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 2),
        ],
      ),
    );
  }
}
