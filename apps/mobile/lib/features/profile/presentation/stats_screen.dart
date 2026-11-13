import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/pecox_models.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/pecox_theme.dart';
import '../../../core/widgets/pecox_widgets.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(appStateProvider).history;
    final total = history.length;
    final maxBar = kDemoWeeklyActivity.map((e) => e.$2).reduce(max);

    final counts = kMaterials
        .map(
          (mat) => (
            mat: mat,
            count: history.where((item) => item.confirmedMaterial == mat.key).length,
          ),
        )
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    final topMat = counts.first;

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            const PecoxHonestyBanner(
              title: 'Vista V2 · Datos de demostración',
              message:
                  'Los totales reflejan tu sesión actual. No se muestran cifras inventadas de CO₂ evitado ni dinero ahorrado.',
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [PecoxColors.forest900, PecoxColors.emerald700],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total clasificaciones',
                          style: TextStyle(fontSize: 11, color: Color(0xFFC6DCD4)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$total',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Sesión actual',
                          style: TextStyle(fontSize: 11, color: Color(0xFFC6DCD4)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Más frecuente',
                            style: TextStyle(fontSize: 11, color: PecoxColors.textMuted),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            total > 0 ? topMat.mat.label : '--',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: PecoxColors.forest900,
                            ),
                          ),
                          Text(
                            total > 0 ? '${topMat.count} registro(s)' : 'Sin registros',
                            style: const TextStyle(
                              fontSize: 11,
                              color: PecoxColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Actividad semanal (Demo)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: PecoxColors.forest900,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: PecoxColors.mint100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'DEMO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: PecoxColors.emerald700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 135,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: kDemoWeeklyActivity.map((item) {
                          return Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '${item.$2}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: FractionallySizedBox(
                                      heightFactor: item.$2 / maxBar,
                                      widthFactor: 0.65,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: PecoxColors.emerald500,
                                          borderRadius: BorderRadius.circular(7),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.$1,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: PecoxColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Distribución por material',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: PecoxColors.forest900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final entry in counts) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.mat.label,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${entry.count} (${total > 0 ? ((entry.count / total) * 100).round() : 0}%)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: PecoxColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      LinearProgressIndicator(
                        value: total > 0 ? entry.count / total : 0,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(999),
                        backgroundColor: const Color(0xFFEDF5F1),
                        color: entry.mat.fgColor,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
