# Pasos 4 y 5: analizar un enlace y ver el resultado

Con este paso ya está el flujo completo de la demo: pegas un mensaje, la app lo manda a la API, espera el resultado preguntando cada 2 segundos y muestra el veredicto con sus razones y la captura. También quedaron la barra inferior, el Historial con filtros y Mi cuenta.

## Archivos nuevos

```
lib/
  app/app_shell.dart                      barra inferior: Inicio, Analizar, Historial
  core/utils/tiempo.dart                  "hace 5 min", "ayer", cronómetro 00:07
  core/widgets/url_box.dart               enlace en letra de código con botón de copiar
  features/
    analisis/
      data/analisis.dart                  modelos y enums (Estado, Veredicto)
      data/analisis_repository.dart       POST /analisis, GET /analisis/{id}, GET /historial
      ui/inicio_screen.dart               campo, contadores y recientes
      ui/analisis_screen.dart             espera mientras se analiza
      ui/resultado_view.dart              veredicto, razones y captura
      ui/veredicto_ui.dart                color, ícono y texto de cada veredicto
      ui/analisis_row.dart                fila de Recientes e Historial
    historial/ui/historial_screen.dart
    cuenta/ui/cuenta_screen.dart
```

## Decisiones que te pueden preguntar

**La app no extrae ni valida el enlace.** `crear(texto)` manda el texto tal cual. La API es la que encuentra el enlace dentro del mensaje. Si no hay ninguno, responde 400 y la app muestra "No encontramos un enlace válido en el texto." debajo del campo. Así la regla vive en un solo lugar, el servidor, y no hay dos versiones que puedan diferir.

**Una sola ruta para esperar y para ver el resultado.** `/analisis/:id` muestra la espera mientras el estado es `pendiente` o `procesando`, y cambia sola al resultado cuando llega `terminado` o `error`. Si alguien toca en el Historial un análisis que sigue en proceso, ve la espera y luego el resultado sin hacer nada más.

**Preguntar cada 2 segundos (polling).**

```dart
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
```

→ **StreamProvider** (proveedor de flujo) — entrega varios valores con el tiempo, no uno solo. La pantalla se redibuja con cada uno.
→ **family** (familia) — un proveedor distinto por cada `id`. Dos análisis no se mezclan.
→ **autoDispose** (desechar solo) — cuando la pantalla se cierra, Riverpod cancela el ciclo. Así la app deja de preguntar y no gasta peticiones del límite de 300 por minuto.
→ **async\*** y **yield** (generador) — cada `yield` manda un valor nuevo a la pantalla sin terminar la función.
→ **esFinal** — sale del ciclo con `terminado` o `error`, y ya no pregunta más.
→ **delayed(2 s)** — es el intervalo que pide el resumen del proyecto.

*Es todo el polling en 9 líneas, y se apaga solo al salir de la pantalla.*

**Los dos 429 tienen textos distintos.** La API responde 429 cuando ya tienes 3 análisis en proceso y también cuando pasas de 10 por minuto. La app revisa si el `detail` habla de "proceso" para elegir el mensaje del diseño que corresponde.

**El enlace nunca es tocable.** En `UrlBox` el enlace solo se puede copiar. La app no abre enlaces sospechosos en ningún momento. Solo los abre el sandbox.

**La captura.** La API manda un PNG en base64. `base64Decode` lo convierte a bytes e `Image.memory` lo muestra. El marco tiene la proporción del Pixel 7 (412 x 839). Al tocarla se abre en pantalla completa con zoom (`InteractiveViewer`). Si viene vacía, se muestra el aviso "No se pudo obtener la captura".

**"Seguro" se muestra como "Sin amenazas detectadas".** Está en `VerdictStyle`, que es el único lugar donde se decide el color, el ícono y el texto de cada veredicto. Para el estado `error` el título es "No se pudo analizar", con el botón "Intentar de nuevo", que vuelve a mandar el mismo enlace.

**Los contadores de Inicio y los filtros del Historial se calculan en la app** a partir de `GET /historial?limite=50`, el máximo que permite la API. No hay un endpoint de estadísticas, así que "Analizados" cuenta los últimos 50.

## Lo que falta

- Botón de compartir en Resultado (necesita el paquete `share_plus`).
- Recibir enlaces compartidos desde WhatsApp o SMS (`receive_sharing_intent`, solo en Android).
- Bienvenida de 3 páginas con las ilustraciones de Figma.
- Fuentes incluidas en `assets/` para no depender de internet en la demo.
