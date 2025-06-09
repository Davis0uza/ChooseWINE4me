// lib/widgets/custom_navbar.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/favorites_page.dart';
import '../pages/profile_page.dart'; // Importa a nova página de perfil

class CustomNavBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomNavBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  String? _initial;

  @override
  void initState() {
    super.initState();
    _loadUserInitial();
  }

  Future<void> _loadUserInitial() async {
    final prefs = await SharedPreferences.getInstance();
    final String? name = prefs.getString('user_name');
    setState(() {
      _initial = (name != null && name.isNotEmpty)
          ? name.trim()[0].toUpperCase()
          : 'A';
    });
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
          // Botão de Perfil
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              alignment: Alignment.center,
              child: Text(
                _initial ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF69182D),
                ),
              ),
            ),
          ),

          // Botão de Favoritos
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FavoritesPage()),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: const Icon(
                Icons.favorite_border,
                color: Color(0xFF69182D),
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
