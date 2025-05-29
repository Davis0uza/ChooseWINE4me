// lib/services/auth_service.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';

class AuthService {
  AuthService._() {
    _dio = Dio(BaseOptions(baseUrl: kBackendBaseUrl))
      ..interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }
  static final AuthService instance = AuthService._();

  late final Dio _dio;
  final _google = GoogleSignIn(
    scopes: ['openid', 'email'],
    clientId: kIsWeb
        ? '1013089135904-umqldfdnm79thic4ia656cbk6lullqbd.apps.googleusercontent.com'
        : null,
  );

  final _fbAuth = FirebaseAuth.instance;

  static const _keyIdToken = 'id_token';
  static const _keyMongoUserId = 'mongo_user_id';

  /// Guarda no shared_preferences
  Future<void> _save(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> _read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  /// Login com Google + backend, guarda idToken, mongoUserId E JWT
  Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      // Novo fluxo web recomendado
      final provider = GoogleAuthProvider();
      final userCredential = await _fbAuth.signInWithPopup(provider);
      final idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        throw Exception('idToken Firebase não disponível');
      }

      // Chama backend para criar/validar utilizador e gerar MongoID
      final resp = await _dio.post(
        '/auth/firebase',
        data: {'idToken': idToken},
      );
      if (!(resp.statusCode == 200 || resp.statusCode == 201)) {
        throw Exception('Erro no backend: ${resp.statusCode}');
      }

      final body = resp.data;
      final mongoId = body['userId'] as String?;
      final jwtToken = body['token'] as String?;

      if (mongoId == null) {
        throw Exception('mongoUserId não retornado pelo backend');
      }
      if (jwtToken == null) {
        throw Exception('JWT não retornado pelo backend');
      }

      // GUARDA TUDO!
      await _save('jwt_token', jwtToken); 
      await _save(_keyMongoUserId, mongoId);
      await _save(_keyIdToken, idToken);

      return userCredential.user;
    } else {
      // Fluxo original Mobile
      final googleUser = await _google.signIn();
      if (googleUser == null) return null;

      final auth = await googleUser.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        throw Exception('idToken Google não disponível');
      }

      // Backend
      final resp = await _dio.post(
        '/auth/firebase',
        data: {'idToken': idToken},
      );
      if (!(resp.statusCode == 200 || resp.statusCode == 201)) {
        throw Exception('Erro no backend: ${resp.statusCode}');
      }

      final body = resp.data;
      final mongoId = body['userId'] as String?;
      final jwtToken = body['token'] as String?;

      if (mongoId == null) {
        throw Exception('mongoUserId não retornado pelo backend');
      }
      if (jwtToken == null) {
        throw Exception('JWT não retornado pelo backend');
      }

      // GUARDA TUDO!
      await _save('jwt_token', jwtToken);         // <---- ESSENCIAL!
      await _save(_keyMongoUserId, mongoId);
      await _save(_keyIdToken, idToken);

      // Autentica no Firebase
      final cred = GoogleAuthProvider.credential(idToken: idToken);
      await _fbAuth.signInWithCredential(cred);

      return _fbAuth.currentUser;
    }
  }

  /// Desloga de tudo e limpa prefs
  Future<void> signOut() async {
    if (!kIsWeb) {
      await _google.signOut();
    }
    await _fbAuth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIdToken);
    await prefs.remove(_keyMongoUserId);
    await prefs.remove('jwt_token');
  }

  /// Lê o idToken guardado
  Future<String?> get idToken async {
    return _read(_keyIdToken);
  }

  /// Lê o mongoUserId guardado
  Future<String?> get mongoUserId async {
    return _read(_keyMongoUserId);
  }
}
