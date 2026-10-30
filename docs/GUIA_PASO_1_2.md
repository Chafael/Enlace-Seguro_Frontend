# Pasos 1 y 2: tema y cliente de la API

Esta guía explica los archivos de la rama `feature/base-app`. El paso 1 pasa los colores y las letras de Figma a código. El paso 2 deja listo el único lugar por donde la app habla con la API.

## Cómo probarlo

1. Levanta la API en la PC (`docker compose up -d` en `C:\Dev\enlaceseguro`).
2. Saca la IP de tu PC con `ipconfig` (por ejemplo `192.168.1.50`).
3. Corre la app con esa IP:

```powershell
flutter run --dart-define=API_URL=http://192.168.1.50:8000
```

Si usas el emulador de Android no hace falta la IP: por defecto se usa `http://10.0.2.2:8000`, que es la forma en que el emulador ve el `localhost` de la PC.

4. Corre `flutter analyze` y `flutter test`. Los dos deben terminar sin errores.

Por ahora la app solo muestra una pantalla de prueba con textos, un campo y botones, para comparar contra Figma. Se reemplaza en el paso 3.

## Estructura

```
lib/
  main.dart
  core/
    theme/    app_colors.dart, app_text.dart, app_theme.dart
    config/   env.dart
    storage/  token_storage.dart
    api/      api_client.dart, api_exception.dart
```

Todo lo de `core/` lo usan varias pantallas. Lo que es de una sola función (login, análisis, historial) irá después en `features/`.

---

## app_colors.dart

```dart
class AppColors {
  AppColors._();
  static const background = Color(0xFF0A1220);
  static const primary = Color(0xFF2F7BF5);
  ...
  static Color tint(Color color) => color.withValues(alpha: 0.12);
}
```

→ **class** (clase) — un contenedor con nombre; aquí solo guarda constantes.
→ **AppColors._()** (constructor privado) — el guion bajo impide hacer `AppColors()`. No tiene sentido crear objetos de esta clase, solo leer sus colores.
→ **static const** (estático y constante) — el valor existe una sola vez y se fija al compilar. Se usa como `AppColors.primary`.
→ **Color(0xFF2F7BF5)** (color) — `FF` es la opacidad completa y lo demás es el hexadecimal de Figma.
→ **tint** (tinte) — devuelve el mismo color al 12 % de opacidad. Es el fondo suave de las pastillas "Peligroso", "Sospechoso", etc.
→ **withValues(alpha: 0.12)** (con valores) — cambia solo la transparencia. Es el reemplazo actual de `withOpacity`, que ya está marcado como obsoleto.

*Guarda los colores de Figma en un solo lugar. Si un color cambia, se cambia aquí y se actualiza toda la app.*

## app_text.dart

```dart
static TextStyle _sans(double size, double height, FontWeight weight, [Color color = AppColors.textPrimary]) =>
    GoogleFonts.ibmPlexSans(fontSize: size, height: height / size, fontWeight: weight, color: color);

static final h1 = _sans(26, 32, FontWeight.w600);
static final sectionLabel = GoogleFonts.ibmPlexMono(fontSize: 11, letterSpacing: 1.2, ...);
```

→ **_sans** (función privada) — fabrica estilos de IBM Plex Sans para no repetir los mismos cuatro datos en cada uno.
→ **[Color color = ...]** (parámetro opcional) — si no se manda color, usa el texto principal.
→ **height: height / size** (alto de línea) — Figma da el interlineado en píxeles (32) y Flutter lo pide como proporción del tamaño (32 / 26).
→ **FontWeight.w600** (peso 600) — SemiBold, como los títulos en Figma.
→ **static final** (estático final) — no puede ser `const` porque `GoogleFonts` arma el estilo al ejecutarse.
→ **ibmPlexMono** (fuente monoespaciada) — se usa en enlaces y etiquetas. Todas las letras miden lo mismo, y eso le da el toque técnico.
→ **letterSpacing: 1.2** (espacio entre letras) — las etiquetas como "RECIENTES" van separadas, igual que en el diseño.

*Define una vez cada tamaño de letra del diseño (h1, h2, body, small, caption, mono). Las pantallas solo eligen cuál usar.*

