import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

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
}
