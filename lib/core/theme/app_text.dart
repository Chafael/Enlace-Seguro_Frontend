import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Estilos de texto del diseño. Plex Sans para la interfaz y Plex Mono
/// para enlaces, etiquetas de sección, fechas y cronómetros. Las fuentes
/// están en assets/fonts, así funcionan sin internet.
class AppText {
  AppText._();

  /// Nombres declarados en pubspec.yaml (sección fonts).
  static const sans = 'IBMPlexSans';
  static const monoFamily = 'IBMPlexMono';

  static TextStyle _sans(double size, double height, FontWeight weight,
          [Color color = AppColors.textPrimary]) =>
      TextStyle(
        fontFamily: sans,
        fontSize: size,
        height: height / size,
        fontWeight: weight,
        color: color,
      );

  static final h1 = _sans(26, 32, FontWeight.w600);
  static final h2 = _sans(20, 26, FontWeight.w600);
  static final body = _sans(15, 22, FontWeight.w400);
  static final small = _sans(13, 18, FontWeight.w400, AppColors.textSecondary);
  static final caption = _sans(12, 16, FontWeight.w400, AppColors.textTertiary);
  static final button = _sans(15, 20, FontWeight.w600);
  static final number = _sans(32, 38, FontWeight.w600);

  /// Etiqueta de sección: "RECIENTES", "ENLACE ANALIZADO".
  static const sectionLabel = TextStyle(
    fontFamily: monoFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.2,
    color: AppColors.textTertiary,
  );

  /// Enlaces mostrados como bloque de código.
  static const mono = TextStyle(
    fontFamily: monoFamily,
    fontSize: 13,
    height: 18 / 13,
    color: AppColors.textSecondary,
  );
}