Nota: `google_fonts` descarga la fuente la primera vez que abre la app. Para la demo final conviene incluir las fuentes en `assets/` y así no depender de internet. Se hace en la semana 6.

## app_theme.dart

```dart
static ThemeData get dark => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme.dark(primary: AppColors.primary, ...),
  filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
    minimumSize: const Size.fromHeight(52), ...)),
  inputDecorationTheme: InputDecorationTheme(
    focusedBorder: _border(AppColors.primary),
    errorBorder: _border(AppColors.danger), ...),
  ...
);
```

→ **ThemeData** (datos del tema) — la configuración visual que Flutter aplica a todos los widgets de Material.
→ **get dark** (obtener oscuro) — un getter: se lee como `AppTheme.dark` sin paréntesis.
→ **useMaterial3** (usar Material 3) — la versión actual de los componentes de Google.
→ **scaffoldBackgroundColor** (color de fondo del andamio) — el azul marino de fondo en todas las pantallas.
→ **ColorScheme.dark** (esquema oscuro) — los colores base que leen los widgets cuando no se les indica otro.
→ **filledButtonTheme** (tema del botón relleno) — el botón azul principal: 52 px de alto, esquinas de 12 y el gris de deshabilitado.
→ **Size.fromHeight(52)** (tamaño desde alto) — alto fijo de 52 y ancho completo, como "Analizar enlace".
→ **outlinedButtonTheme** (botón con borde) — el botón secundario, por ejemplo "Seguir en segundo plano".
→ **inputDecorationTheme** (decoración de campos) — fondo, borde normal, borde azul al enfocar y borde rojo con error.
→ **snackBarTheme** (tema del aviso) — los avisos flotantes de "Sin conexión" o "Demasiados análisis".

*Gracias a esto, un `FilledButton` o un `TextField` común ya salen como en Figma. Las pantallas quedan más cortas y todas se ven iguales.*

---

## env.dart

```dart
static const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8000');
```

→ **String.fromEnvironment** (texto desde el entorno) — lee el valor que se pasa con `--dart-define=API_URL=...` al compilar.
→ **defaultValue** (valor por defecto) — si no se manda nada, usa la dirección del emulador.

*La dirección de la API no queda escrita a mano en el código. Cada quien la cambia al correr la app, y en producción se pasaría la URL con HTTPS.*

## token_storage.dart

```dart
class TokenStorage {
  Future<String?> read() => _storage.read(key: _key);
  Future<void> save(String token) => _storage.write(key: _key, value: token);
  Future<void> clear() => _storage.delete(key: _key);
}
final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage(const FlutterSecureStorage()));
```

→ **FlutterSecureStorage** (almacenamiento seguro) — en Android cifra los datos con llaves del Keystore del sistema. Otra app no puede leer el token y tampoco queda en texto plano como en `SharedPreferences`.
→ **Future** (futuro) — leer o guardar tarda un poco, así que se espera con `await`.
→ **String?** (texto o nulo) — si el usuario no ha iniciado sesión, no hay token y regresa `null`.
→ **clear** (borrar) — se usa al cerrar sesión y cuando el token vence.
→ **Provider** (proveedor) — Riverpod crea una sola instancia y se la da a quien la pida. En las pruebas se puede cambiar por una falsa.

*Envuelve el almacenamiento seguro en tres operaciones simples: leer, guardar y borrar el token. Cumple lo que promete la propuesta sobre guardar el token cifrado.*

## api_exception.dart

```dart
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});
  bool get isUnauthorized => statusCode == 401;
  bool get isRateLimited => statusCode == 429;
}
```

→ **implements Exception** (implementa excepción) — se puede lanzar con `throw` y atrapar con `try/catch`.
→ **message** (mensaje) — un texto ya listo para mostrarse al usuario.
→ **statusCode** (código de estado) — el código HTTP, por si una pantalla necesita reaccionar distinto ante un 401 o un 429.

*Todas las fallas de red o de la API llegan a las pantallas en la misma forma, así que no tienen que entender Dio.*

## api_client.dart

### Bloque 1: configuración de Dio

```dart
ApiClient(this._tokens) : _dio = Dio(BaseOptions(
  baseUrl: Env.apiUrl,
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 15),
  contentType: Headers.jsonContentType,
)) {
  _dio.interceptors.add(InterceptorsWrapper(onRequest: _addToken, onError: _onError));
}
```

