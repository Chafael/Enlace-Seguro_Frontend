import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/compartir/texto_compartido.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/loading_button.dart';
import '../../auth/data/auth_repository.dart';
import '../data/analisis.dart';
import '../data/analisis_repository.dart';
import 'analisis_row.dart';

const _maxCaracteres = 4000;

class InicioScreen extends ConsumerStatefulWidget {
  const InicioScreen({super.key, this.enfocar = false});

  /// true cuando se entra desde el botón "Analizar" de la barra inferior.
  final bool enfocar;

  @override
  ConsumerState<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends ConsumerState<InicioScreen> {
  final _texto = TextEditingController();
  final _foco = FocusNode();
  bool _loading = false;
  String? _error;

  /// true si el texto del campo llegó desde "Compartir" de otra app.
  bool _compartido = false;

  @override
  void initState() {
    super.initState();
    _texto.addListener(() => setState(() {}));
    if (widget.enfocar) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _foco.requestFocus());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _tomarCompartido());
  }

  /// Pone en el campo el texto que llegó de WhatsApp o SMS y lo marca
  /// como usado. No lo analiza solo: el usuario revisa y toca Analizar.
  void _tomarCompartido() {
    final texto = ref.read(textoCompartidoProvider);
    if (texto == null || !mounted) return;
    ref.read(textoCompartidoProvider.notifier).state = null;
    _texto.text = texto.length > _maxCaracteres
        ? texto.substring(0, _maxCaracteres)
        : texto;
    setState(() {
      _compartido = true;
      _error = null;
    });
  }

  @override
  void didUpdateWidget(InicioScreen old) {
    super.didUpdateWidget(old);
    if (widget.enfocar && !old.enfocar) _foco.requestFocus();
  }

  @override
  void dispose() {
    _texto.dispose();
    _foco.dispose();
    super.dispose();
  }

  Future<void> _pegar() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) return;
    _texto.text = text.length > _maxCaracteres ? text.substring(0, _maxCaracteres) : text;
    setState(() => _error = null);
  }

  Future<void> _analizar() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final creado = await ref.read(analisisRepositoryProvider).crear(_texto.text);
      _texto.clear();
      _compartido = false;
      if (!mounted) return;
      await context.push('/analisis/${creado.id}');
      // Al volver, el historial ya trae el análisis nuevo.
      ref.invalidate(historialProvider);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 400) {
        setState(() => _error = 'No encontramos un enlace válido en el texto.');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_mensaje(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// La API manda 429 por dos razones distintas; cada una tiene su texto.
  String _mensaje(ApiException e) {
    if (!e.isRateLimited) return e.message;
    return e.message.contains('proceso')
        ? 'Ya tienes 3 análisis en proceso. Espera a que termine alguno.'
        : 'Llegaste al límite de 10 análisis por minuto. Espera un momento.';
  }

  @override
  Widget build(BuildContext context) {
    final historial = ref.watch(historialProvider);
    // Si la app ya estaba en Inicio cuando llegó un texto compartido.
    ref.listen(textoCompartidoProvider, (_, texto) {
      if (texto != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _tomarCompartido());
      }
    });

    return RefreshIndicator(
      onRefresh: () => ref.refresh(historialProvider.future),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const _Saludo(),
          const SizedBox(height: 28),
          Text('ANALIZA UN ENLACE', style: AppText.sectionLabel),
          const SizedBox(height: 6),
          Text('Pega el enlace o el mensaje completo tal como te llegó.',
              style: AppText.small),
          const SizedBox(height: 12),
          if (_compartido) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.share2, size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Recibimos un enlace compartido. Revísalo y toca Analizar enlace.',
                      style: AppText.small.copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _texto,
            focusNode: _foco,
            minLines: 5,
            maxLines: 5,
            maxLength: _maxCaracteres,
            keyboardType: TextInputType.multiline,
            style: AppText.mono.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText:
                  'Ej. BBVA: Tu cuenta fue bloqueada, ingresa a https://bbva-mx-seguridad.com para reactivarla',
              hintStyle: AppText.mono.copyWith(color: AppColors.textTertiary),
              hintMaxLines: 4,
              errorText: _error,
            ),
            buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                Text('$currentLength / $maxLength',
                    style: AppText.mono.copyWith(
                        fontSize: 12, color: AppColors.textTertiary)),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _pegar,
                icon: const Icon(LucideIcons.clipboard, size: 16),
                label: const Text('Pegar'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: AppText.small.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _texto.text.isEmpty
                    ? null
                    : () {
                        _texto.clear();
                        setState(() => _compartido = false);
                      },
                style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                child: const Text('Borrar'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LoadingButton(
            label: 'Analizar enlace',
            loading: _loading,
            onPressed: _texto.text.trim().isEmpty ? null : _analizar,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(LucideIcons.lock, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'La página se abre en un entorno aislado, nunca en tu celular.',
                  style: AppText.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          historial.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text(e is ApiException ? e.message : '$e', style: AppText.small),
            data: (items) => _ResumenYRecientes(items: items),
          ),
        ],
      ),
    );
  }
}

class _Saludo extends ConsumerWidget {
  const _Saludo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioActualProvider).valueOrNull;
    return InkWell(
      onTap: () => context.push('/cuenta'),
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.surface,
            child: Text(usuario?.iniciales ?? '', style: AppText.button),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hola,', style: AppText.small),
              Text(usuario?.nombre ?? '', style: AppText.h2),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResumenYRecientes extends StatelessWidget {
  const _ResumenYRecientes({required this.items});

  final List<AnalisisResumen> items;

  int _contar(Veredicto v) => items.where((i) => i.veredicto == v).length;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicHeight(
          child: Row(
            children: [
              _Numero(valor: items.length, etiqueta: 'Analizados'),
              const VerticalDivider(),
              _Numero(
                valor: _contar(Veredicto.peligroso),
                etiqueta: 'Peligrosos',
                color: AppColors.danger,
              ),
              const VerticalDivider(),
              _Numero(
                valor: _contar(Veredicto.sospechoso),
                etiqueta: 'Sospechosos',
                color: AppColors.suspicious,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Text('RECIENTES', style: AppText.sectionLabel),
            const Spacer(),
            if (items.isNotEmpty)
              TextButton(
                onPressed: () => context.go('/historial'),
                child: const Text('Ver todo'),
              ),
          ],
        ),
        if (items.isEmpty)
          const _SinAnalisis()
        else
          for (final item in items.take(3)) AnalisisRow(item: item),
      ],
    );
  }
}

class _Numero extends StatelessWidget {
  const _Numero({required this.valor, required this.etiqueta, this.color});

  final int valor;
  final String etiqueta;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text('$valor', style: AppText.number.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(etiqueta, style: AppText.caption.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _SinAnalisis extends StatelessWidget {
  const _SinAnalisis();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.tint(AppColors.primary),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.shield, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text('Aún no has analizado enlaces', style: AppText.body),
          const SizedBox(height: 4),
          Text('Cuando analices uno aparecerá aquí.', style: AppText.small),
        ],
      ),
    );
  }
}
