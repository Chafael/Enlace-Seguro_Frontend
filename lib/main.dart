import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_text.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: EnlaceSeguroApp()));
}

class EnlaceSeguroApp extends StatelessWidget {
  const EnlaceSeguroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EnlaceSeguro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _ThemePreview(),
    );
  }
}

/// Pantalla temporal para revisar el tema. Se reemplaza en el paso 3.
class _ThemePreview extends StatelessWidget {
  const _ThemePreview();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Inicia sesión', style: AppText.h1),
            const SizedBox(height: 8),
            Text('Analiza enlaces sospechosos sin abrirlos.',
                style: AppText.small),
            const SizedBox(height: 24),
            Text('ENLACE ANALIZADO', style: AppText.sectionLabel),
            const SizedBox(height: 8),
            Text('https://bbva-mx-seguridad.com/login', style: AppText.mono),
            const SizedBox(height: 24),
            const TextField(
              decoration: InputDecoration(hintText: 'tucorreo@ejemplo.com'),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: () {}, child: const Text('Analizar enlace')),
            const SizedBox(height: 12),
            OutlinedButton(
                onPressed: () {}, child: const Text('Seguir en segundo plano')),
            const SizedBox(height: 24),
            Text('Peligroso',
                style: AppText.h1.copyWith(color: AppColors.danger)),
          ],
        ),
      ),
    );
  }
}
