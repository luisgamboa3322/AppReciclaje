import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/pecox_models.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/pecox_theme.dart';
import '../../../core/widgets/pecox_widgets.dart';

class GuideScreen extends ConsumerWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedKey = ref.watch(appStateProvider).selectedGuideMaterial;
    final active = materialByKey(selectedKey);

    return Scaffold(
      appBar: AppBar(title: const Text('Guía de materiales')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            const Text(
              'APRENDE A SEPARAR · SIN CÁMARA',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w800,
                color: PecoxColors.emerald700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Cada material tiene su lugar',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: PecoxColors.forest900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Consulta ejemplos, preparación y advertencias por categoría. Las reglas pueden variar según tu localidad.',
              style: TextStyle(fontSize: 13, height: 1.5, color: PecoxColors.textMuted),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: kMaterials.map((mat) {
                  final selected = mat.key == selectedKey;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: InkWell(
                      onTap: () => ref
                          .read(appStateProvider.notifier)
                          .selectGuideMaterial(mat.key),
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: mat.bgColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selected
                                    ? PecoxColors.emerald700
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Icon(mat.icon, color: mat.fgColor, size: 26),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            mat.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: selected
                                  ? PecoxColors.emerald700
                                  : PecoxColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: active.bgColor,
                    child: Row(
                      children: [
                        Icon(active.icon, size: 46, color: active.fgColor),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MATERIAL',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w800,
                                color: active.fgColor,
                              ),
                            ),
                            Text(
                              active.label,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: active.fgColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          active.description,
                          style: const TextStyle(fontSize: 13, height: 1.55),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5FBF8),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: PecoxColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'EJEMPLOS COMUNES',
                                style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 1.1,
                                  fontWeight: FontWeight.w800,
                                  color: PecoxColors.emerald700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              for (final example in active.examples)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  child: Text(
                                    '• $example',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'ANTES DE RECICLAR',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w800,
                            color: PecoxColors.emerald700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Prepáralo en tres pasos',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: PecoxColors.forest900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (var i = 0; i < active.steps.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: PecoxColors.mint100,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: PecoxColors.emerald700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        active.steps[i].title,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        active.steps[i].detail,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: PecoxColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 6),
                        PecoxHonestyBanner(
                          title: 'Advertencia y reglas locales',
                          message: active.warning,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
