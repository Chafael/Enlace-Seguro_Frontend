import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/app_logo.dart';
import '../../auth/state/auth_controller.dart';

class _Pagina {
  const _Pagina(this.ilustracion, this.titulo, this.subtitulo);

  final String ilustracion;
  final String titulo;
  final String subtitulo;
}

const _paginas = [
  _Pagina(
    'assets/ilustraciones/bienvenida_1.svg',
    '¿Te llegó un enlace sospechoso?',
    'Por SMS o WhatsApp llegan mensajes que fingen ser tu banco o una paquetería.',
  ),
  _Pagina(
    'assets/ilustraciones/bienvenida_2.svg',
    'Lo abrimos por ti en un entorno aislado',
    'Tu celular nunca abre la página. Un navegador aislado la revisa y toma una captura.',
  ),
  _Pagina(
    'assets/ilustraciones/bienvenida_3.svg',
    'Recibe un veredicto claro',
    'Te decimos si es seguro, sospechoso o peligroso y por qué.',
  ),
];

/// Tres páginas que solo se ven la primera vez que se abre la app.
class BienvenidaScreen extends ConsumerStatefulWidget {
  const BienvenidaScreen({super.key});

  @override
  ConsumerState<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends ConsumerState<BienvenidaScreen> {
  final _pager = PageController();
  int _actual = 0;

  bool get _esUltima => _actual == _paginas.length - 1;

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  /// Guarda que ya se vio. El router detecta el cambio y abre el login.
  void _terminar() => ref.read(authControllerProvider.notifier).terminarBienvenida();

  void _siguiente() {
    if (_esUltima) {
      _terminar();
    } else {
      _pager.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            children: [
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    const AppLogo(size: 24),
                    const SizedBox(width: 8),
                    AppWordmark(
                      style: AppText.body.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    if (!_esUltima)
                      TextButton(
                        onPressed: _terminar,
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary),
                        child: const Text('Omitir'),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pager,
                  itemCount: _paginas.length,
                  onPageChanged: (i) => setState(() => _actual = i),
                  itemBuilder: (_, i) => _PaginaView(pagina: _paginas[i]),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: List.generate(_paginas.length, (i) {
                  final activo = i == _actual;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 6),
                    width: activo ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: activo ? AppColors.primary : AppColors.line,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _siguiente,
                child: Text(_esUltima ? 'Comenzar' : 'Siguiente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaginaView extends StatelessWidget {
  const _PaginaView({required this.pagina});

  final _Pagina pagina;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Center(
            child: SvgPicture.asset(pagina.ilustracion, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 24),
        Text(pagina.titulo, style: AppText.h1),
        const SizedBox(height: 10),
        Text(pagina.subtitulo,
            style: AppText.body.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}
