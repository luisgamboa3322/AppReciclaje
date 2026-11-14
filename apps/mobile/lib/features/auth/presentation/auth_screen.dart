import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/pecox_theme.dart';
import '../../../core/widgets/pecox_widgets.dart';

enum _AuthMode { login, register, recover }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  _AuthMode _mode = _AuthMode.login;
  bool _obscure = true;
  String? _localError;
  String? _infoMsg;

  Future<void> _openServerUrlDialog() async {
    final ctrl = TextEditingController(text: ref.read(apiBaseUrlProvider));
    final updated = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Servidor API (/api/v1)'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'URL base API',
            hintText: 'http://192.168.100.120:8000/api/v1',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogCtx).pop(ctrl.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (updated != null && updated.isNotEmpty) {
      ref.read(apiBaseUrlProvider.notifier).state = updated;
      await ref.read(appStateProvider.notifier).refreshPublicMetadata();
      if (mounted) {
        setState(() {
          _localError = null;
          _infoMsg = 'Servidor actualizado a $updated';
        });
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _localError = null;
      _infoMsg = null;
    });

    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final name = _nameCtrl.text.trim();

    if (ref.read(appStateProvider).offlineSim) {
      setState(() => _localError = 'Sin conexión a internet. Puedes explorar la guía sin cuenta.');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _localError = 'Ingresa un correo electrónico válido.');
      return;
    }
    if (_mode == _AuthMode.recover) {
      setState(() {
        _infoMsg =
            'El restablecimiento por correo aún no está habilitado en este servidor MVP. Crea una nueva cuenta o solicita ayuda al administrador.';
      });
      return;
    }
    if (pass.length < 8) {
      setState(() => _localError = 'La contraseña debe tener al menos 8 caracteres.');
      return;
    }
    if (_mode == _AuthMode.register && name.length < 2) {
      setState(() => _localError = 'Ingresa tu nombre completo (mínimo 2 caracteres).');
      return;
    }

    final notifier = ref.read(appStateProvider.notifier);
    final ok = _mode == _AuthMode.login
        ? await notifier.login(email: email, password: pass)
        : await notifier.register(name: name, email: email, password: pass);

    if (!mounted) return;
    if (ok) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final errorBanner = _localError ?? state.authError;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const PecoxBrand(),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _openServerUrlDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: PecoxColors.mint100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBCEBD8)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.dns_outlined, size: 13, color: PecoxColors.emerald700),
                          SizedBox(width: 4),
                          Text(
                            'API FASTAPI · JWT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: PecoxColors.emerald700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                _mode == _AuthMode.login
                    ? 'Inicia sesión en PECOX'
                    : _mode == _AuthMode.register
                        ? 'Crea tu cuenta'
                        : 'Recuperar acceso',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: PecoxColors.forest900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _mode == _AuthMode.recover
                    ? 'Consulta el estado del servicio de recuperación de contraseña.'
                    : 'Guarda tus clasificaciones confirmadas y sincroniza tu historial real.',
                style: const TextStyle(fontSize: 13, height: 1.5, color: PecoxColors.textMuted),
              ),
              const SizedBox(height: 18),
              if (_mode != _AuthMode.recover)
                SegmentedButton<_AuthMode>(
                  segments: const [
                    ButtonSegment(value: _AuthMode.login, label: Text('Iniciar sesión')),
                    ButtonSegment(value: _AuthMode.register, label: Text('Crear cuenta')),
                  ],
                  selected: {_mode},
                  onSelectionChanged: state.authBusy
                      ? null
                      : (sel) => setState(() {
                            _mode = sel.first;
                            _localError = null;
                            _infoMsg = null;
                          }),
                ),
              const SizedBox(height: 16),
              if (errorBanner != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDEBEC),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: const Color(0xFFF4C6C8)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: PecoxColors.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorBanner,
                          style: const TextStyle(fontSize: 12, color: Color(0xFFA3252A)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              if (_infoMsg != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PecoxColors.mint100,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Text(
                    _infoMsg!,
                    style: const TextStyle(fontSize: 12, color: PecoxColors.emerald700),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              if (_mode == _AuthMode.register) ...[
                TextField(
                  controller: _nameCtrl,
                  enabled: !state.authBusy,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    hintText: 'Ej. Sofía Martínez',
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _emailCtrl,
                enabled: !state.authBusy,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  hintText: 'nombre@correo.com',
                ),
              ),
              if (_mode != _AuthMode.recover) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _passCtrl,
                  enabled: !state.authBusy,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    hintText: 'Mínimo 8 caracteres',
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      tooltip: _obscure ? 'Mostrar contraseña' : 'Ocultar contraseña',
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    ),
                  ),
                ),
              ],
              if (_mode == _AuthMode.login)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: state.authBusy
                        ? null
                        : () => setState(() {
                              _mode = _AuthMode.recover;
                              _localError = null;
                              _infoMsg = null;
                            }),
                    style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: state.authBusy ? null : _submit,
                child: state.authBusy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _mode == _AuthMode.login
                            ? 'Entrar a PECOX Vision'
                            : _mode == _AuthMode.register
                                ? 'Crear cuenta'
                                : 'Ver disponibilidad',
                      ),
              ),
              if (_mode == _AuthMode.recover) ...[
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => setState(() => _mode = _AuthMode.login),
                  child: const Text('Volver a iniciar sesión'),
                ),
              ],
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: state.authBusy
                    ? null
                    : () async {
                        await ref.read(appStateProvider.notifier).enterGuestMode();
                        if (context.mounted) {
                          context.push('/guide');
                        }
                      },
                icon: const Icon(Icons.menu_book_outlined, size: 18),
                label: const Text('Explorar guía de materiales sin cuenta'),
              ),
              const SizedBox(height: 8),
              const Text(
                'El modo invitado permite consultar la guía de separación sin activar la cámara ni iniciar sesión.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: PecoxColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
