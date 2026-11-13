import 'dart:io';
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

  Future<void> _saveClassification(MaterialKey confirmedKey) async {
    final ok = await ref
        .read(appStateProvider.notifier)
        .confirmAndSavePrediction(confirmedMaterial: confirmedKey);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clasificación guardada en tu historial.')),
      );
      context.go('/history');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final payload = state.lastPrediction;

    if (payload == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resultado')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: PecoxStateCard(
              icon: Icons.camera_alt_outlined,
              isWarning: true,
              title: 'Sin resultado activo',
              description:
                  'Captura o selecciona una fotografía para ejecutar una predicción con el modelo.',
              primaryLabel: 'Abrir escáner',
              onPrimary: () => context.pushReplacement('/scanner'),
              secondaryLabel: 'Volver al inicio',
              onSecondary: () => context.go('/home'),
            ),
          ),
        ),
      );
    }

    final confirmedKey = _manualOverride ?? payload.material;
    final activeMat = materialByKey(confirmedKey);
    final predictedMat = materialByKey(payload.material);
    final isCorrected = confirmedKey != payload.material;
    final isIdentified = payload.status == PredictionStatus.identified;

    final String statusHeadline;
    final String statusExplanation;
    if (payload.status == PredictionStatus.identified) {
      statusHeadline = 'Material identificado sobre el umbral calibrado';
      statusExplanation =
          'El puntaje corresponde a la probabilidad softmax del modelo ${payload.modelVersion}. Verifica visualmente antes de separar.';
    } else if (payload.status == PredictionStatus.lowConfidence) {
      statusHeadline = 'Confianza moderada o baja · Verifica manualmente';
      statusExplanation =
          'La fotografía presenta similitud entre dos o más materiales. Puedes confirmar o elegir la categoría correcta abajo.';
    } else {
      statusHeadline = 'Material incierto · Confirma manualmente';
      statusExplanation =
          'La confianza quedó por debajo del umbral mínimo. Revisa las opciones sugeridas o corrige la categoría antes de guardar.';
    }

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
            if (state.capturedImagePath != null &&
                File(state.capturedImagePath!).existsSync()) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  height: 150,
                  child: Image.file(
                    File(state.capturedImagePath!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (state.saveErrorMessage != null) ...[
              PecoxHonestyBanner(
                title: 'No se pudo guardar',
                message: state.saveErrorMessage!,
                isWarning: true,
              ),
              const SizedBox(height: 12),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        PecoxMaterialIconTile(
                          material: activeMat,
                          size: 52,
                          iconSize: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isCorrected
                                    ? 'MATERIAL CORREGIDO'
                                    : 'MATERIAL IDENTIFICADO',
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
                                    ? 'Corregido (original: ${predictedMat.label})'
                                    : '${payload.modelVersion} · ${payload.inferenceMs.round()} ms',
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
                                '${payload.confidencePercent}%',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: isIdentified
                                      ? PecoxColors.emerald700
                                      : const Color(0xFFB46D0C),
                                ),
                              ),
                              const Text(
                                'Confianza\ndel modelo',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: PecoxColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    PecoxHonestyBanner(
                      title: statusHeadline,
                      message: statusExplanation,
                      isWarning: !isIdentified,
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
                    if (payload.alternatives.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Text(
                        'Otras probabilidades del modelo',
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
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
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
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: PecoxColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: state.saveBusy
                          ? null
                          : () => _saveClassification(confirmedKey),
                      icon: state.saveBusy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.bookmark_added_outlined, size: 18),
                      label: Text(
                        state.saveBusy ? 'Guardando...' : 'Guardar clasificación',
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: state.saveBusy
                          ? null
                          : () => _openCorrectionSheet(payload.material, confirmedKey),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Corregir material'),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: state.saveBusy
                          ? null
                          : () => context.pushReplacement('/scanner'),
                      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                      child: const Text('Escanear otro objeto'),
                    ),
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
