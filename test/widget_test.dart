import 'package:flutter_test/flutter_test.dart';

import 'package:enlace_seguro/core/api/api_exception.dart';
import 'package:enlace_seguro/core/theme/app_colors.dart';
import 'package:enlace_seguro/core/utils/defang.dart';
import 'package:enlace_seguro/core/utils/tiempo.dart';
import 'package:enlace_seguro/features/analisis/data/analisis.dart';
import 'package:enlace_seguro/features/auth/data/password_strength.dart';
import 'package:enlace_seguro/features/auth/data/validators.dart';

void main() {
  test('Los colores coinciden con Figma', () {
    expect(AppColors.primary.toARGB32(), 0xFF2F7BF5);
    expect(AppColors.background.toARGB32(), 0xFF0A1220);
  });

  test('ApiException reconoce 401 y 429', () {
    expect(const ApiException('x', statusCode: 401).isUnauthorized, isTrue);
    expect(const ApiException('x', statusCode: 429).isRateLimited, isTrue);
  });

  test('Fuerza de contraseña', () {
    expect(passwordStrength(''), 0);
    expect(passwordStrength('abcdefgh'), 1);
    expect(passwordStrength('Abcdefgh1!'), 3);
    expect(passwordStrength('Abcdefghijk1!'), 4);
  });

  test('Validación de correo', () {
    expect(Validators.correo('rafael@ejemplo.com'), isNull);
    expect(Validators.correo('rafael@'), isNotNull);
    expect(Validators.correo(''), isNotNull);
  });

  test('Tiempo relativo', () {
    final ahora = DateTime(2026, 10, 30, 12, 0);
    expect(hace(DateTime(2026, 10, 30, 11, 55), ahora: ahora), 'hace 5 min');
    expect(hace(DateTime(2026, 10, 29, 20, 0), ahora: ahora), 'ayer');
    expect(hace(DateTime(2026, 10, 27, 9, 0), ahora: ahora), 'hace 3 días');
    expect(cronometro(const Duration(seconds: 7)), '00:07');
  });

  test('Modelo de análisis', () {
    final a = Analisis.fromJson({
      'id': '1',
      'url': 'https://bbva-mx-seguridad.com/login',
      'estado': 'terminado',
      'veredicto': 'peligroso',
      'razones': ['La página pide una contraseña.'],
      'urlFinal': 'https://otro.com',
      'captura': '',
      'desdeCache': true,
      'creadoEn': '2026-10-30T06:00:00Z',
    });
    expect(a.estado.esFinal, isTrue);
    expect(a.veredicto, Veredicto.peligroso);
    expect(a.dominio, 'bbva-mx-seguridad.com');
    expect(a.redirige, isTrue);
    expect(a.captura, isNull);
    expect(Estado.parse('procesando').esFinal, isFalse);
  });

  test('Enlace desactivado para compartir', () {
    expect(defang('https://bbva-mx.com/login'), 'hxxps://bbva-mx[.]com/login');
  });
}
