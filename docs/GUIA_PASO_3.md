# Paso 3: sesión, router, iniciar sesión y crear cuenta

Con este paso la app ya habla con la API de verdad. Puedes crear una cuenta, iniciar sesión y ver tu nombre (lo trae `GET /yo`). Si el token vence, la app te regresa al login con un aviso.

## Archivos nuevos

```
lib/
  app/router.dart                       qué pantalla toca según la sesión
  core/widgets/                         piezas que se repiten en varias pantallas
    app_logo.dart                       escudo con eslabón y "EnlaceSeguro"
    alert_box.dart                      caja de aviso (error, demasiados intentos)
    labeled_field.dart                  campo con etiqueta arriba y ojo para la contraseña
    loading_button.dart                 botón azul con spinner
  features/
    auth/
      data/usuario.dart                 modelo de GET /yo
      data/auth_repository.dart         login, registro, yo, revisar token
      data/validators.dart              validaciones del formulario
      data/password_strength.dart       barra de seguridad de la contraseña
      state/auth_controller.dart        estado de la sesión
      ui/login_screen.dart
      ui/registro_screen.dart
      ui/registro_listo_screen.dart
    bienvenida/ui/splash_screen.dart
    analisis/ui/inicio_screen.dart      temporal, se completa en el paso 4
```

## Cómo fluye todo

1. La app abre en `/splash`. `AuthController` revisa si hay un token guardado y si todavía no vence.
2. Si hay token, el router manda a `/inicio`. Si no, a `/login`.
3. En el login, `AuthController.login` llama a la API y guarda el token. El estado cambia a `signedIn`, el router lo detecta y abre Inicio. La pantalla no navega por su cuenta.
4. Si la API responde 401 en una ruta protegida, `ApiClient` avisa, el estado pasa a `signedOut` con `expired: true` y el router regresa al login, donde aparece "Tu sesión expiró".

Las pantallas no deciden a dónde ir después de iniciar o cerrar sesión. Esa decisión vive en un solo lugar, el router, así que no hay forma de quedar en Inicio sin token.

---

## auth_repository.dart

### Bloque 1: login y registro

```dart
Future<void> login({required String correo, required String password}) async {
  final data = await _api.post('/auth/login', body: {'correo': correo.trim(), 'password': password});
  await _tokens.save(data['token'] as String);
}
```

→ **required** (requerido) — obliga a pasar los dos datos por nombre, así no se confunden de orden.
→ **trim()** (recortar) — quita los espacios que a veces agrega el teclado al final del correo. A la contraseña no se le aplica, porque un espacio puede ser parte de ella.
→ **_api.post** — usa el cliente del paso 2, así que los errores ya llegan como `ApiException`.
→ **_tokens.save** — guarda el token cifrado. Si el login falla, esta línea nunca corre.

*Inicia sesión y guarda el token. Registro es igual, pero no guarda nada: la API solo crea la cuenta y no regresa token.*

### Bloque 2: revisar si el token ya venció

```dart
static bool _isExpired(String token) {
  final payload = token.split('.')[1];
  final json = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(payload))));
  final vence = DateTime.fromMillisecondsSinceEpoch((json['exp'] as num).toInt() * 1000);
  return DateTime.now().isAfter(vence.subtract(const Duration(seconds: 30)));
}
```

→ **split('.')[1]** (partir) — un JWT tiene tres partes separadas por puntos: encabezado, datos y firma. La segunda trae `exp`.
→ **base64Url.normalize** (normalizar) — los JWT quitan el relleno `=` del base64. Esto lo vuelve a poner para poder decodificar.
→ **exp** (expiración) — los segundos desde 1970 en que vence el token. La API lo pone a 1 hora.
→ **subtract(30 s)** (restar) — da por vencido el token 30 segundos antes, para no mandarlo justo cuando está por caducar.
→ **catch → true** — si el token está dañado, se trata como vencido.

*Evita que, al abrir la app con un token viejo, se muestre Inicio un instante y luego salte al login. La firma no se revisa aquí, porque eso le toca a la API. Esto solo lee la fecha.*

## auth_controller.dart

```dart
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    final sub = ref.watch(apiClientProvider).onSessionExpired.listen((_) {
      state = const AuthState(AuthStatus.signedOut, expired: true);
    });
    ref.onDispose(sub.cancel);
    unawaited(_restore());
    return const AuthState(AuthStatus.checking);
  }
```

