import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/router.dart';
import 'core/compartir/texto_compartido.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Nombres de meses en español para las fechas ("oct 2026").
  await initializeDateFormatting('es');
  runApp(const ProviderScope(child: EnlaceSeguroApp()));
}

class EnlaceSeguroApp extends ConsumerStatefulWidget {
  const EnlaceSeguroApp({super.key});

  @override
  ConsumerState<EnlaceSeguroApp> createState() => _EnlaceSeguroAppState();
}

class _EnlaceSeguroAppState extends ConsumerState<EnlaceSeguroApp> {
  late final ReceptorCompartir _receptor;

  @override
  void initState() {
    super.initState();
    // Cuando llega un texto compartido se guarda y se abre Inicio.
    // Si no hay sesión, el router manda al login y el texto espera ahí.
    _receptor = ReceptorCompartir((texto) {
      ref.read(textoCompartidoProvider.notifier).state = texto;
      ref.read(routerProvider).go('/inicio');
    })
      ..iniciar();
  }

  @override
  void dispose() {
    _receptor.cancelar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EnlaceSeguro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
