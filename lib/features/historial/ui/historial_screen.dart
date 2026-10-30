import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../analisis/data/analisis.dart';
import '../../analisis/data/analisis_repository.dart';
import '../../analisis/ui/analisis_row.dart';

enum _Filtro { todos, peligroso, sospechoso, seguro, error }

const _etiquetas = {
  _Filtro.todos: 'Todos',
  _Filtro.peligroso: 'Peligroso',
  _Filtro.sospechoso: 'Sospechoso',
  _Filtro.seguro: 'Sin amenazas',
  _Filtro.error: 'Error',
};

class HistorialScreen extends ConsumerStatefulWidget {
  const HistorialScreen({super.key});

  @override
  ConsumerState<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends ConsumerState<HistorialScreen> {
  _Filtro _filtro = _Filtro.todos;

  /// El filtro se aplica en la app: la API ya regresa los 50 más recientes.
  bool _pasa(AnalisisResumen a) => switch (_filtro) {
        _Filtro.todos => true,
        _Filtro.error => a.estado == Estado.error,
        _Filtro.peligroso => a.veredicto == Veredicto.peligroso,
        _Filtro.sospechoso => a.veredicto == Veredicto.sospechoso,
        _Filtro.seguro => a.veredicto == Veredicto.seguro,
      };

  @override
  Widget build(BuildContext context) {
    final historial = ref.watch(historialProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(historialProvider.future),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text('Historial', style: AppText.h1),
          const SizedBox(height: 2),
          Text('Tus últimos análisis', style: AppText.small),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final f in _Filtro.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _Chip(
                      texto: _etiquetas[f]!,
                      activo: f == _filtro,
                      onTap: () => setState(() => _filtro = f),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          historial.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(e is ApiException ? e.message : '$e', style: AppText.small),
            ),
            data: (items) {
              final visibles = items.where(_pasa).toList();
              if (visibles.isEmpty) return const _Vacio();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _agrupar(visibles),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Separa la lista en HOY, AYER y fechas anteriores.
  List<Widget> _agrupar(List<AnalisisResumen> items) {
    final now = DateTime.now();
    final hoy = DateTime(now.year, now.month, now.day);
    String grupo(DateTime f) {
      final d = hoy.difference(DateTime(f.year, f.month, f.day)).inDays;
      if (d == 0) return 'HOY';
      if (d == 1) return 'AYER';
      if (d < 7) return 'ESTA SEMANA';
      return 'ANTERIORES';
    }

    final widgets = <Widget>[];
    String? actual;
    for (final item in items) {
      final g = grupo(item.creadoEn);
      if (g != actual) {
        actual = g;
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 4),
          child: Text(g, style: AppText.sectionLabel),
        ));
      }
      final hora = g == 'HOY' || g == 'AYER'
          ? DateFormat('HH:mm').format(item.creadoEn)
          : DateFormat('dd/MM').format(item.creadoEn);
      widgets.add(AnalisisRow(item: item, tiempo: hora));
    }
    return widgets;
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.texto, required this.activo, required this.onTap});

  final String texto;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: activo ? AppColors.tint(AppColors.primary) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: activo ? Colors.transparent : AppColors.line),
        ),
        child: Text(
          texto,
          style: AppText.small.copyWith(
            color: activo ? AppColors.primary : AppColors.textSecondary,
            fontWeight: activo ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _Vacio extends StatelessWidget {
  const _Vacio();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.tint(AppColors.primary),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.history, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text('Todavía no hay análisis', style: AppText.body),
          const SizedBox(height: 4),
          Text('Pega un enlace en Inicio para empezar.', style: AppText.small),
        ],
      ),
    );
  }
}
