import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/analisis/ui/inicio_screen.dart';
import '../features/auth/state/auth_controller.dart';
import '../features/auth/ui/login_screen.dart';
import '../features/auth/ui/registro_listo_screen.dart';
import '../features/auth/ui/registro_screen.dart';
import '../features/bienvenida/ui/splash_screen.dart';

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
      GoRoute(path: '/inicio', builder: (_, _) => const InicioScreen()),
    ],
  );
});
