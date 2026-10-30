import 'package:intl/intl.dart';

/// "hace 5 min", "ayer", "hace 2 días" o la fecha corta.
String hace(DateTime fecha, {DateTime? ahora}) {
  final now = ahora ?? DateTime.now();
  final diff = now.difference(fecha);
  if (diff.inMinutes < 1) return 'ahora';
  if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
  if (diff.inHours < 24 && now.day == fecha.day) return 'hace ${diff.inHours} h';
  final hoy = DateTime(now.year, now.month, now.day);
  final dia = DateTime(fecha.year, fecha.month, fecha.day);
  final dias = hoy.difference(dia).inDays;
  if (dias == 1) return 'ayer';
  if (dias < 7) return 'hace $dias días';
  return DateFormat('dd/MM/yy').format(fecha);
}

/// 7 segundos -> "00:07"
String cronometro(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}
