import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/pecox_theme.dart';
import '../../../core/widgets/pecox_widgets.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  bool _flashOn = false;

  Future<void> _pickFromSource(ImageSource source) async {
    final result = await ref.read(imagePickerServiceProvider).pick(source);
    if (!mounted) return;
    switch (result.outcome) {
      case PickImageOutcome.picked:
        ref.read(appStateProvider.notifier).setCapturedPhoto(result.path);
        context.push('/preview');
      case PickImageOutcome.unavailableFallback:
        ref.read(appStateProvider.notifier).setCapturedPhoto(null);
        context.push('/preview');
      case PickImageOutcome.cameraDenied:
        ref.read(appStateProvider.notifier).toggleCameraDenied(true);
      case PickImageOutcome.cancelled:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraDenied = ref.watch(appStateProvider).cameraDeniedSim;

    if (cameraDenied) {
      return Scaffold(
        appBar: AppBar(title: const Text('Permiso de cámara')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PecoxStateCard(
                  icon: Icons.no_photography_outlined,
                  isWarning: true,
                  title: 'Cámara no disponible o denegada',
                  description:
                      'PECOX necesita acceso a la cámara únicamente para capturar la foto que elijas analizar. Puedes elegir una imagen de tu galería o explorar la guía.',
                  primaryLabel: 'Elegir imagen de la galería',
                  onPrimary: () => _pickFromSource(ImageSource.gallery),
                  secondaryLabel: 'Abrir guía de materiales',
                  onSecondary: () => context.push('/guide'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () =>
                      ref.read(appStateProvider.notifier).toggleCameraDenied(false),
                  child: const Text('Simular permiso concedido'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF13221D),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0A1F19),
                      _flashOn ? const Color(0xFF28473C) : const Color(0xFF1B332C),
                      const Color(0xFF081A16),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        tooltip: 'Cerrar escáner',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black38,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(48, 48),
                        ),
                        icon: const Icon(Icons.close),
                      ),
                      const Text(
                        'Escáner inteligente',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _flashOn = !_flashOn),
                        tooltip: _flashOn ? 'Desactivar flash' : 'Activar flash',
                        style: IconButton.styleFrom(
                          backgroundColor:
                              _flashOn ? PecoxColors.emerald500 : Colors.black38,
                          foregroundColor:
                              _flashOn ? PecoxColors.forest900 : Colors.white,
                          minimumSize: const Size(48, 48),
                        ),
                        icon: const Icon(Icons.flash_on_outlined),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      Text(
                        'FASE 1 UI · ANÁLISIS POR FOTO',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF9BE9CE),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Coloca el residuo dentro del encuadre',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Usa buena luz y un fondo despejado.',
                        style: TextStyle(color: Color(0xFFD0DED9), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final boxSize = (constraints.maxHeight - 16).clamp(140.0, 260.0);
                        return SizedBox(
                          width: boxSize * 0.94,
                          height: boxSize,
                          child: CustomPaint(
                            painter: _ViewfinderPainter(),
                            child: const Center(
                              child: Icon(
                                Icons.local_drink_outlined,
                                size: 58,
                                color: Colors.white24,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, size: 15, color: Color(0xFFC7D9D2)),
                      SizedBox(width: 6),
                      Text(
                        'La imagen se enviará solo para el análisis',
                        style: TextStyle(color: Color(0xFFC7D9D2), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () => _pickFromSource(ImageSource.gallery),
                        tooltip: 'Elegir de la galería',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white12,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(52, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.photo_library_outlined),
                      ),
                      Semantics(
                        button: true,
                        label: 'Tomar fotografía',
                        child: InkResponse(
                          key: const Key('scanner-shutter'),
                          onTap: () => _pickFromSource(ImageSource.camera),
                          radius: 44,
                          child: Container(
                            width: 74,
                            height: 74,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.push('/guide'),
                        tooltip: 'Abrir guía',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white12,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(52, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.menu_book_outlined),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PecoxColors.emerald500
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 38.0;
    const r = 16.0;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(0, len)
        ..lineTo(0, r)
        ..quadraticBezierTo(0, 0, r, 0)
        ..lineTo(len, 0),
      paint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, 0)
        ..lineTo(size.width - r, 0)
        ..quadraticBezierTo(size.width, 0, size.width, r)
        ..lineTo(size.width, len),
      paint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - len)
        ..lineTo(0, size.height - r)
        ..quadraticBezierTo(0, size.height, r, size.height)
        ..lineTo(len, size.height),
      paint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, size.height)
        ..lineTo(size.width - r, size.height)
        ..quadraticBezierTo(size.width, size.height, size.width, size.height - r)
        ..lineTo(size.width, size.height - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
