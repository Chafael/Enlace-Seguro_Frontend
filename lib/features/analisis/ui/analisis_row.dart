import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/tiempo.dart';
import '../data/analisis.dart';
import 'veredicto_ui.dart';

/// Fila de "Recientes" e "Historial": dominio, enlace, pastilla y hora.
class AnalisisRow extends StatelessWidget {
  const AnalisisRow({super.key, required this.item, this.tiempo});

  final AnalisisResumen item;

  /// Texto de la derecha. Si no se manda, usa "hace 5 min", "ayer"...
  final String? tiempo;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/analisis/${item.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VerdictIconBox(estado: item.estado, veredicto: item.veredicto),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.dominio,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.mono
                        .copyWith(fontSize: 12, color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: 8),
                  VerdictPill(estado: item.estado, veredicto: item.veredicto),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Text(tiempo ?? hace(item.creadoEn), style: AppText.caption),
                  const Icon(LucideIcons.chevronRight,
                      size: 16, color: AppColors.textTertiary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
