import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_repository.dart';

enum AuthStatus { checking, signedOut, signedIn }

class AuthState {
  const AuthState(this.status, {this.expired = false, this.bienvenidaVista = true});

  final AuthStatus status;

  /// false solo la primera vez que se abre la app.
  final bool bienvenidaVista;

  /// true cuando la sesión terminó porque el token venció (401).
  final bool expired;
}

/// Sabe si hay sesión. El router lo escucha para decidir a qué pantalla ir.
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

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> _restore() async {
    // El splash se muestra al menos 800 ms para que no sea un parpadeo.
    final results = await Future.wait([
      _repo.hasValidToken(),
      ref.read(tokenStorageProvider).bienvenidaVista(),
      Future<void>.delayed(const Duration(milliseconds: 800)),
    ]);
    final hasToken = results[0] as bool;
    final vista = results[1] as bool;
    state = AuthState(
      hasToken ? AuthStatus.signedIn : AuthStatus.signedOut,
      bienvenidaVista: vista,
    );
  }

  Future<void> terminarBienvenida() async {
    await ref.read(tokenStorageProvider).marcarBienvenidaVista();
    state = AuthState(state.status);
  }

  Future<void> login(String correo, String password) async {
    await _repo.login(correo: correo, password: password);
    state = const AuthState(AuthStatus.signedIn);
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(AuthStatus.signedOut);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
