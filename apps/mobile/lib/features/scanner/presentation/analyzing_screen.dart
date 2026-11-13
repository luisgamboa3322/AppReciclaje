import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/pecox_api_client.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/pecox_theme.dart';
import '../../../core/widgets/pecox_widgets.dart';

class AnalyzingScreen extends ConsumerStatefulWidget {
  const AnalyzingScreen({super.key, this.autoStart = true});

  final bool autoStart;

  @override
  ConsumerState<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends ConsumerState<AnalyzingScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.autoStart) {
      Future.microtask(_runAnalysis);
    }
  }

  Future<void> _runAnalysis() async {
    final ok = await ref.read(appStateProvider.notifier).analyzeCapturedImage();
    if (!mounted) return;
    if (ok) {
      context.pushReplacement('/result');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final failure = state.analysisFailure;
    final errMsg = state.analysisErrorMessage;

    if (!state.analysisBusy && failure != null && errMsg != null) {
      final isNetwork = failure == ApiFailure.network || failure == ApiFailure.timeout;
      final isUnauthorized = failure == ApiFailure.unauthorized;
      final isModelDown = failure == ApiFailure.modelUnavailable;

      return Scaffold(
        appBar: AppBar(title: const Text('Analizando imagen')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: PecoxStateCard(
              icon: isNetwork
                  ? Icons.wifi_off
                  : isModelDown
                      ? Icons.model_training_outlined
                      : Icons.error_outline,
              isError: !isModelDown,
              isWarning: isModelDown,
              title: isNetwork
                  ? 'No se pudo conectar'
                  : isUnauthorized
                      ? 'Sesión requerida o expirada'
                      : isModelDown
                          ? 'Modelo ML no disponible'
                          : 'No se pudo procesar la foto',
              description: errMsg,
              primaryLabel: isUnauthorized
                  ? 'Iniciar sesión'
                  : 'Reintentar análisis',
              onPrimary: () {
                if (isUnauthorized) {
                  context.go('/auth');
                } else {
                  if (state.offlineSim) {
                    ref.read(appStateProvider.notifier).toggleOffline(false);
                  }
                  _runAnalysis();
                }
              },
              secondaryLabel: 'Volver a revisar foto',
              onSecondary: () => context.pop(),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
          child: Column(
            children: [
              const Align(alignment: Alignment.centerLeft, child: PecoxBrand()),
              const Spacer(),
              Container(
                width: 148,
                height: 148,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PecoxColors.mint100,
                  border: Border.all(color: PecoxColors.emerald500, width: 2.5),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 54,
                  color: PecoxColors.emerald700,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Analizando el material',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: PecoxColors.forest900,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Enviando la fotografía al servidor FastAPI para clasificarla con el modelo entrenado.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.55, color: PecoxColors.textMuted),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: PecoxColors.emerald700),
              const Spacer(),
              TextButton(
                onPressed: () => context.pop(),
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
