import 'package:flutter/foundation.dart';

/// Configuración que llega al compilar con --dart-define.
///
/// Ejemplo con celular físico:
///   flutter run --dart-define=API_URL=http://192.168.1.111:8000
class Env {
  Env._();

  static const _apiUrl = String.fromEnvironment('API_URL');

  /// Si no se manda API_URL:
  /// - en Chrome la API está en localhost de la misma PC;
  /// - en el emulador de Android, 10.0.2.2 es el localhost de la PC.
  static String get apiUrl {
    if (_apiUrl.isNotEmpty) return _apiUrl;
    return kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';
  }
}
