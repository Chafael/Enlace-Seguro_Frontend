import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../data/auth_repository.dart';

enum AuthStatus { checking, signedOut, signedIn }

class AuthState {
  const AuthState(this.status, {this.expired = false});

  final AuthStatus status;

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
      Future<void>.delayed(const Duration(milliseconds: 800)),
    ]);
    final hasToken = results.first as bool;
    state = AuthState(hasToken ? AuthStatus.signedIn : AuthStatus.signedOut);
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
