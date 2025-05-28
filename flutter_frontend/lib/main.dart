import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/firebase_options.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'pages/login_page.dart';
import 'pages/address_page.dart';
import 'pages/register_page.dart';
import 'pages/login_email_page.dart';
import 'pages/home_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChooseWine',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      routes: {
        '/': (context) => const AuthGate(),              // AuthGate fica aqui mesmo!
        '/address': (context) => const AddressPage(),
        '/register': (context) => const RegisterPage(),
        '/login-email': (context) => const LoginEmailPage(),
      },
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
    );
  }
}

// AuthGate continua aqui mesmo!
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLoggedInViaJwt(),
      builder: (ctx, snapJwt) {
        if (snapJwt.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapJwt.data != true) {
          // nem JWT nem Firebase
          return const LoginPage();
        }
        // JWT existe (login-email) ou Firebase user existe (social)
        return FutureBuilder<bool>(
          future: _hasAddress(),
          builder: (ctx2, snapAddr) {
            if (snapAddr.connectionState != ConnectionState.done) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            return snapAddr.data == true
                ? HomePage()
                : const AddressPage();
          },
        );
      },
    );
  }

  Future<bool> _isLoggedInViaJwt() async {
    // 1) Se houver user do Firebase, já é suficiente
    if (FirebaseAuth.instance.currentUser != null) return true;
    // 2) Senão, verifica se existe JWT nas prefs
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');
    return jwt != null && jwt.isNotEmpty;
  }

  Future<bool> _hasAddress() async {
    const int maxAttempts = 20;
    const Duration delay = Duration(milliseconds: 100);

    // 1️⃣ Espera até o mongoUserId estar disponível
    String? mongoId;
    for (int i = 0; i < maxAttempts; i++) {
      mongoId = await AuthService.instance.mongoUserId;
      if (mongoId != null && mongoId.isNotEmpty) break;
      await Future.delayed(delay);
    }
    if (mongoId == null || mongoId.isEmpty) {
      debugPrint('mongoUserId nunca apareceu após aguardar ${maxAttempts * delay.inMilliseconds}ms');
      return false; // Não temos ID, força AddressPage
    }

    // 2. Espera o JWT estar disponível antes de continuar!
    for (int i = 0; i < 20; i++) {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt_token');
      if (jwt != null && jwt.isNotEmpty) break;
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // 3️⃣ Chama o backend a ver se existem moradas
    try {
      final resp = await ApiService.instance.fetchAddresses(mongoId);
      return resp.statusCode == 200 && (resp.data as List).isNotEmpty;
    } catch (e) {
      debugPrint('Erro ao verificar endereço: $e');
      return false;
    }
  } 
}

// Mantém o resto dos imports, classes e lógicas aqui como já tens.

