import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import 'config.dart';

class ApiService {
  ApiService._() {
    _dio = Dio(BaseOptions(
      baseUrl: kBackendBaseUrl,
      connectTimeout: const Duration(milliseconds: 5000),
      receiveTimeout: const Duration(milliseconds: 5000),
    ))
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Usa apenas o JWT (não o id_token do Firebase)
          final prefs = await SharedPreferences.getInstance();
          final jwt = prefs.getString('jwt_token');
          if (jwt != null && jwt.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $jwt';
          }
          handler.next(options);
        },
        onError: (e, handler) => handler.next(e),
      ),
    );
  }

  static final ApiService instance = ApiService._();
  late final Dio _dio;


  Future<Response> fetchAddresses(String userId) async {
    return _dio.get('/addresses/user/$userId');
  }

  Future<Response> createAddress(Map<String, dynamic> addressData) {
    return _dio.post('/addresses', data: addressData);
  }

  Future<Response> updateAddress(String id, Map<String, dynamic> addressData) {
    return _dio.put('/addresses/$id', data: addressData);
  }

  Future<Response> deleteAddress(String id) {
    return _dio.delete('/addresses/$id');
  }

  Future<Response> registerUser({
      required String name,
      required String email,
      required String password,
    }) {
      return _dio.post(
        '/users/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );
  }

  Future<Response> loginWithEmail({
  required String email,
  required String password,
  }) async {
    final resp = await _dio.post(
      '/auth/email',
      data: {
        'email': email,
        'password': password,
      },
    );

    // 🔒 Guarda em SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', resp.data['token']);
    await prefs.setString('mongo_user_id', resp.data['userId']);
    await prefs.setString('user_name', resp.data['user']['name']);

    return resp;
  }

  Future<Response> getAllWines() {
    return _dio.get('/wines/');
  }

   Future<Response> getWineries() {
    return _dio.get('/wines/wineries');
  }

 Future<Uint8List> fetchProxyImage(String originalUrl) async {
    final resp = await _dio.get(
      '/images/proxy',
      queryParameters: {'url': originalUrl},
      options: Options(responseType: ResponseType.bytes),
    );
    return resp.data as Uint8List;
  }
}
