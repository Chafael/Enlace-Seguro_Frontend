import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Enlace mostrado como bloque de código, con botón para copiarlo.
/// Nunca es tocable: la app no abre enlaces sospechosos.
class UrlBox extends StatelessWidget {
  const UrlBox({super.key, required this.url, this.color});

  final String url;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.mono.copyWith(color: color),
            ),
          ),
          IconButton(
            tooltip: 'Copiar enlace',
            icon: const Icon(LucideIcons.copy,
                size: 16, color: AppColors.textSecondary),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: url));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enlace copiado.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
