import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'pages/login_page.dart';
import 'pages/address_page.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChooseWine',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) {
          return const LoginPage();
        }

        // Usa o _id do MongoDB gravado em SharedPreferences!
        return FutureBuilder<bool>(
          future: _hasAddress(),
          builder: (context, addressSnap) {
            if (addressSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (addressSnap.hasError) {
              return const AddressPage();
            }
            if (addressSnap.data == true) {
              return HomePage(user: user);
            } else {
              return const AddressPage();
            }
          },
        );
      },
    );
  }

  // Busca o _id do MongoDB do utilizador e só faz request autenticada depois do JWT estar disponível
  Future<bool> _hasAddress() async {
    // 1. Lê o id do utilizador (MongoDB) gravado após login
    final mongoId = await AuthService.instance.mongoUserId;
    if (mongoId == null) {
      debugPrint('mongoUserId ainda não disponível!');
      return false;
    }

    // 2. Espera o JWT estar disponível antes de continuar!
    for (int i = 0; i < 20; i++) {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt_token');
      if (jwt != null && jwt.isNotEmpty) break;
      await Future.delayed(const Duration(milliseconds: 100));
    }

    try {
      final resp = await ApiService.instance.fetchAddresses(mongoId);
      return resp.statusCode == 200 && (resp.data as List).isNotEmpty;
    } catch (e) {
      debugPrint('Erro ao verificar endereço: $e');
      return false;
    }
  }
}
