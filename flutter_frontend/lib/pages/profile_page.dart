// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _name;
  String? _email;
  String? _initial;

  // Endereço
  String? _country;
  String? _city;
  String? _street;
  String? _postalCode;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1) Pega o mongo_user_id das SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('mongo_user_id');
      if (userId == null) {
        throw Exception('Usuário não logado');
      }

      // 2) Chama getUserById para obter nome e email
      final userResponse = await ApiService.instance.getUserById(userId);
      dynamic rawUserData = userResponse.data;
      if (rawUserData is List && rawUserData.isNotEmpty) {
        rawUserData = rawUserData[0];
      }
      if (rawUserData is! Map<String, dynamic>) {
        throw Exception('Formato inesperado para getUserById');
      }
      final Map<String, dynamic> userData = rawUserData;

      _name = userData['name'] as String?;
      _email = userData['email'] as String?;
      if (_name != null && _name!.isNotEmpty) {
        _initial = _name!.trim()[0].toUpperCase();
      } else {
        _initial = '';
      }

      // 3) Chama fetchAddresses para obter o endereço
      final addrResponse = await ApiService.instance.fetchAddresses(userId);
      dynamic rawAddrData = addrResponse.data;
      if (rawAddrData is List && rawAddrData.isNotEmpty) {
        rawAddrData = rawAddrData[0];
      }
      if (rawAddrData is! Map<String, dynamic>) {
        throw Exception('Formato inesperado para fetchAddresses');
      }
      final Map<String, dynamic> addrData = rawAddrData;

      _country = addrData['country'] as String?;
      _city = addrData['city'] as String?;
      _street = addrData['address'] as String?;
      _postalCode = addrData['postal'] as String?;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // limpa todas as chaves gravadas
    // Redireciona para a LoginPage e remove histórico de navegação
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          'Erro ao carregar perfil:\n$_error',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 1) Círculo com inicial
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF52335E),
            child: Text(
              _initial ?? '',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2) Nome e e-mail
          if (_name != null)
            Text(
              _name!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF52335E),
              ),
            ),
          const SizedBox(height: 8),
          if (_email != null)
            Text(
              _email!,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          const SizedBox(height: 24),

          // 3) Seção de endereço
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF52335E), width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Endereço',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF52335E),
                  ),
                ),
                const SizedBox(height: 12),
                if (_country != null)
                  Text(
                    'País: $_country',
                    style: const TextStyle(fontSize: 16),
                  ),
                const SizedBox(height: 4),
                if (_city != null)
                  Text(
                    'Cidade: $_city',
                    style: const TextStyle(fontSize: 16),
                  ),
                const SizedBox(height: 4),
                if (_street != null)
                  Text(
                    'Endereço: $_street',
                    style: const TextStyle(fontSize: 16),
                  ),
                const SizedBox(height: 4),
                if (_postalCode != null)
                  Text(
                    'Código-Postal: $_postalCode',
                    style: const TextStyle(fontSize: 16),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 4) Botão de Logout
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _logout,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF52335E), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.white,
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF52335E),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}