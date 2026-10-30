import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Caja de aviso con fondo suave del color, borde y un ícono.
/// Se usa para "Correo o contraseña incorrectos", "Demasiados intentos", etc.
class AlertBox extends StatelessWidget {
  const AlertBox({
    super.key,
    required this.message,
    required this.icon,
    this.color = AppColors.danger,
  });

  final String message;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tint(color),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppText.small.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
