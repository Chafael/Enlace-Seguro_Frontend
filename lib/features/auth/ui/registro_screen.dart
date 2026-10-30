import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/alert_box.dart';
import '../../../core/widgets/labeled_field.dart';
import '../../../core/widgets/loading_button.dart';
import '../data/auth_repository.dart';
import '../data/password_strength.dart';
import '../data/validators.dart';

class RegistroScreen extends ConsumerStatefulWidget {
  const RegistroScreen({super.key});

  @override
  ConsumerState<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends ConsumerState<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  String? _correoError;
  String? _error;
  int _strength = 0;

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _correoError = null;
      _error = null;
    });
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).registro(
            nombre: _nombre.text,
            correo: _correo.text,
            password: _password.text,
          );
      if (mounted) context.go('/registro/listo', extra: _correo.text.trim());
    } on ApiException catch (e) {
      setState(() {
        if (e.statusCode == 409) {
          _correoError = 'Ya existe una cuenta con este correo.';
        } else {
          _error = e.message;
        }
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton.outlined(
                  tooltip: 'Regresar',
                  onPressed: () => context.pop(),
                  icon: const Icon(LucideIcons.arrowLeft, size: 20),
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.line),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Crea tu cuenta', style: AppText.h1),
              const SizedBox(height: 4),
              Text('Solo necesitas tu nombre, correo y una contraseña.',
                  style: AppText.small),
              const SizedBox(height: 32),
              LabeledField(
                label: 'Nombre',
                hint: 'Ej. Carlos Rafael',
                helper: 'Entre 2 y 80 caracteres',
                icon: LucideIcons.user,
                controller: _nombre,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                validator: Validators.nombre,
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: 'Correo electrónico',
                hint: 'tucorreo@ejemplo.com',
                icon: LucideIcons.mail,
                controller: _correo,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: Validators.correo,
                errorText: _correoError,
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: 'Contraseña',
                hint: '••••••••',
                helper: 'Mínimo 8 caracteres',
                icon: LucideIcons.lock,
                controller: _password,
                isPassword: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                validator: Validators.passwordNueva,
                onChanged: (v) => setState(() => _strength = passwordStrength(v)),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 12),
              _StrengthBar(score: _strength),
              if (_error != null) ...[
                const SizedBox(height: 16),
                AlertBox(message: _error!, icon: LucideIcons.circleAlert),
              ],
              const SizedBox(height: 24),
              LoadingButton(
                label: 'Crear cuenta',
                loading: _loading,
                onPressed: _submit,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('¿Ya tienes cuenta?', style: AppText.small),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Inicia sesión'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cuatro segmentos que se llenan según la fuerza de la contraseña.
class _StrengthBar extends StatelessWidget {
  const _StrengthBar({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Container(
                height: 3,
                margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                decoration: BoxDecoration(
                  color: i < score ? AppColors.primary : AppColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Text(
          'Seguridad de la contraseña: ${passwordStrengthLabel(score)}',
          style: AppText.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
