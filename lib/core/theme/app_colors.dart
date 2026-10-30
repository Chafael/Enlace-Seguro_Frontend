import 'package:flutter/material.dart';

/// Colores del sistema de diseño de EnlaceSeguro (los mismos de Figma).
class AppColors {
  AppColors._();

  // Fondos y superficies
  static const background = Color(0xFF0A1220);
  static const surface = Color(0xFF101B2D);
  static const surface2 = Color(0xFF16233A);
  static const line = Color(0xFF1F2D45);

  // Marca
  static const primary = Color(0xFF2F7BF5);

  // Texto
  static const textPrimary = Color(0xFFE7EDF6);
  static const textSecondary = Color(0xFF8D9BB0);
  static const textTertiary = Color(0xFF5A6880);

  // Veredictos y estados
  static const safe = Color(0xFF2FBF71);
  static const suspicious = Color(0xFFE9A23B);
  static const danger = Color(0xFFE5484D);
  static const neutral = Color(0xFF8D9BB0);

  /// Versión suave (12 %) de un color, para fondos de pastillas y cajas.
  static Color tint(Color color) => color.withValues(alpha: 0.12);
}
