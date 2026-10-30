import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/storage/token_storage.dart';
import 'usuario.dart';

/// Llamadas de autenticación a la API.
class AuthRepository {
  AuthRepository(this._api, this._tokens);

  final ApiClient _api;
  final TokenStorage _tokens;

  Future<void> login({required String correo, required String password}) async {
    final data = await _api.post(
      '/auth/login',
      body: {'correo': correo.trim(), 'password': password},
    );
    await _tokens.save(data['token'] as String);
  }

  Future<void> registro({
    required String nombre,
    required String correo,
    required String password,
  }) async {
    await _api.post(
      '/auth/registro',
      body: {'nombre': nombre.trim(), 'correo': correo.trim(), 'password': password},
    );
  }

  Future<Usuario> yo() async {
    final data = await _api.get('/yo');
    return Usuario.fromJson(data as Map<String, dynamic>);
  }

  Future<void> logout() => _tokens.clear();

  /// true si hay un token guardado y todavía no vence.
  Future<bool> hasValidToken() async {
    final token = await _tokens.read();
    if (token == null) return false;
    if (_isExpired(token)) {
      await _tokens.clear();
      return false;
    }
    return true;
  }

  /// Lee la fecha "exp" del JWT sin verificar la firma. La firma la revisa
  /// la API; aquí solo evitamos entrar a Inicio con un token que ya venció.
  static bool _isExpired(String token) {
    try {
      final payload = token.split('.')[1];
      final json = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(payload))));
      final exp = (json['exp'] as num).toInt();
      final vence = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(vence.subtract(const Duration(seconds: 30)));
    } catch (_) {
      return true;
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStorageProvider),
  ),
);

/// Datos del usuario con sesión iniciada (para "Hola, Carlos Rafael").
final usuarioActualProvider = FutureProvider.autoDispose<Usuario>(
  (ref) => ref.watch(authRepositoryProvider).yo(),
);
