import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/url_box.dart';
import '../data/analisis.dart';
import '../data/analisis_repository.dart';
import 'veredicto_ui.dart';

/// Pantalla de resultado: veredicto, enlace, razones y captura.
class ResultadoView extends StatefulWidget {
  const ResultadoView({super.key, required this.analisis});

  final Analisis analisis;

  @override
  State<ResultadoView> createState() => _ResultadoViewState();
}

class _ResultadoViewState extends State<ResultadoView> {
  bool _verCaptura = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.analisis;
    final esError = a.estado == Estado.error;
    final style = VerdictStyle.of(a.estado, a.veredicto);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        _Header(onBack: () => context.canPop() ? context.pop() : context.go('/inicio')),
        const SizedBox(height: 16),
        _BloqueVeredicto(analisis: a, style: style),
        if (a.desdeCache) ...[
          const SizedBox(height: 10),
          const Align(alignment: Alignment.centerLeft, child: _ChipCache()),
        ],
        const SizedBox(height: 24),
        Text('ENLACE ANALIZADO', style: AppText.sectionLabel),
        const SizedBox(height: 8),
        UrlBox(url: a.url),
        if (a.redirige) ...[
          const SizedBox(height: 12),
          Text('Te redirige a', style: AppText.small),
          const SizedBox(height: 8),
          UrlBox(url: a.urlFinal!, color: style.color),
        ],
        const SizedBox(height: 24),
        if (esError) ...[
          Text('QUÉ PASÓ', style: AppText.sectionLabel),
          const SizedBox(height: 4),
          _Razones(razones: a.razones, color: style.color),
          const SizedBox(height: 24),
          _Reintentar(url: a.url),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.go('/inicio'),
            child: const Text('Volver al inicio'),
          ),
        ] else ...[
          _Selector(
            verCaptura: _verCaptura,
            onChanged: (v) => setState(() => _verCaptura = v),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _verCaptura
                ? _Captura(key: const ValueKey('captura'), base64: a.captura, url: a.url, style: style)
                : Column(
                    key: const ValueKey('razones'),
                    children: [
                      _Razones(razones: a.razones, color: style.color),
                      const SizedBox(height: 16),
                      _Nota(veredicto: a.veredicto),
                    ],
                  ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.go('/inicio?analizar=1'),
            child: const Text('Analizar otro enlace'),
          ),
          TextButton(
            onPressed: () => context.go('/historial'),
            child: const Text('Ver en historial'),
          ),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

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
          Text('Resultado', style: AppText.h2),
        ],
      ),
    );
  }
}

/// Bloque de color con el veredicto, como en Figma.
class _BloqueVeredicto extends StatelessWidget {
  const _BloqueVeredicto({required this.analisis, required this.style});

  final Analisis analisis;
  final VerdictStyle style;

  String get _explicacion => switch ((analisis.estado, analisis.veredicto)) {
        (Estado.error, _) => 'Ningún entorno aislado respondió a tiempo.',
        (_, Veredicto.seguro) => 'No encontramos señales de fraude.',
        (_, Veredicto.sospechoso) =>
          'Hay señales de alerta. Mejor no ingreses tus datos.',
        _ => 'No abras este enlace ni compartas tus datos.',
      };

  String get _titulo =>
      analisis.estado == Estado.error ? 'No se pudo analizar' : style.label;

  String get _fecha {
    final f = analisis.creadoEn;
    final now = DateTime.now();
    final hoy = f.year == now.year && f.month == now.month && f.day == now.day;
    final dia = hoy ? 'hoy' : DateFormat('dd/MM/yy').format(f);
    return 'Analizado $dia, ${DateFormat('HH:mm').format(f)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.tint(style.color),
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: style.color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(style.icon, size: 28, color: style.color),
          const SizedBox(height: 10),
          Text(_titulo, style: AppText.h1.copyWith(color: style.color)),
          const SizedBox(height: 4),
          Text(_explicacion, style: AppText.body.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Text(_fecha, style: AppText.mono.copyWith(fontSize: 12, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

class _ChipCache extends StatelessWidget {
  const _ChipCache();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.refreshCw, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text('Resultado reciente reutilizado',
              style: AppText.caption.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

/// Control "Razones | Captura".
class _Selector extends StatelessWidget {
  const _Selector({required this.verCaptura, required this.onChanged});

  final bool verCaptura;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget opcion(String texto, bool activo, bool valor) => Expanded(
          child: GestureDetector(
            onTap: () => onChanged(valor),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: activo ? AppColors.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: activo ? AppColors.line : Colors.transparent),
              ),
              child: Text(
                texto,
                style: AppText.small.copyWith(
                  color: activo ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: activo ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          opcion('Razones', !verCaptura, false),
          opcion('Captura', verCaptura, true),
        ],
      ),
    );
  }
}

class _Razones extends StatelessWidget {
  const _Razones({required this.razones, required this.color});

  final List<String> razones;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final r in razones)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.line)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(width: 6, height: 6, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(r, style: AppText.body)),
              ],
            ),
          ),
      ],
    );
  }
}

