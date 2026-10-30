import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/state/auth_controller.dart';

class CuentaScreen extends ConsumerWidget {
  const CuentaScreen({super.key});

  Future<void> _confirmarSalida(BuildContext context, WidgetRef ref) async {
    final salir = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Cerrar sesión?', style: AppText.h2),
            const SizedBox(height: 8),
            Text('Tendrás que volver a ingresar tu correo y contraseña.',
                style: AppText.body.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Cerrar sesión'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (salir == true) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioActualProvider).valueOrNull;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            SizedBox(
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton.outlined(
                      tooltip: 'Regresar',
                      onPressed: () => context.pop(),
                      icon: const Icon(LucideIcons.arrowLeft, size: 20),
                      style: IconButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.line),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  Text('Mi cuenta', style: AppText.h2),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.surface,
                child: Text(usuario?.iniciales ?? '', style: AppText.h2),
              ),
            ),
            const SizedBox(height: 12),
            Text(usuario?.nombre ?? '', style: AppText.h2, textAlign: TextAlign.center),
            Text(usuario?.correo ?? '', style: AppText.small, textAlign: TextAlign.center),
            if (usuario?.creadoEn != null)
              Text(
                'Miembro desde ${DateFormat('MMM yyyy', 'es').format(usuario!.creadoEn!)}',
                style: AppText.mono.copyWith(fontSize: 12, color: AppColors.textTertiary),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 32),
            Text('CÓMO FUNCIONA', style: AppText.sectionLabel),
            const _Fila(LucideIcons.box, 'Tu enlace se revisa en uno de 3 entornos aislados.'),
            const _Fila(LucideIcons.refreshCw, 'Si una página es peligrosa, ese entorno se reinicia limpio.'),
            const _Fila(LucideIcons.database, 'Consultamos VirusTotal, Google Safe Browsing y URLhaus.'),
            const SizedBox(height: 24),
            Text('ACERCA DE', style: AppText.sectionLabel),
            const SizedBox(height: 10),
            Text('Proyecto de Seguridad Informática, UPChiapas', style: AppText.small),
            const SizedBox(height: 40),
            OutlinedButton.icon(
              onPressed: () => _confirmarSalida(context, ref),
              icon: const Icon(LucideIcons.logOut, size: 18),
              label: const Text('Cerrar sesión'),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
            ),
          ],
        ),
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila(this.icono, this.texto);

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icono, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(texto, style: AppText.small.copyWith(color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}
