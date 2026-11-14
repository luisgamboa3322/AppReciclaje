import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/pecox_theme.dart';
import '../../../core/widgets/pecox_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _openEditProfile(BuildContext context, WidgetRef ref, String name, String email) {
    final nameCtrl = TextEditingController(text: name);
    final emailCtrl = TextEditingController(text: email);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PecoxColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            18,
            20,
            MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Editar datos locales',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isNotEmpty &&
                      emailCtrl.text.contains('@')) {
                    ref
                        .read(appStateProvider.notifier)
                        .updateProfileLocal(nameCtrl.text, emailCtrl.text);
                    Navigator.of(sheetCtx).pop();
                  }
                },
                child: const Text('Guardar cambios'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openAccessibility(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: PecoxColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) {
        return Consumer(
          builder: (ctx, modalRef, _) {
            final a11y = modalRef.watch(appStateProvider).accessibility;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Accesibilidad',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: a11y.largeText,
                      title: const Text('Texto grande'),
                      subtitle: const Text('Aumenta el escalado tipográfico de la app'),
                      onChanged: (v) => modalRef
                          .read(appStateProvider.notifier)
                          .updateAccessibility(largeText: v),
                    ),
                    SwitchListTile(
                      value: a11y.reduceMotion,
                      title: const Text('Reducir movimiento'),
                      subtitle: const Text('Minimiza transiciones y animaciones'),
                      onChanged: (v) => modalRef
                          .read(appStateProvider.notifier)
                          .updateAccessibility(reduceMotion: v),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.of(sheetCtx).pop(),
                      child: const Text('Listo'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openServerAndModelSheet(BuildContext context, WidgetRef ref) {
    final urlCtrl = TextEditingController(text: ref.read(apiBaseUrlProvider));
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PecoxColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) {
        return Consumer(
          builder: (ctx, modalRef, _) {
            final state = modalRef.watch(appStateProvider);
            final modelInfo = state.modelInfo;
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Servidor y modelo ML',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: urlCtrl,
                      decoration: const InputDecoration(
                        labelText: 'URL base API (/api/v1)',
                        helperText: 'Emulador Android: http://10.0.2.2:8000/api/v1',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      modelInfo == null
                          ? 'Estado del modelo: no consultado todavía'
                          : 'Estado: ${modelInfo.status} · Versión: ${modelInfo.activeVersion ?? 'ninguna'}',
                      style: const TextStyle(fontSize: 12, color: PecoxColors.textMuted),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      value: state.offlineSim,
                      title: const Text('Simular sin conexión'),
                      onChanged: (v) =>
                          modalRef.read(appStateProvider.notifier).toggleOffline(v),
                    ),
                    SwitchListTile(
                      value: state.cameraDeniedSim,
                      title: const Text('Simular permiso de cámara denegado'),
                      onChanged: (v) =>
                          modalRef.read(appStateProvider.notifier).toggleCameraDenied(v),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final trimmed = urlCtrl.text.trim();
                        if (trimmed.isNotEmpty) {
                          modalRef.read(apiBaseUrlProvider.notifier).state = trimmed;
                          await modalRef
                              .read(appStateProvider.notifier)
                              .refreshPublicMetadata();
                        }
                        if (sheetCtx.mounted) {
                          Navigator.of(sheetCtx).pop();
                        }
                      },
                      child: const Text('Aplicar y comprobar'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final user = state.user;
    final modelVersion = state.modelInfo?.activeVersion ?? 'No conectado';

    return Scaffold(
      bottomNavigationBar: const PecoxBottomNav(currentIndex: 3),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            const Text(
              'TU CUENTA',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w800,
                color: PecoxColors.emerald700,
              ),
            ),
            const Text(
              'Perfil',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                color: PecoxColors.forest900,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCEFE7),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        user.initials,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1D5A47),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: PecoxColors.forest900,
                            ),
                          ),
                          Text(
                            user.email,
                            style: const TextStyle(
                              fontSize: 12,
                              color: PecoxColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: PecoxColors.mint100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              user.badge,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: PecoxColors.emerald700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (state.isAuthenticated)
                      IconButton(
                        onPressed: () =>
                            _openEditProfile(context, ref, user.name, user.email),
                        tooltip: 'Editar perfil',
                        icon: const Icon(Icons.edit_outlined),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: PecoxColors.mint100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: PecoxColors.emerald700,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(Icons.eco_outlined, color: Colors.white, size: 19),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${state.history.length} clasificaciones sincronizadas',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: PecoxColors.forest900,
                          ),
                        ),
                        Text(
                          'Modelo ML: $modelVersion',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF56796E)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'AJUSTES Y EXPLORACIÓN',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w800,
                color: PecoxColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.visibility_outlined, color: PecoxColors.emerald700),
                    title: const Text('Accesibilidad'),
                    subtitle: Text(
                      '${state.accessibility.largeText ? 'Texto grande' : 'Texto estándar'} · ${state.accessibility.reduceMotion ? 'Movimiento reducido' : 'Animaciones normales'}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openAccessibility(context, ref),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.bar_chart, color: PecoxColors.emerald700),
                    title: const Text('Estadísticas'),
                    subtitle: const Text('Actividad semanal y distribución real'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/stats'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.memory, color: PecoxColors.emerald700),
                    title: const Text('Próximas funciones'),
                    subtitle: const Text('Estaciones inteligentes y recompensas'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/future'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.dns_outlined, color: PecoxColors.emerald700),
                    title: const Text('Servidor y modelo ML'),
                    subtitle: Text(ref.watch(apiBaseUrlProvider)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openServerAndModelSheet(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(appStateProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/auth');
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: PecoxColors.error,
                side: const BorderSide(color: Color(0xFFF0DEDE)),
              ),
              icon: const Icon(Icons.logout, size: 18),
              label: Text(user.isGuest ? 'Ir a iniciar sesión' : 'Cerrar sesión'),
            ),
            const SizedBox(height: 14),
            const Text(
              'PECOX Vision · MVP 1.0',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: PecoxColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
