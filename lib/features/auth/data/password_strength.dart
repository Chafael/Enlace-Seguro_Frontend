/// Puntaje de 0 a 4 para la barra "Seguridad de la contraseña".
/// Suma un punto por cada regla que cumple.
int passwordStrength(String password) {
  if (password.isEmpty) return 0;
  var score = 0;
  if (password.length >= 8) score++;
  if (password.length >= 12) score++;
  if (RegExp(r'[a-z]').hasMatch(password) && RegExp(r'[A-Z]').hasMatch(password)) score++;
  if (RegExp(r'[0-9]').hasMatch(password) && RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;
  return score;
}

String passwordStrengthLabel(int score) => switch (score) {
      0 || 1 => 'baja',
      2 => 'media',
      3 => 'buena',
      _ => 'alta',
    };
