import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/tiempo.dart';
import '../../../core/widgets/alert_box.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/url_box.dart';
import '../data/analisis.dart';
import '../data/analisis_repository.dart';
import 'resultado_view.dart';

/// Una sola ruta (/analisis/:id) para todo el análisis:
/// mientras está pendiente o procesando muestra la espera, y cuando
/// termina cambia sola al resultado. Así, abrir desde el historial un
/// análisis que sigue en proceso también funciona.
class AnalisisScreen extends ConsumerWidget {
  const AnalisisScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analisis = ref.watch(analisisEnCursoProvider(id));

    return Scaffold(
      body: SafeArea(
        child: analisis.when(
          loading: () => const _Analizando(analisis: null),
          error: (e, _) => _ErrorConsulta(
            mensaje: e is ApiException ? e.message : '$e',
            onRetry: () => ref.invalidate(analisisEnCursoProvider(id)),
          ),
          data: (a) => a.estado.esFinal
              ? ResultadoView(analisis: a)
              : _Analizando(analisis: a),
        ),
      ),
    );
  }
}

class _Analizando extends StatefulWidget {
  const _Analizando({required this.analisis});

  final Analisis? analisis;

  @override
  State<_Analizando> createState() => _AnalizandoState();
}

class _AnalizandoState extends State<_Analizando> {
  final _reloj = Stopwatch()..start();
  late final Timer _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _tick.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.analisis;
    final procesando = a?.estado == Estado.procesando;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        _Header(titulo: 'Analizando', onBack: () => context.pop()),
        const SizedBox(height: 12),
        _Progreso(paso: procesando ? 3 : 2),
        const SizedBox(height: 40),
        const Center(child: _Escaner()),
        const SizedBox(height: 28),
        Text('Revisando el enlace', style: AppText.h2, textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(
          'Puede tardar unos segundos, hasta 1 minuto si hay mucha demanda.',
          style: AppText.small,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          cronometro(_reloj.elapsed),
          style: AppText.mono.copyWith(fontSize: 15),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        if (a != null) ...[
          Text('ENLACE', style: AppText.sectionLabel),
          const SizedBox(height: 8),
          UrlBox(url: a.url),
          const SizedBox(height: 20),
        ],
        const _Paso(texto: 'Recibimos tu enlace', estado: _EstadoPaso.listo),
        _Paso(
          texto: 'En fila para un entorno aislado',
          estado: procesando ? _EstadoPaso.listo : _EstadoPaso.actual,
        ),
        _Paso(
          texto: 'Abriendo la página en un navegador aislado',
          estado: procesando ? _EstadoPaso.actual : _EstadoPaso.pendiente,
        ),
        const SizedBox(height: 28),
        OutlinedButton(
          onPressed: () => context.go('/inicio'),
          child: const Text('Seguir en segundo plano'),
        ),
        const SizedBox(height: 8),
        Text('El resultado quedará en tu historial.',
            style: AppText.caption, textAlign: TextAlign.center),
      ],
    );
  }
}

/// Encabezado con botón de regresar y título centrado.
class _Header extends StatelessWidget {
  const _Header({required this.titulo, required this.onBack});

  final String titulo;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton.outlined(
              tooltip: 'Regresar',
              onPressed: onBack,
              icon: const Icon(LucideIcons.arrowLeft, size: 20),
              style: IconButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.line),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Text(titulo, style: AppText.h2),
        ],
      ),
    );
  }
}

/// Tres segmentos: Recibido, En fila, Analizando.
class _Progreso extends StatelessWidget {
  const _Progreso({required this.paso});

  /// 2 = en fila, 3 = analizando.
  final int paso;

  @override
  Widget build(BuildContext context) {
    const etiquetas = ['Recibido', 'En fila', 'Analizando'];
    return Row(
      children: List.generate(3, (i) {
        final n = i + 1;
        final completo = n < paso;
        final actual = n == paso;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    value: completo ? 1 : (actual ? null : 0),
                    color: AppColors.primary,
                    backgroundColor: AppColors.line,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  etiquetas[i],
                  style: AppText.caption.copyWith(
                    color: actual ? AppColors.textPrimary : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

/// Escudo dentro de un anillo que gira (progreso indeterminado).
class _Escaner extends StatelessWidget {
  const _Escaner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
              backgroundColor: AppColors.line,
            ),
          ),
          AppLogo(size: 40),
        ],
      ),
    );
  }
}

enum _EstadoPaso { listo, actual, pendiente }

class _Paso extends StatelessWidget {
  const _Paso({required this.texto, required this.estado});

  final String texto;
  final _EstadoPaso estado;

  @override
  Widget build(BuildContext context) {
    final icono = switch (estado) {
      _EstadoPaso.listo =>
        const Icon(LucideIcons.circleCheck, size: 16, color: AppColors.safe),
      _EstadoPaso.actual => const SizedBox(
          width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
      _EstadoPaso.pendiente =>
        const Icon(LucideIcons.circle, size: 16, color: AppColors.textTertiary),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(width: 18, child: Center(child: icono)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: AppText.body.copyWith(
                color: estado == _EstadoPaso.pendiente
                    ? AppColors.textTertiary
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorConsulta extends StatelessWidget {
  const _ErrorConsulta({required this.mensaje, required this.onRetry});

  final String mensaje;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AlertBox(message: mensaje, icon: LucideIcons.wifiOff),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.go('/inicio'),
            child: const Text('Volver al inicio'),
          ),
        ],
      ),
    );
  }
}
