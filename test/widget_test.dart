import 'package:flutter_test/flutter_test.dart';

import 'package:enlace_seguro/core/api/api_exception.dart';
import 'package:enlace_seguro/core/theme/app_colors.dart';
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
}
