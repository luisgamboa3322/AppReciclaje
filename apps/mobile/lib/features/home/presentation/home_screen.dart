import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/pecox_models.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/pecox_theme.dart';
import '../../../core/widgets/pecox_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final uniqueMaterials =
        state.history.map((e) => e.confirmedMaterial).toSet().length;
    final firstName = state.user.isGuest
        ? 'Visitante'
        : state.user.name.split(' ').first;
    final latest = state.history.isNotEmpty ? state.history.first : null;
    final latestMat = latest != null ? materialByKey(latest.confirmedMaterial) : null;

    return Scaffold(
      bottomNavigationBar: const PecoxBottomNav(currentIndex: 0),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PecoxBrand(),
                      const SizedBox(height: 6),
                      Text(
                        'Hola, $firstName · Cada clasificación cuenta',
                        style: const TextStyle(
                          fontSize: 12,
                          color: PecoxColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => context.go('/profile'),
                  borderRadius: BorderRadius.circular(15),
                  child: Semantics(
                    button: true,
                    label: 'Abrir perfil',
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCEFE7),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        state.user.initials,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1D5A47),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (state.offlineSim)
              PecoxOfflineBanner(
                onRetry: () => ref.read(appStateProvider.notifier).toggleOffline(false),
              ),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF123D30), PecoxColors.forest800],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: PecoxColors.forest900.withOpacity(0.16),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, size: 14, color: Color(0xFFAEEFDA)),
                            SizedBox(width: 5),
                            Text(
                              'RECONOCIMIENTO INTELIGENTE',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 0.9,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFAEEFDA),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '¿Qué vamos a reciclar hoy?',
                          style: TextStyle(
                            fontSize: 22,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Identifica el material por fotografía y aprende a separarlo.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.45,
                            color: Color(0xFFC6DCD4),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/scanner'),
                          iconAlignment: IconAlignment.end,
                          icon: const Icon(Icons.arrow_forward, size: 18),
                          label: const Text('Escanear ahora'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: PecoxColors.forest900,
                            minimumSize: const Size(0, 48),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 66,
                    height: 112,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.26)),
                    ),
                    child: const Icon(
                      Icons.recycling,
                      size: 38,
                      color: PecoxColors.lime300,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 12,
                  child: Card(
                    child: InkWell(
                      onTap: () => context.push('/stats'),
                      borderRadius: BorderRadius.circular(PecoxRadii.lg),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Objetos clasificados',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: PecoxColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${state.history.length}',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: PecoxColors.forest900,
                              ),
                            ),
                            const Text(
                              'Demo local · Ver estadísticas',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: PecoxColors.emerald700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 9,
                  child: Card(
                    child: InkWell(
                      onTap: () => context.push('/stats'),
                      borderRadius: BorderRadius.circular(PecoxRadii.lg),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Materiales',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: PecoxColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 6),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: PecoxColors.forest900,
                                ),
                                children: [
                                  TextSpan(text: '$uniqueMaterials'),
                                  const TextSpan(
                                    text: '/6',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: PecoxColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              'Categorías',
                              style: TextStyle(fontSize: 11, color: PecoxColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            PecoxSectionHeading(
              kicker: 'EXPLORA',
              title: 'Guía de materiales',
              actionLabel: 'Ver guía',
              onAction: () => context.push('/guide'),
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.25,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: kMaterials.map((mat) {
                return InkWell(
                  onTap: () {
                    ref.read(appStateProvider.notifier).selectGuideMaterial(mat.key);
                    context.push('/guide');
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: mat.bgColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(mat.icon, color: mat.fgColor, size: 24),
                        const SizedBox(height: 4),
                        Text(
                          mat.label,
                          style: TextStyle(
                            color: mat.fgColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            PecoxSectionHeading(
              kicker: 'TU ACTIVIDAD',
              title: 'Clasificaciones recientes',
              actionLabel: 'Ver todo',
              onAction: () => context.go('/history'),
            ),
            const SizedBox(height: 8),
            if (latest != null && latestMat != null)
              Card(
                child: ListTile(
                  minVerticalPadding: 12,
                  onTap: () => context.go('/history'),
                  leading: PecoxMaterialIconTile(material: latestMat),
                  title: Text(
                    latest.title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '${latest.timestampLabel} · ${latestMat.label}',
                    style: const TextStyle(fontSize: 12, color: PecoxColors.textMuted),
                  ),
                  trailing: latest.confidence != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: PecoxColors.mint100,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            '${latest.confidence}%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: PecoxColors.emerald700,
                            ),
                          ),
                        )
                      : null,
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Aún no tienes clasificaciones guardadas.',
                        style: TextStyle(color: PecoxColors.textMuted),
                      ),
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: () => context.push('/scanner'),
                        child: const Text('Escanear mi primer residuo'),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                onTap: () => context.push('/stats'),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: PecoxColors.mint100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bar_chart, color: PecoxColors.emerald700),
                ),
                title: const Text(
                  'Estadísticas y actividad (V2 Demo)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
                subtitle: const Text(
                  'Gráficas demostrativas por material',
                  style: TextStyle(fontSize: 12, color: PecoxColors.textMuted),
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                onTap: () => context.push('/future'),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8EFDD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.memory, color: Color(0xFF91671E)),
                ),
                title: const Text(
                  'Conceptos futuros (V3)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
                subtitle: const Text(
                  'Máquinas inteligentes y depósitos verificados',
                  style: TextStyle(fontSize: 12, color: PecoxColors.textMuted),
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
