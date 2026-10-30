import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';

/// Marco con la barra inferior (Inicio, Analizar, Historial).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final enHistorial = location.startsWith('/historial');
    return Scaffold(
      body: SafeArea(bottom: false, child: child),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _Item(
                  icon: LucideIcons.house,
                  label: 'Inicio',
                  activo: !enHistorial,
                  onTap: () => context.go('/inicio'),
                ),
                _Item(
                  icon: LucideIcons.shield,
                  label: 'Analizar',
                  activo: false,
                  // Lleva a Inicio y pone el cursor en el campo del enlace.
                  onTap: () => context.go('/inicio?analizar=1'),
                ),
                _Item(
                  icon: LucideIcons.history,
                  label: 'Historial',
                  activo: enHistorial,
                  onTap: () => context.go('/historial'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.label,
    required this.activo,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = activo ? AppColors.primary : AppColors.textTertiary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: activo ? AppColors.primary : Colors.transparent,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(2)),
              ),
            ),
            const Spacer(),
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(label, style: AppText.caption.copyWith(color: color, fontSize: 11)),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
