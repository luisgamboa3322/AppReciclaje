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
  final _nameCtrl = TextEditingController(text: 'Sofía Martínez');
  final _emailCtrl = TextEditingController(text: 'sofia@ejemplo.com');
  final _passCtrl = TextEditingController(text: 'pecox2026');
  _AuthMode _mode = _AuthMode.login;
  bool _obscure = true;
  String? _errorMsg;
  String? _successMsg;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _errorMsg = null;
      _successMsg = null;
    });

    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    if (ref.read(appStateProvider).offlineSim) {
      setState(() => _errorMsg = 'Sin conexión a internet. Puedes explorar la guía sin cuenta.');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _errorMsg = 'Ingresa un correo electrónico válido.');
      return;
    }
    if (_mode != _AuthMode.recover && pass.length < 6) {
      setState(() => _errorMsg = 'La contraseña debe tener al menos 6 caracteres.');
      return;
    }
    if (_mode == _AuthMode.register && name.length < 2) {
      setState(() => _errorMsg = 'Ingresa tu nombre completo.');
      return;
    }

    if (_mode == _AuthMode.recover) {
      setState(() {
        _successMsg =
            'Simulación de envío para $email. Se conectará al backend FastAPI en Fase 2.';
      });
      return;
    }

    ref.read(appStateProvider.notifier).loginUser(name, email);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: PecoxColors.mint100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBCEBD8)),
                    ),
                    child: const Text(
                      'PROTOTIPO · AUTH DEMO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: PecoxColors.emerald700,
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
                    ? 'Te enviaremos instrucciones cuando el servicio de autenticación esté conectado.'
                    : 'Guarda tus clasificaciones confirmadas y consulta tu historial personal.',
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
                  onSelectionChanged: (sel) => setState(() {
                    _mode = sel.first;
                    _errorMsg = null;
                    _successMsg = null;
                  }),
                ),
              const SizedBox(height: 16),
              if (_errorMsg != null) ...[
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
                          _errorMsg!,
                          style: const TextStyle(fontSize: 12, color: Color(0xFFA3252A)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              if (_successMsg != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PecoxColors.mint100,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Text(
                    _successMsg!,
                    style: const TextStyle(fontSize: 12, color: PecoxColors.emerald700),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              if (_mode == _AuthMode.register) ...[
                TextField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Nombre completo'),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
              ),
              if (_mode != _AuthMode.recover) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
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
                    onPressed: () => setState(() {
                      _mode = _AuthMode.recover;
                      _errorMsg = null;
                    }),
                    style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _submit,
                child: Text(
                  _mode == _AuthMode.login
                      ? 'Entrar a PECOX Vision'
                      : _mode == _AuthMode.register
                          ? 'Crear cuenta'
                          : 'Enviar enlace de recuperación',
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
                onPressed: () {
                  ref.read(appStateProvider.notifier).enterGuestMode();
                  context.push('/guide');
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
