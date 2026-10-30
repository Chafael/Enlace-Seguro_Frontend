/// Usuario que regresa GET /yo.
class Usuario {
  const Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    this.creadoEn,
  });

  final String id;
  final String nombre;
  final String correo;
  final DateTime? creadoEn;

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'] as String,
        nombre: json['nombre'] as String,
        correo: json['correo'] as String,
        creadoEn: DateTime.tryParse(json['creadoEn'] as String? ?? ''),
      );

  /// "Carlos Rafael Ruiz" -> "CR", para el avatar.
  String get iniciales {
    final partes = nombre.trim().split(RegExp(r'\s+'));
    return partes.take(2).map((p) => p[0].toUpperCase()).join();
  }
}
