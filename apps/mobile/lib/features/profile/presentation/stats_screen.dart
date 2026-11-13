import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/pecox_models.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/pecox_theme.dart';
import '../../../core/widgets/pecox_widgets.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  List<(String day, int count)> _computeWeeklyActivity(
    List<ClassificationRecord> history,
  ) {
    const dayLabels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final buckets = List<int>.filled(7, 0);
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    for (final item in history) {
      final dt = item.createdAtUtc?.toLocal() ?? DateTime.now();
      if (dt.isAfter(cutoff)) {
        buckets[dt.weekday - 1] += 1;
      }
    }
    return List.generate(7, (idx) => (dayLabels[idx], buckets[idx]));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(appStateProvider).history;
    final total = history.length;
    final weeklyActivity = _computeWeeklyActivity(history);
    final maxBar = weeklyActivity.map((e) => e.$2).fold<int>(1, max);

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
              title: 'Métricas basadas en registros guardados',
              message:
                  'Los totales provienen únicamente de tus clasificaciones persistidas. No calculamos CO₂ evitado ni dinero ahorrado sin medición física.',
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
                          'Registros confirmados',
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
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Actividad semanal (7 días)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: PecoxColors.forest900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: weeklyActivity.map((item) {
                          final h = item.$2 == 0 ? 6.0 : (item.$2 / maxBar) * 76 + 10;
                          return Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '${item.$2}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: PecoxColors.forest900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 24,
                                  height: h,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: item.$2 == 0
                                          ? const [Color(0xFFE0EBE6), Color(0xFFE0EBE6)]
                                          : const [
                                              PecoxColors.emerald700,
                                              PecoxColors.emerald500,
                                            ],
                                    ),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(8),
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
                    const SizedBox(height: 12),
                    for (final entry in counts) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.mat.label,
                                  style: const TextStyle(
                                    fontSize: 13,
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
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: total > 0 ? entry.count / total : 0,
                              minHeight: 7,
                              borderRadius: BorderRadius.circular(6),
                              backgroundColor: PecoxColors.mint100,
                              color: entry.mat.fgColor,
                            ),
                          ],
                        ),
                      ),
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
