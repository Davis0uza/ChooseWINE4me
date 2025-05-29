// lib/main.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';            // O teu ficheiro manual
import 'services/auth_service.dart';
import 'pages/login_page.dart';
import 'pages/address_page.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Na Web, precisamos das opções geradas manualmente
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    // No Mobile, o plugin do Firebase já auto‐inicializa com google‐services.json
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

  Future<Widget> _decideStartPage() async {
    final authService = AuthService();
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      return const LoginPage();
    }

    try {
      final mongoId = await authService.mongoUserId;
      final resp = await authService.httpClient.get(
        'http://192.168.36.112:3000/addresses',
        queryParameters: {'user': mongoId},
      );
      if (resp.statusCode == 200) {
        final list = resp.data as List;
        final hasAddress = list.any((addr) {
          final u = addr['user'];
          return (u is Map && u['_id'] == mongoId) || u == mongoId;
        });
        return hasAddress
            ? HomePage(user: firebaseUser)
            : const AddressPage();
      }
    } catch (_) {
      // fallback
    }
    return HomePage(user: firebaseUser);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _decideStartPage(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Uma vez pronto, devolve a página calculada
        return snap.data!;
      },
    );
  }
}
