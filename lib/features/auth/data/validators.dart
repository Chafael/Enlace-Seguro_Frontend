/// Validaciones del formulario. Son solo para avisar rápido en pantalla;
/// la API vuelve a validar todo por su cuenta.
class Validators {
  Validators._();

  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static String? correo(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Escribe tu correo.';
    if (!_email.hasMatch(v)) return 'Revisa el formato del correo.';
    return null;
  }

  static String? passwordLogin(String? value) =>
      (value == null || value.isEmpty) ? 'Escribe tu contraseña.' : null;

  static String? passwordNueva(String? value) {
    final v = value ?? '';
    if (v.length < 8) return 'Mínimo 8 caracteres.';
    if (v.length > 72) return 'Máximo 72 caracteres.';
    return null;
  }

  static String? nombre(String? value) {
    final v = value?.trim() ?? '';
    if (v.length < 2) return 'Escribe al menos 2 caracteres.';
    if (v.length > 80) return 'Máximo 80 caracteres.';
    return null;
  }
}