→ **Notifier** (notificador) — una clase de Riverpod que guarda un estado y avisa a quien lo escucha cuando cambia.
→ **AuthStatus** — tres estados: `checking` (revisando), `signedOut` (sin sesión) y `signedIn` (con sesión).
→ **onSessionExpired.listen** (escuchar) — se suscribe al aviso de 401 que creamos en `ApiClient`.
→ **ref.onDispose(sub.cancel)** (al desechar) — si el controlador se destruye, cancela la suscripción y no queda memoria colgada.
→ **unawaited(_restore())** (sin esperar) — empieza a revisar el token sin bloquear. Mientras tanto el estado es `checking` y se ve el splash.
→ **Future.wait** (dentro de `_restore`) — espera a la vez la revisión del token y 800 ms. Así el splash no parpadea si la revisión es instantánea.

*Lleva el estado de la sesión de toda la app. Login y logout solo cambian este estado. Lo demás reacciona solo.*

## router.dart

```dart
ref.listen(authControllerProvider, (_, _) => refresh.value++);
return GoRouter(
  initialLocation: '/splash',
  refreshListenable: refresh,
  redirect: (context, state) {
    final status = ref.read(authControllerProvider).status;
    if (status == AuthStatus.checking) return location == '/splash' ? null : '/splash';
    if (status == AuthStatus.signedOut) return _publicas.contains(location) ? null : '/login';
    if (location == '/splash' || _publicas.contains(location)) return '/inicio';
    return null;
  },
```

→ **refreshListenable** (escuchable para refrescar) — cuando su valor cambia, GoRouter vuelve a correr `redirect`. Sube cada vez que cambia la sesión.
→ **redirect** (redirigir) — se ejecuta antes de mostrar cualquier pantalla. Si regresa una ruta, manda ahí. Si regresa `null`, deja pasar.
→ **_publicas** — login, registro y "cuenta creada" son las únicas pantallas sin sesión.
→ **return '/inicio'** — con sesión no tiene sentido volver al login. Si alguien lo intenta, va a Inicio.

*Es el guardia de la app: sin token no se entra a nada protegido, y la regla está escrita una sola vez.*

## login_screen.dart

### Bloque 1: enviar el formulario

```dart
if (!_formKey.currentState!.validate()) return;
try {
  await ref.read(authControllerProvider.notifier).login(_correo.text, _password.text);
} on ApiException catch (e) {
  setState(() => _error = _messageFor(e));
  if (e.isRateLimited) _blockForOneMinute();
}
```

→ **validate()** (validar) — corre las validaciones de cada campo. Si alguna falla, se pinta en rojo y no se llama a la API.
→ **.notifier** — da acceso a los métodos del controlador (`login`), no solo a su estado.
→ **on ApiException** — atrapa solo errores de la API. Un error de programación no se escondería aquí.
→ **_messageFor** — para 401 y 429 usa los textos del diseño con acentos ("contraseña"). Para lo demás, el `detail` de la API.

*Valida, llama a la API y muestra el error en la caja roja si algo falla.*

### Bloque 2: límite de intentos

```dart
void _blockForOneMinute() {
  setState(() => _blocked = true);
  _unblock = Timer(const Duration(minutes: 1), () {
    if (mounted) setState(() => _blocked = false);
  });
}
```

→ **Timer** (temporizador) — corre una función después de un tiempo.
→ **mounted** (montado) — revisa que la pantalla siga abierta antes de actualizarla. Si el usuario ya salió, no hace nada.

*La API solo deja 5 logins por minuto. Al recibir 429, el botón se desactiva ese minuto y la caja se pone amarilla con un reloj, como en el diseño "demasiados intentos".*

## registro_screen.dart

```dart
} on ApiException catch (e) {
  if (e.statusCode == 409) {
    _correoError = 'Ya existe una cuenta con este correo.';
  } else {
    _error = e.message;
  }
}
```

→ **409** (conflicto) — la API lo responde cuando el correo ya está registrado. El error se muestra debajo del campo de correo, como en Figma.
→ **context.go('/registro/listo', extra: correo)** — si todo sale bien, abre "Tu cuenta está lista" y le pasa el correo. Luego el login aparece ya con el correo escrito.

*Crea la cuenta y pone cada error donde corresponde: el de correo repetido en su campo y los demás en la caja de aviso.*

## password_strength.dart

Suma un punto por cada regla: 8 caracteres o más, 12 o más, mayúsculas y minúsculas, y números con símbolos. El resultado llena de 0 a 4 segmentos de la barra. Es solo una guía para el usuario. Lo único obligatorio es el mínimo de 8 que exige la API.

## Pruebas

`flutter test` ahora también revisa la fuerza de la contraseña y la validación del correo.

## Probar en Chrome

Tu API no tiene CORS activado. El navegador bloquea las peticiones de `localhost:XXXX` (la app web) a `localhost:8000` (la API) aunque la API responda bien. En el emulador o en el celular eso no pasa, porque CORS es una regla solo de los navegadores. Para probar en Chrome hay que agregar `@fastify/cors` a la API y permitir solo orígenes `http://localhost:*` en desarrollo.
