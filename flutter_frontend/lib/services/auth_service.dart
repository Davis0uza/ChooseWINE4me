import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth    = FirebaseAuth.instance;
  final _http    = Dio();
  final _storage = const FlutterSecureStorage();

  static const _jwtKey       = 'backend_jwt';
  static const _mongoIdKey   = 'backend_user_id';

  AuthService() {
    // Interceptor para incluir o JWT nas chamadas
    _http.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: _jwtKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  Future<User?> signInWithGoogle() async {
    late UserCredential userCred;

    if (kIsWeb) {
      userCred = await _auth.signInWithPopup(
        GoogleAuthProvider()
          ..addScope('email')
          ..addScope('profile'),
      );
    } else {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;
      final googleAuth = await googleUser.authentication;
      final cred = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      userCred = await _auth.signInWithCredential(cred);
    }

    final user = userCred.user;
    if (user == null) return null;

    // obtém o ID-Token do Firebase
    final idToken = await user.getIdToken();
    final resp = await _http.post(
      'http://192.168.36.112:3000/auth/firebase',
      data: {'idToken': idToken},
    );
    if (resp.statusCode != 200) {
      throw Exception('Falha ao autenticar no backend');
    }

    final data = resp.data as Map<String, dynamic>;

    // guarda o JWT local
    final backendJwt = data['token'] as String;
    await _storage.write(key: _jwtKey, value: backendJwt);

    // guarda o Mongo User ID
    final mongoUserId = data['userId'] as String;
    await _storage.write(key: _mongoIdKey, value: mongoUserId);

    return user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) await GoogleSignIn().signOut();
    await _storage.delete(key: _jwtKey);
    await _storage.delete(key: _mongoIdKey);
  }

  Future<bool> isSignedIn() async {
    final token = await _storage.read(key: _jwtKey);
    return token != null && token.isNotEmpty;
  }

  Future<String?> get mongoUserId async {
    return await _storage.read(key: _mongoIdKey);
  }

  Dio get httpClient => _http;
}
