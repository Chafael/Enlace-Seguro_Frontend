# Paso 6: Bienvenida, compartir y fuentes sin internet

## Bienvenida y Splash

- El Splash tiene de fondo la ilustración de Figma (`assets/ilustraciones/splash_fondo.svg`): anillos y cuadrícula de puntos centrados en el logo.
- La Bienvenida tiene 3 páginas con las ilustraciones planas de Figma. Se puede deslizar, saltar con "Omitir" o avanzar con "Siguiente".
- Solo aparece la primera vez. `TokenStorage.marcarBienvenidaVista()` guarda una marca, y `AuthController` la lee al arrancar junto con el token. El router decide igual que con la sesión: sin sesión y sin haber visto la Bienvenida, va a `/bienvenida`.
- La marca no se borra al cerrar sesión, porque la Bienvenida explica la app y no tiene que ver con la cuenta.

## Recibir enlaces desde WhatsApp o SMS

Esto lo promete la propuesta. Hay tres piezas:

1. `AndroidManifest.xml` tiene un `intent-filter` con `action.SEND` y `text/plain`. Eso hace que EnlaceSeguro aparezca en el menú "Compartir" de Android.
2. `ReceptorCompartir` (en `core/compartir/`) escucha lo que llega, con la app cerrada (`getInitialMedia`) o abierta (`getMediaStream`). Solo corre en Android: en Chrome no hace nada.
3. El texto se guarda en `textoCompartidoProvider` y la app va a `/inicio`. Inicio lo pone en el campo con el aviso "Recibimos un enlace compartido".

Hay dos decisiones aquí:
- **No se analiza solo.** El usuario ve qué llegó y toca "Analizar enlace". Así no se gasta un análisis por un toque accidental y el usuario sabe qué se está revisando.
- **Si no hay sesión, el texto espera.** Queda guardado en el provider. El router manda al login y, al entrar, Inicio lo toma.

Para probarlo en el celular: abre WhatsApp, mantén presionado un mensaje, toca Compartir y elige EnlaceSeguro.

## Compartir el resultado

El botón de compartir en Resultado usa `share_plus` y manda el veredicto, el enlace y las razones como texto. El enlace va desactivado con `defang`:

```dart
String defang(String url) => url
    .replaceFirst(RegExp(r'^http', caseSensitive: false), 'hxxp')
    .replaceAll('.', '[.]');
```

→ **replaceFirst** (reemplazar el primero) — cambia `http` por `hxxp` al inicio, así las apps de mensajes ya no lo reconocen como enlace y no lo hacen tocable.
→ **caseSensitive: false** (sin distinguir mayúsculas) — también funciona con `HTTP://`.
→ **replaceAll('.', '[.]')** (reemplazar todos) — `bbva.com` queda `bbva[.]com`.

*Es la forma en que los equipos de seguridad comparten URLs maliciosas en reportes. Si alguien reenvía un resultado "Peligroso", nadie abre el sitio por error.*

## Fuentes dentro de la app

Se quitó `google_fonts`. IBM Plex Sans y Plex Mono (Regular, Medium y SemiBold) están en `assets/fonts/` y se declaran en `pubspec.yaml`. Antes, la primera vez que se abría la app descargaba la fuente desde Google, y en una demo sin internet se veía con la letra del sistema. La licencia de las fuentes (SIL OFL) va en `assets/fonts/OFL.txt` y permite incluirlas en la app.
