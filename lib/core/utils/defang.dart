/// "Desactiva" un enlace para compartirlo sin que nadie lo abra por error:
/// https://bbva.com -> hxxps://bbva[.]com
/// Es la convención que usan los equipos de seguridad al reportar URLs.
String defang(String url) => url
    .replaceFirst(RegExp(r'^http', caseSensitive: false), 'hxxp')
    .replaceAll('.', '[.]');
