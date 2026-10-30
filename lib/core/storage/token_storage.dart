import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda el JWT cifrado en el dispositivo (Keystore de Android).
class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;
  static const _key = 'jwt';

  Future<String?> read() => _storage.read(key: _key);

  Future<void> save(String token) => _storage.write(key: _key, value: token);

  Future<void> clear() => _storage.delete(key: _key);

  /// Marca de que el usuario ya vio la Bienvenida. No se borra al cerrar
  /// sesión: la Bienvenida solo se muestra la primera vez.
  static const _bienvenidaKey = 'bienvenida_vista';

  Future<bool> bienvenidaVista() async =>
      await _storage.read(key: _bienvenidaKey) == '1';

  Future<void> marcarBienvenidaVista() =>
      _storage.write(key: _bienvenidaKey, value: '1');
}

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => TokenStorage(const FlutterSecureStorage()),
);
