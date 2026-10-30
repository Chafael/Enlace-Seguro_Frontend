import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

/// Único punto de salida hacia la API de EnlaceSeguro.
class ApiClient {
  ApiClient(this._tokens)
      : _dio = Dio(
          BaseOptions(
            baseUrl: Env.apiUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            contentType: Headers.jsonContentType,
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: _addToken, onError: _onError),
    );
  }

  final Dio _dio;
  final TokenStorage _tokens;
  final _sessionExpired = StreamController<void>.broadcast();

  /// Avisa cuando la API responde 401 en una ruta protegida.
  /// El router lo escucha para mandar al usuario a iniciar sesión.
  Stream<void> get onSessionExpired => _sessionExpired.stream;

  static bool _isAuthRoute(String path) => path.startsWith('/auth/');

  Future<void> _addToken(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isAuthRoute(options.path)) {
      final token = await _tokens.read();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final isExpired = error.response?.statusCode == 401 &&
        !_isAuthRoute(error.requestOptions.path);
    if (isExpired) {
      await _tokens.clear();
      _sessionExpired.add(null);
    }
    handler.next(error);
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.get(path, queryParameters: query));

  Future<dynamic> post(String path, {Object? body}) =>
      _send(() => _dio.post(path, data: body));

  Future<dynamic> _send(Future<Response> Function() request) async {
    try {
      final response = await request();
      return response.data;
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  ApiException _toApiException(DioException e) {
    final response = e.response;
    if (response == null) {
      return const ApiException(
        'No pudimos conectar con el servidor. Revisa tu conexión.',
      );
    }
    final data = response.data;
    final detail = data is Map && data['detail'] is String
        ? data['detail'] as String
        : 'Ocurrió un error inesperado. Intenta de nuevo.';
    return ApiException(detail, statusCode: response.statusCode);
  }
}

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(tokenStorageProvider)),
);
