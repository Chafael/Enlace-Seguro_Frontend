import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/app_logo.dart';

/// Se muestra mientras se revisa si hay un token guardado.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo de Figma: anillos y cuadrícula de puntos, centrados en el logo.
          SvgPicture.asset(
            'assets/ilustraciones/splash_fondo.svg',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                const AppLogo(size: 72),
                const SizedBox(height: 16),
                AppWordmark(style: AppText.h1),
                const SizedBox(height: 8),
                Text('Revisa antes de abrir', style: AppText.small),
                const Spacer(),
                const SizedBox(
                  width: 96,
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    color: AppColors.primary,
                    backgroundColor: AppColors.line,
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
