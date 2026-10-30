import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';

/// Escudo con eslabón: el mismo logo de Figma, dibujado como SVG.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 40, this.color = AppColors.primary});

  final double size;
  final Color color;

  static const _svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#000" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
<path d="M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z"/>
<g transform="translate(12 12) scale(0.42) translate(-12 -12)" stroke-width="4.2">
<path d="M9 17H7A5 5 0 0 1 7 7h2"/><path d="M15 7h2a5 5 0 1 1 0 10h-2"/><line x1="8" x2="16" y1="12" y2="12"/>
</g></svg>''';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _svg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

/// "Enlace" en blanco y "Seguro" en azul.
class AppWordmark extends StatelessWidget {
  const AppWordmark({super.key, required this.style});

  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          const TextSpan(text: 'Enlace'),
          TextSpan(
            text: 'Seguro',
            style: const TextStyle(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
