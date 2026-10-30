import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';

class RegistroListoScreen extends StatelessWidget {
  const RegistroListoScreen({super.key, this.correo});

  final String? correo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.tint(AppColors.safe),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(LucideIcons.check,
                    color: AppColors.safe, size: 28),
              ),
              const SizedBox(height: 20),
              Text('Tu cuenta está lista', style: AppText.h2),
              const SizedBox(height: 8),
              Text(
                'Ahora inicia sesión con tu correo y contraseña.',
                style: AppText.small,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.go('/login', extra: correo),
                child: const Text('Ir a iniciar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
