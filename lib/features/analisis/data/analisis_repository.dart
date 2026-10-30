import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import 'analisis.dart';

class AnalisisRepository {
  AnalisisRepository(this._api);

  final ApiClient _api;

  /// Manda el texto tal cual (enlace o mensaje completo). La API extrae
  /// y valida el enlace; la app no lo hace. Regresa el id del análisis.
  Future<({String id, String url})> crear(String texto) async {
    final data = await _api.post('/analisis', body: {'texto': texto});
    return (id: data['id'] as String, url: data['url'] as String);
  }

  Future<Analisis> obtener(String id) async {
    final data = await _api.get('/analisis/$id');
    return Analisis.fromJson(data as Map<String, dynamic>);
  }

  Future<List<AnalisisResumen>> historial({int limite = 50}) async {
    final data = await _api.get('/historial', query: {'limite': limite});
    return (data as List)
        .map((e) => AnalisisResumen.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final analisisRepositoryProvider = Provider<AnalisisRepository>(
  (ref) => AnalisisRepository(ref.watch(apiClientProvider)),
);

/// Últimos 50 análisis del usuario (máximo que permite la API).
final historialProvider = FutureProvider.autoDispose<List<AnalisisResumen>>(
  (ref) => ref.watch(analisisRepositoryProvider).historial(),
);

/// Pregunta por un análisis cada 2 segundos hasta que termine.
/// Al cerrar la pantalla, autoDispose cancela el ciclo y deja de preguntar.
final analisisEnCursoProvider =
    StreamProvider.autoDispose.family<Analisis, String>((ref, id) async* {
  final repo = ref.watch(analisisRepositoryProvider);
  while (true) {
    final analisis = await repo.obtener(id);
    yield analisis;
    if (analisis.estado.esFinal) break;
    await Future<void>.delayed(const Duration(seconds: 2));
  }
});
