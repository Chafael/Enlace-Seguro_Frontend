/// Configuración que llega al compilar con --dart-define.
///
/// Ejemplo:
///   flutter run --dart-define=API_URL=http://192.168.1.50:8000
class Env {
  Env._();

  static const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
}
