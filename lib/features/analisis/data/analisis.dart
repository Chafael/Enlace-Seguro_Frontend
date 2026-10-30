/// Estados por los que pasa un análisis en la API.
enum Estado {
  pendiente,
  procesando,
  terminado,
  error;

  static Estado parse(String? value) =>
      Estado.values.firstWhere((e) => e.name == value, orElse: () => Estado.error);

  /// true cuando ya no hay que seguir preguntando a la API.
  bool get esFinal => this == Estado.terminado || this == Estado.error;
}

/// Veredicto que calcula la API. En pantalla "seguro" se muestra como
/// "Sin amenazas detectadas", como dice la propuesta.
enum Veredicto {
  seguro,
  sospechoso,
  peligroso;

  static Veredicto? parse(String? value) {
    for (final v in Veredicto.values) {
      if (v.name == value) return v;
    }
    return null;
  }
}

/// Fila de GET /historial (sin captura ni razones).
class AnalisisResumen {
  const AnalisisResumen({
    required this.id,
    required this.url,
    required this.estado,
    required this.veredicto,
    required this.creadoEn,
  });

  final String id;
  final String url;
  final Estado estado;
  final Veredicto? veredicto;
  final DateTime creadoEn;

  /// "https://bbva-mx-seguridad.com/login" -> "bbva-mx-seguridad.com"
  String get dominio {
    final host = Uri.tryParse(url)?.host ?? '';
    return host.isEmpty ? url : host;
  }

  factory AnalisisResumen.fromJson(Map<String, dynamic> json) => AnalisisResumen(
        id: json['id'] as String,
        url: json['url'] as String,
        estado: Estado.parse(json['estado'] as String?),
        veredicto: Veredicto.parse(json['veredicto'] as String?),
        creadoEn: DateTime.parse(json['creadoEn'] as String).toLocal(),
      );
}

/// Respuesta completa de GET /analisis/{id}.
class Analisis extends AnalisisResumen {
  const Analisis({
    required super.id,
    required super.url,
    required super.estado,
    required super.veredicto,
    required super.creadoEn,
    required this.razones,
    required this.urlFinal,
    required this.captura,
    required this.desdeCache,
  });

  final List<String> razones;
  final String? urlFinal;

  /// PNG en base64 de la pantalla del Pixel 7. Puede venir vacía.
  final String? captura;
  final bool desdeCache;

  /// true si la página redirigió a otro lado.
  bool get redirige => urlFinal != null && urlFinal != url;

  factory Analisis.fromJson(Map<String, dynamic> json) => Analisis(
        id: json['id'] as String,
        url: json['url'] as String,
        estado: Estado.parse(json['estado'] as String?),
        veredicto: Veredicto.parse(json['veredicto'] as String?),
        creadoEn: DateTime.parse(json['creadoEn'] as String).toLocal(),
        razones: (json['razones'] as List? ?? const []).cast<String>(),
        urlFinal: json['urlFinal'] as String?,
        captura: (json['captura'] as String?)?.isEmpty ?? true
            ? null
            : json['captura'] as String,
        desdeCache: json['desdeCache'] as bool? ?? false,
      );
}
