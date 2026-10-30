import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/alert_box.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/labeled_field.dart';
import '../../../core/widgets/loading_button.dart';
import '../data/validators.dart';
import '../state/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.correoInicial});

  /// Llega desde "Cuenta creada" para no volver a escribir el correo.
  final String? correoInicial;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _correo = TextEditingController(text: widget.correoInicial);
  final _password = TextEditingController();

  bool _loading = false;
  String? _error;
  bool _blocked = false;
  Timer? _unblock;

  @override
  void dispose() {
    _correo.dispose();
    _password.dispose();
    _unblock?.cancel();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .login(_correo.text, _password.text);
      // El router detecta la sesión y abre Inicio solo.
    } on ApiException catch (e) {
      setState(() => _error = _messageFor(e));
      if (e.isRateLimited) _blockForOneMinute();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _messageFor(ApiException e) {
    if (e.isUnauthorized) return 'Correo o contraseña incorrectos.';
    if (e.isRateLimited) {
      return 'Demasiados intentos. Espera un minuto e inténtalo de nuevo.';
    }
    return e.message;
  }

  /// La API acepta 5 intentos por minuto. Si se pasa, el botón se
  /// desactiva ese minuto para no seguir mandando peticiones inútiles.
  void _blockForOneMinute() {
    setState(() => _blocked = true);
    _unblock?.cancel();
    _unblock = Timer(const Duration(minutes: 1), () {
      if (mounted) setState(() => _blocked = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final expired = ref.watch(authControllerProvider).expired;

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: AutofillGroup(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
              children: [
                const Align(alignment: Alignment.centerLeft, child: AppLogo()),
                const SizedBox(height: 24),
                Text('Inicia sesión', style: AppText.h1),
                const SizedBox(height: 4),
                Text('Analiza enlaces sospechosos sin abrirlos.',
                    style: AppText.small),
                const SizedBox(height: 32),
                if (expired && _error == null) ...[
                  const AlertBox(
                    icon: LucideIcons.clock,
                    color: AppColors.primary,
                    message:
                        'Tu sesión expiró. Por seguridad dura 1 hora; inicia sesión de nuevo.',
                  ),
                  const SizedBox(height: 20),
                ],
                LabeledField(
                  label: 'Correo electrónico',
                  hint: 'tucorreo@ejemplo.com',
                  icon: LucideIcons.mail,
                  controller: _correo,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: Validators.correo,
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Contraseña',
                  hint: '••••••••',
                  icon: LucideIcons.lock,
                  controller: _password,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  validator: Validators.passwordLogin,
                  onSubmitted: (_) => _submit(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  AlertBox(
                    message: _error!,
                    icon: _blocked ? LucideIcons.clock : LucideIcons.circleAlert,
                    color: _blocked ? AppColors.suspicious : AppColors.danger,
                  ),
                ],
                const SizedBox(height: 24),
                LoadingButton(
                  label: 'Iniciar sesión',
                  loading: _loading,
                  onPressed: _blocked ? null : _submit,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('¿No tienes cuenta?', style: AppText.small),
                    TextButton(
                      onPressed: () => context.push('/registro'),
                      child: const Text('Regístrate'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.lock,
                        size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 6),
                    Text('Tu sesión se guarda cifrada en este dispositivo.',
                        style: AppText.caption),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
