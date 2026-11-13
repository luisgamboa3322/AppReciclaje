import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/pecox_models.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/pecox_theme.dart';
import '../../../core/widgets/pecox_widgets.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  MaterialKey? _manualOverride;

  void _openCorrectionSheet(MaterialKey original, MaterialKey current) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PecoxColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final selected = _manualOverride ?? current;
            final isModified = selected != original;
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBE4E0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'AJUSTAR RESULTADO',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                        color: PecoxColors.emerald700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '¿Qué material es?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: PecoxColors.forest900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tu corrección se guarda separada de la sugerencia original y no reentrena el modelo de inmediato.',
                      style: TextStyle(fontSize: 12, color: PecoxColors.textMuted),
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.05,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: kMaterials.map((mat) {
                        final isSelected = selected == mat.key;
                        return InkWell(
                          onTap: () {
                            setState(() => _manualOverride = mat.key);
                            setSheetState(() {});
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? PecoxColors.emerald500
                                    : PecoxColors.border,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                PecoxMaterialIconTile(
                                  material: mat,
                                  size: 40,
                                  iconSize: 20,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  mat.label,
                                  style: const TextStyle(
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
                    const SizedBox(height: 16),
                    if (isModified) ...[
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() => _manualOverride = original);
                          setSheetState(() {});
                        },
                        icon: const Icon(Icons.undo, size: 18),
                        label: const Text('Deshacer corrección'),
                      ),
                      const SizedBox(height: 8),
                    ],
                    ElevatedButton(
                      onPressed: () => Navigator.of(sheetCtx).pop(),
                      child: Text('Confirmar (${materialByKey(selected).label})'),
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
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final variant = state.resultVariant;
    final payload = variant == ResultVariant.error
        ? kDemoPredictions[ResultVariant.identified]!
        : kDemoPredictions[variant]!;
    final confirmedKey = _manualOverride ?? payload.material;
    final activeMat = materialByKey(confirmedKey);
    final isCorrected = confirmedKey != payload.material;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado'),
        actions: [
          IconButton(
            onPressed: () => context.go('/home'),
            tooltip: 'Cerrar',
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final item in const [
                    (ResultVariant.identified, 'Identificado'),
                    (ResultVariant.lowConfidence, 'Baja confianza'),
                    (ResultVariant.unknown, 'Desconocido'),
                    (ResultVariant.error, 'Error'),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(item.$2),
                        selected: variant == item.$1,
                        onSelected: (_) {
                          setState(() => _manualOverride = null);
                          ref.read(appStateProvider.notifier).setResultVariant(item.$1);
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (variant == ResultVariant.error)
              PecoxStateCard(
                icon: Icons.error_outline,
                isError: true,
                title: 'Error al procesar la imagen',
                description:
                    'El servicio de inferencia devolvió un error controlado. No se mostrará una categoría inventada.',
                primaryLabel: 'Reintentar análisis',
                onPrimary: () => context.pushReplacement('/analyzing'),
                secondaryLabel: 'Elegir material manualmente',
                onSecondary: () => ref
                    .read(appStateProvider.notifier)
                    .setResultVariant(ResultVariant.lowConfidence),
              )
            else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          PecoxMaterialIconTile(material: activeMat, size: 52, iconSize: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isCorrected ? 'MATERIAL CORREGIDO' : 'MATERIAL SUGERIDO',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    letterSpacing: 1.1,
                                    fontWeight: FontWeight.w800,
                                    color: PecoxColors.emerald700,
                                  ),
                                ),
                                Text(
                                  activeMat.label,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: PecoxColors.forest900,
                                  ),
                                ),
                                Text(
                                  isCorrected
                                      ? 'Corregido (original: ${materialByKey(payload.material).label})'
                                      : 'Sugerencia demo · ${payload.modelVersion}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: PecoxColors.emerald700,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 12),
                            decoration: const BoxDecoration(
                              border: Border(left: BorderSide(color: PecoxColors.border)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${payload.confidence ?? '--'}%',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: variant == ResultVariant.identified
                                        ? PecoxColors.emerald700
                                        : const Color(0xFFB46D0C),
                                  ),
                                ),
                                const Text(
                                  'Confianza\ndel modelo',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontSize: 10, color: PecoxColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      PecoxHonestyBanner(
                        title: payload.headline,
                        message: payload.explanation,
                        isWarning: variant != ResultVariant.identified,
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6FBF8),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CÓMO PREPARARLO (${activeMat.label.toUpperCase()})',
                              style: const TextStyle(
                                fontSize: 10,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w800,
                                color: PecoxColors.emerald700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activeMat.steps.first.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: PecoxColors.forest900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${activeMat.steps.first.detail} ${activeMat.warning}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: PecoxColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Otras sugerencias del ejemplo',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      for (final alt in payload.alternatives)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 66,
                                child: Text(
                                  materialByKey(alt.key).label,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                              ),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: alt.confidence / 100,
                                  backgroundColor: PecoxColors.mint100,
                                  color: PecoxColors.emerald500,
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${alt.confidence}%',
                                style: const TextStyle(fontSize: 12, color: PecoxColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          final record = ClassificationRecord(
                            id: 'cls-${DateTime.now().millisecondsSinceEpoch}',
                            title: isCorrected
                                ? '${activeMat.label} (corregido)'
                                : payload.title,
                            predictedMaterial: payload.material,
                            confirmedMaterial: confirmedKey,
                            confidence: payload.confidence,
                            status: isCorrected
                                ? ClassificationStatus.corrected
                                : ClassificationStatus.confirmed,
                            dateGroup: 'HOY',
                            timestampLabel: 'Ahora mismo',
                            imagePath: state.capturedImagePath,
                            notes: isCorrected
                                ? 'Original: ${materialByKey(payload.material).label} → Confirmado: ${activeMat.label}'
                                : 'Registro guardado en sesión de demostración.',
                          );
                          ref.read(appStateProvider.notifier).saveClassification(record);
                          context.go('/history');
                        },
                        icon: const Icon(Icons.bookmark_added_outlined, size: 18),
                        label: const Text('Guardar clasificación'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () =>
                            _openCorrectionSheet(payload.material, confirmedKey),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Corregir material'),
                      ),
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: () => context.pushReplacement('/scanner'),
                        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                        child: const Text('Escanear otro objeto'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
