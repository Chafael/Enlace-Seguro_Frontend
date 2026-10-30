import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Estilos de texto del diseño. Plex Sans para la interfaz y Plex Mono
/// para enlaces, etiquetas de sección, fechas y cronómetros.
class AppText {
  AppText._();

  static TextStyle _sans(double size, double height, FontWeight weight,
          [Color color = AppColors.textPrimary]) =>
      GoogleFonts.ibmPlexSans(
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
  static final sectionLabel = GoogleFonts.ibmPlexMono(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.2,
    color: AppColors.textTertiary,
  );

  /// Enlaces mostrados como bloque de código.
  static final mono = GoogleFonts.ibmPlexMono(
    fontSize: 13,
    height: 18 / 13,
    color: AppColors.textSecondary,
  );
}