→ **baseUrl** (URL base) — así las llamadas se escriben corto: `post('/analisis')`.
→ **connectTimeout** (tiempo para conectar) — si en 10 segundos no se conecta, se da por perdido y se muestra "Sin conexión".
→ **receiveTimeout** (tiempo para recibir) — 15 segundos como máximo para la respuesta. El análisis no tarda tanto porque la API responde 202 enseguida y el resultado se pide después.
→ **contentType** (tipo de contenido) — todo se manda como JSON, que es lo que espera Fastify.
→ **interceptors** (interceptores) — funciones que corren antes de cada petición y después de cada error, sin repetir código en cada pantalla.

*Crea el cliente HTTP con la dirección de la API, los tiempos límite y dos interceptores.*

### Bloque 2: agregar el token

```dart
Future<void> _addToken(RequestOptions options, RequestInterceptorHandler handler) async {
  if (!_isAuthRoute(options.path)) {
    final token = await _tokens.read();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
  }
  handler.next(options);
}
```

→ **_isAuthRoute** (es ruta de auth) — `/auth/login` y `/auth/registro` no llevan token, porque es justo donde se consigue.
→ **headers['Authorization']** (encabezado de autorización) — la API valida aquí el JWT. Es el formato que pide su contrato: `Bearer <token>`.
→ **handler.next** (siguiente) — deja que la petición continúe.

*Pone el token en todas las peticiones protegidas. Ninguna pantalla tiene que acordarse de hacerlo.*

### Bloque 3: sesión vencida

```dart
final isExpired = error.response?.statusCode == 401 && !_isAuthRoute(error.requestOptions.path);
if (isExpired) {
  await _tokens.clear();
  _sessionExpired.add(null);
}
```

→ **statusCode == 401** (no autorizado) — el token dura 1 hora. Después, la API responde 401.
→ **!_isAuthRoute** — un 401 en el login significa contraseña incorrecta, no sesión vencida. Por eso se excluye.
→ **_tokens.clear()** — borra el token viejo para no seguir mandándolo.
→ **_sessionExpired.add** (emitir) — avisa por un `Stream`. En el paso 3 el router lo escucha y muestra "Tu sesión expiró".

*Detecta en un solo lugar que el token venció y avisa al resto de la app.*

### Bloque 4: convertir errores

```dart
if (response == null) {
  return const ApiException('No pudimos conectar con el servidor. Revisa tu conexión.');
}
final detail = data is Map && data['detail'] is String ? data['detail'] as String : 'Ocurrió un error inesperado. Intenta de nuevo.';
return ApiException(detail, statusCode: response.statusCode);
```

→ **response == null** (sin respuesta) — no hubo respuesta: la PC está apagada, la IP es incorrecta o el celular no tiene red.
→ **data['detail']** (detalle) — la API siempre manda los errores como `{ "detail": "mensaje" }`. Ese texto se muestra tal cual, como pide el resumen del proyecto para los errores 400 y 429.
→ **data is Map** (es un mapa) — se revisa el tipo antes de leerlo, por si algún error no viene en JSON. Así la app no truena.

*Traduce cualquier falla de Dio a un `ApiException` con un mensaje en español.*

---

## Cambios en Android

`android/app/src/main/AndroidManifest.xml`
- Se agregó el permiso `INTERNET`. Sin él, la versión release no puede hacer peticiones (la de debug ya lo traía).
- El nombre visible de la app ahora es "EnlaceSeguro".

`android/app/src/debug/AndroidManifest.xml`
- `android:usesCleartextTraffic="true"` permite HTTP sin cifrar, pero solo en debug. La API corre en la PC por `http://...:8000` y Android bloquea HTTP por defecto. Como está en el manifiesto de debug, la versión release no lo hereda y sigue exigiendo HTTPS. Esto coincide con la propuesta, que dice que el despliegue real iría por HTTPS.

## Pruebas

`test/widget_test.dart` revisa que los colores sean los de Figma y que `ApiException` reconozca el 401 y el 429. Reemplaza la prueba del contador que trae `flutter create`, porque esa ya no compilaba.
