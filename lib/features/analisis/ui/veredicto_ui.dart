import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../data/analisis.dart';

/// Color, ícono y texto de cada resultado, en un solo lugar.
class VerdictStyle {
  const VerdictStyle(this.color, this.icon, this.label);

  final Color color;
  final IconData icon;
  final String label;

  static VerdictStyle of(Estado estado, Veredicto? veredicto) {
    if (estado == Estado.error) {
      return const VerdictStyle(AppColors.neutral, LucideIcons.cloudOff, 'Error');
    }
    return switch (veredicto) {
      Veredicto.seguro => const VerdictStyle(
          AppColors.safe, LucideIcons.shieldCheck, 'Sin amenazas detectadas'),
      Veredicto.sospechoso => const VerdictStyle(
          AppColors.suspicious, LucideIcons.triangleAlert, 'Sospechoso'),
      Veredicto.peligroso => const VerdictStyle(
          AppColors.danger, LucideIcons.octagonX, 'Peligroso'),
      null => const VerdictStyle(
          AppColors.primary, LucideIcons.loaderCircle, 'Analizando'),
    };
  }
}

/// Pastilla "Peligroso", "Sospechoso"... o "Analizando" con spinner.
class VerdictPill extends StatelessWidget {
  const VerdictPill({super.key, required this.estado, this.veredicto});

  final Estado estado;
  final Veredicto? veredicto;

  @override
  Widget build(BuildContext context) {
    final enProceso = !estado.esFinal;
    final style = VerdictStyle.of(estado, veredicto);
    final color = enProceso ? AppColors.textSecondary : style.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: enProceso ? AppColors.surface2 : AppColors.tint(style.color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (enProceso) ...[
            const SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            enProceso
                ? (estado == Estado.pendiente ? 'En fila' : 'Analizando')
                : style.label,
            style: AppText.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cuadro de 36 px con el ícono del resultado (o spinner si sigue en proceso).
class VerdictIconBox extends StatelessWidget {
  const VerdictIconBox({super.key, required this.estado, this.veredicto});

  final Estado estado;
  final Veredicto? veredicto;

  @override
  Widget build(BuildContext context) {
    final style = VerdictStyle.of(estado, veredicto);
    final enProceso = !estado.esFinal;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: enProceso ? AppColors.surface2 : AppColors.tint(style.color),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: enProceso
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(style.icon, size: 18, color: style.color),
    );
  }
}
