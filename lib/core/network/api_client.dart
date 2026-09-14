import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class ApiClient {
  late Dio _dio;
  final AuthService _authService = AuthService();

  // Usa 10.0.2.2 para emuladores Android o localhost para Web/iOS
  // Cambia esto si pruebas en dispositivo físico (usa la IP de tu PC en la red wifi)
  static const String _baseUrl = kIsWeb ? 'http://localhost:5000/api' : 'http://10.0.2.2:5000/api'; 

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _authService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            print('API Error: \${e.message}');
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
