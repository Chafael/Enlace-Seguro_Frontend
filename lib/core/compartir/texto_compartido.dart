import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// Texto que llegó desde "Compartir" en WhatsApp o SMS y que Inicio
/// todavía no ha puesto en el campo. Inicio lo lee y lo regresa a null.
final textoCompartidoProvider = StateProvider<String?>((ref) => null);

/// Escucha lo que otras apps comparten con EnlaceSeguro (solo Android).
class ReceptorCompartir {
  ReceptorCompartir(this._onTexto);

  final void Function(String texto) _onTexto;
  StreamSubscription<List<SharedMediaFile>>? _sub;

  void iniciar() {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    final intent = ReceiveSharingIntent.instance;
    // App cerrada: se abrió desde "Compartir".
    intent.getInitialMedia().then((files) {
      _procesar(files);
      intent.reset();
    });
    // App abierta en segundo plano.
    _sub = intent.getMediaStream().listen(_procesar);
  }

  void _procesar(List<SharedMediaFile> files) {
    for (final f in files) {
      final esTexto = f.type == SharedMediaType.text || f.type == SharedMediaType.url;
      if (esTexto && f.path.trim().isNotEmpty) {
        _onTexto(f.path.trim());
        return;
      }
    }
  }

  void cancelar() => _sub?.cancel();
}