/// Nota final según el veredicto.
class _Nota extends StatelessWidget {
  const _Nota({required this.veredicto});

  final Veredicto? veredicto;

  @override
  Widget build(BuildContext context) {
    final (texto, icono, color) = switch (veredicto) {
      Veredicto.peligroso => (
          'Si ya ingresaste datos, llama a tu banco y cambia tus contraseñas.',
          LucideIcons.phone,
          AppColors.danger,
        ),
      Veredicto.seguro => (
          'Ningún análisis garantiza el 100 %. Si te piden datos bancarios o códigos, desconfía.',
          LucideIcons.info,
          AppColors.textSecondary,
        ),
      _ => (null, null, null),
    };
    if (texto == null) return const SizedBox.shrink();
    final peligro = veredicto == Veredicto.peligroso;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: peligro ? AppColors.tint(AppColors.danger) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: peligro ? color!.withValues(alpha: 0.6) : AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: AppText.small.copyWith(
                color: peligro ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Captura PNG en base64 que tomó el sandbox (formato vertical de Pixel 7).
class _Captura extends StatelessWidget {
  const _Captura({super.key, required this.base64, required this.url, required this.style});

  final String? base64;
  final String url;
  final VerdictStyle style;

  @override
  Widget build(BuildContext context) {
    final bytes = base64 == null ? null : base64Decode(base64!);
    return Column(
      children: [
        GestureDetector(
          onTap: bytes == null
              ? null
              : () => Navigator.of(context).push(MaterialPageRoute<void>(
                    fullscreenDialog: true,
                    builder: (_) => _CapturaCompleta(bytes: bytes, url: url, style: style),
                  )),
          child: Container(
            width: 220,
            height: 220 * 839 / 412,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            clipBehavior: Clip.antiAlias,
            child: bytes == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.imageOff, size: 24, color: AppColors.textTertiary),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'No se pudo obtener la captura porque la página no cargó.',
                          style: AppText.small,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )
                : Image.memory(bytes, fit: BoxFit.cover, alignment: Alignment.topCenter),
          ),
        ),
        if (bytes != null) ...[
          const SizedBox(height: 10),
          Text('Así se veía la página en un celular. Toca para ampliar.',
              style: AppText.caption, textAlign: TextAlign.center),
        ],
      ],
    );
  }
}

class _CapturaCompleta extends StatelessWidget {
  const _CapturaCompleta({required this.bytes, required this.url, required this.style});

  final Uint8List bytes;
  final String url;
  final VerdictStyle style;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05090F),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Captura de la página',
                            style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
                        Text(url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.mono.copyWith(fontSize: 12, color: AppColors.textTertiary)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar',
                    icon: const Icon(LucideIcons.x, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                maxScale: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.memory(bytes, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.tint(style.color),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(style.label,
                        style: AppText.caption.copyWith(color: style.color, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Es solo una imagen, no la página real.', style: AppText.caption),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vuelve a mandar el mismo enlace cuando ningún sandbox respondió.
class _Reintentar extends ConsumerStatefulWidget {
  const _Reintentar({required this.url});

  final String url;

  @override
  ConsumerState<_Reintentar> createState() => _ReintentarState();
}

class _ReintentarState extends ConsumerState<_Reintentar> {
  bool _loading = false;

  Future<void> _go() async {
    setState(() => _loading = true);
    try {
      final nuevo = await ref.read(analisisRepositoryProvider).crear(widget.url);
      if (mounted) context.pushReplacement('/analisis/${nuevo.id}');
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: _loading ? null : _go,
      child: _loading
          ? const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Text('Intentar de nuevo'),
    );
  }
}
