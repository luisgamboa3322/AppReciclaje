import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/pecox_theme.dart';
import '../../../core/widgets/pecox_widgets.dart';

class PreviewScreen extends ConsumerWidget {
  const PreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final imagePath = state.capturedImagePath;

    return Scaffold(
      appBar: AppBar(title: const Text('Revisar fotografía')),
      body: SafeArea(
        child: state.invalidImageFlag
            ? Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: PecoxStateCard(
                    icon: Icons.broken_image_outlined,
                    isError: true,
                    title: 'Imagen inválida o demasiado grande',
                    description:
                        'El archivo supera el límite permitido o su formato no es válido. Toma o elige otra fotografía clara.',
                    primaryLabel: 'Tomar otra foto',
                    onPrimary: () {
                      ref.read(appStateProvider.notifier).clearInvalidImage();
                      context.pop();
                    },
                    secondaryLabel: 'Volver al inicio',
                    onSecondary: () {
                      ref.read(appStateProvider.notifier).clearInvalidImage();
                      context.go('/home');
                    },
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      height: 310,
                      color: const Color(0xFFE8EFEB),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (imagePath != null && File(imagePath).existsSync())
                            Image.file(File(imagePath), fit: BoxFit.cover)
                          else
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 64,
                                  color: PecoxColors.textMuted,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No se encontró la imagen seleccionada',
                                  style: TextStyle(
                                    color: PecoxColors.forest900,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          Positioned(
                            left: 14,
                            bottom: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: PecoxColors.forest900.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check, size: 15, color: Colors.white),
                                  SizedBox(width: 5),
                                  Text(
                                    'Imagen lista',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '¿La imagen se ve clara?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: PecoxColors.forest900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Asegúrate de que el objeto esté completo, enfocado y con buena iluminación.',
                    style: TextStyle(fontSize: 13, height: 1.5, color: PecoxColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: PecoxColors.mint100,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: PecoxColors.emerald700),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tu privacidad importa',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: PecoxColors.forest900,
                                ),
                              ),
                              Text(
                                'No conservaremos esta fotografía de forma permanente.',
                                style: TextStyle(fontSize: 12, color: Color(0xFF476D61)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/analyzing'),
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: const Text('Analizar material'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Tomar otra foto'),
                  ),
                ],
              ),
      ),
    );
  }
}
