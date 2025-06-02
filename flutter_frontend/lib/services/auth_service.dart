import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_options.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final _dio = Dio(BaseOptions(baseUrl: 'http://192.168.151.206:3000'));
  final _fbAuth = FirebaseAuth.instance;
  final _google = GoogleSignIn();

  static const _keyMongoUserId = 'mongo_user_id';
  static const _keyJwtToken     = 'jwt_token';
  static const _keyIdToken      = 'firebase_id_token';
  static const _keyUserName     = 'user_name';

  Future<void> _save(String key, String? value) async {
    if (value == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> _read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<String?> get mongoUserId async => await _read(_keyMongoUserId);

  /// Login multiplataforma (Web popup ou Mobile SSO), autentica no Firebase,
  /// recolhe o Firebase ID token e envia ao backend.
  /// Retorna o Firebase [User] ou `null` se cancelado.
  Future<User?> signInWithGoogle() async {
    // Garantir Firebase inicializado com suas opções
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    UserCredential userCred;
    if (kIsWeb) {
      // Web: popup nativo do FirebaseAuth
      final provider = GoogleAuthProvider();
      userCred = await _fbAuth.signInWithPopup(provider);
    } else {
      // Mobile: fluxo GoogleSignIn + FirebaseAuth
      final googleUser = await _google.signIn();
      if (googleUser == null) return null;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      userCred = await _fbAuth.signInWithCredential(credential);
    }

    // Pega o Firebase ID token (aud = chosewine-d8c13)
    final firebaseIdToken = await userCred.user!.getIdToken();

    // (DEBUG opcional) imprimir para verificar aud no jwt.io
    // print('Firebase ID Token: $firebaseIdToken');

    // Envia ao backend
    final resp = await _dio.post(
      '/auth/firebase',
      data: {'idToken': firebaseIdToken},
    );
    if (resp.statusCode == null || resp.statusCode! < 200 || resp.statusCode! >= 300) {
      throw Exception('Erro no backend: ${resp.statusCode}');
    }

    // Persiste dados recebidos do backend
    final data     = resp.data as Map<String, dynamic>;
    final mongoId  = data['userId']  as String;
    final jwtToken = data['token']   as String;
    final name     = (data['user'] as Map<String, dynamic>)['name'] as String? ?? '';

    await _save(_keyJwtToken, jwtToken);
    await _save(_keyMongoUserId, mongoId);
    await _save(_keyIdToken, firebaseIdToken);
    await _save(_keyUserName, name);

    return userCred.user;
  }
}
