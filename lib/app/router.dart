import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/analisis/ui/analisis_screen.dart';
import '../features/analisis/ui/inicio_screen.dart';
import '../features/auth/state/auth_controller.dart';
import '../features/auth/ui/login_screen.dart';
import '../features/auth/ui/registro_listo_screen.dart';
import '../features/auth/ui/registro_screen.dart';
import '../features/bienvenida/ui/splash_screen.dart';
import '../features/cuenta/ui/cuenta_screen.dart';
import '../features/historial/ui/historial_screen.dart';
import 'app_shell.dart';

/// Rutas a las que se entra sin sesión.
const _publicas = {'/login', '/registro', '/registro/listo'};

final routerProvider = Provider<GoRouter>((ref) {
  // Cada vez que cambia la sesión, el router vuelve a evaluar "redirect".
  final refresh = ValueNotifier(0);
  ref.listen(authControllerProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final status = ref.read(authControllerProvider).status;
      final location = state.matchedLocation;

      if (status == AuthStatus.checking) {
        return location == '/splash' ? null : '/splash';
      }
      if (status == AuthStatus.signedOut) {
        return _publicas.contains(location) ? null : '/login';
      }
      // Con sesión: no tiene sentido ver splash, login o registro.
      if (location == '/splash' || _publicas.contains(location)) {
        return '/inicio';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: '/login',
        builder: (_, state) =>
            LoginScreen(correoInicial: state.extra as String?),
      ),
      GoRoute(path: '/registro', builder: (_, _) => const RegistroScreen()),
      GoRoute(
        path: '/registro/listo',
        builder: (_, state) =>
            RegistroListoScreen(correo: state.extra as String?),
      ),
      // Pantallas con barra inferior.
      ShellRoute(
        builder: (_, state, child) =>
            AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: '/inicio',
            pageBuilder: (_, state) => NoTransitionPage(
              child: InicioScreen(
                enfocar: state.uri.queryParameters['analizar'] == '1',
              ),
            ),
          ),
          GoRoute(
            path: '/historial',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: HistorialScreen()),
          ),
        ],
      ),
      // Pantallas completas, sin barra.
      GoRoute(
        path: '/analisis/:id',
        builder: (_, state) => AnalisisScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(path: '/cuenta', builder: (_, _) => const CuentaScreen()),
    ],
  );
});
