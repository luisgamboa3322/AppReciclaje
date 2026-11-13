import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/pecox_theme.dart';
import '../../../core/widgets/pecox_widgets.dart';

class AnalyzingScreen extends ConsumerStatefulWidget {
  const AnalyzingScreen({super.key, this.autoComplete = true});

  final bool autoComplete;

  @override
  ConsumerState<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends ConsumerState<AnalyzingScreen> {
  Timer? _timer;
  bool _failedOffline = false;

  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  void _startAnalysis() {
    _timer?.cancel();
    if (!widget.autoComplete) return;

    final isOffline = ref.read(appStateProvider).offlineSim;
    _timer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      if (isOffline) {
        setState(() => _failedOffline = true);
      } else {
        context.pushReplacement('/result');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failedOffline) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analizando imagen')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: PecoxStateCard(
              icon: Icons.wifi_off,
              isError: true,
              title: 'Se perdió la conexión',
              description:
                  'No fue posible enviar la fotografía al servidor. No generaremos una predicción falsa.',
              primaryLabel: 'Reintentar análisis',
              onPrimary: () {
                ref.read(appStateProvider.notifier).toggleOffline(false);
                setState(() => _failedOffline = false);
                _startAnalysis();
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
                'El prototipo está preparando la vista de resultado. No se está ejecutando un modelo ML real ni mostrando porcentajes ficticios.',
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
