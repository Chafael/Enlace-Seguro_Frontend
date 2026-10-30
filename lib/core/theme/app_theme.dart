import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';

/// Tema global. Con esto los widgets normales de Flutter (FilledButton,
/// TextField, SnackBar...) ya salen con el estilo de Figma sin repetir
/// colores en cada pantalla.
class AppTheme {
  AppTheme._();

  static final _radius12 = BorderRadius.circular(12);

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: _radius12,
        borderSide: BorderSide(color: color),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: AppText.sans,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          error: AppColors.danger,
          outline: AppColors.line,
        ),
        textTheme: TextTheme(
          headlineMedium: AppText.h1,
          titleLarge: AppText.h2,
          bodyLarge: AppText.body,
          bodyMedium: AppText.small,
          bodySmall: AppText.caption,
          labelLarge: AppText.button,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.line,
          thickness: 1,
          space: 1,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.surface,
            disabledForegroundColor: AppColors.textTertiary,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: _radius12),
            textStyle: AppText.button,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            minimumSize: const Size.fromHeight(52),
            side: const BorderSide(color: AppColors.line),
            shape: RoundedRectangleBorder(borderRadius: _radius12),
            textStyle: AppText.button,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppText.button,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          hintStyle: AppText.body.copyWith(color: AppColors.textTertiary),
          errorStyle: AppText.caption.copyWith(color: AppColors.danger),
          prefixIconColor: AppColors.textSecondary,
          suffixIconColor: AppColors.textSecondary,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          border: _border(AppColors.line),
          enabledBorder: _border(AppColors.line),
          focusedBorder: _border(AppColors.primary),
          errorBorder: _border(AppColors.danger),
          focusedErrorBorder: _border(AppColors.danger),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surface2,
          contentTextStyle: AppText.small.copyWith(color: AppColors.textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: _radius12,
            side: const BorderSide(color: AppColors.line),
          ),
        ),
      );
}
