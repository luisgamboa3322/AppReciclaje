import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/pecox_models.dart';
import '../../../core/theme/pecox_theme.dart';
import '../../../core/widgets/pecox_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  static const _slides = [
    (
      kicker: 'PASO 1 DE 3 · RECONOCIMIENTO',
      title: 'Reconoce tus residuos',
      body:
          'Toma o selecciona una fotografía para recibir una sugerencia de material con nivel de confianza.',
    ),
    (
      kicker: 'PASO 2 DE 3 · APRENDIZAJE',
      title: 'Aprende a clasificarlos',
      body:
          'Descubre cómo vaciar, limpiar y separar plástico, vidrio, metal, cartón, papel y otros.',
    ),
    (
      kicker: 'PASO 3 DE 3 · SEGUIMIENTO',
      title: 'Consulta tu progreso',
      body:
          'Guarda tus clasificaciones confirmadas y revisa tu actividad en un historial ordenado.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    } else {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _slides[_page];
    final isLast = _page == _slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const PecoxBrand(),
                  TextButton(
                    onPressed: () => context.go('/auth'),
                    style: TextButton.styleFrom(
                      foregroundColor: PecoxColors.textMuted,
                      minimumSize: const Size(48, 48),
                    ),
                    child: const Text('Omitir', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (idx) => setState(() => _page = idx),
                  children: const [
                    _OnboardingCardSlide(child: _ScanArt()),
                    _OnboardingCardSlide(child: _MaterialsArt()),
                    _OnboardingCardSlide(child: _DemoChartArt()),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                current.kicker,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: PecoxColors.emerald700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                current.title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: PecoxColors.forest900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                current.body,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: PecoxColors.textMuted,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (idx) {
                  final active = idx == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? PecoxColors.emerald700 : const Color(0xFFD2E3DC),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _next,
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(isLast ? 'Empezar' : 'Continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingCardSlide extends StatelessWidget {
  const _OnboardingCardSlide({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PecoxColors.mint100, Colors.white],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PecoxColors.border),
      ),
      child: child,
    );
  }
}

class _ScanArt extends StatelessWidget {
  const _ScanArt();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 136,
          height: 136,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: PecoxColors.emerald500, width: 2.5),
            color: Colors.white,
          ),
          child: const Icon(Icons.local_drink_outlined, size: 64, color: PecoxColors.emerald700),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: PecoxColors.forest900,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'Vista previa de encuadre',
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _MaterialsArt extends StatelessWidget {
  const _MaterialsArt();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: kMaterials.map((mat) {
        return Container(
          decoration: BoxDecoration(
            color: mat.bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(mat.icon, color: mat.fgColor, size: 26),
              const SizedBox(height: 4),
              Text(
                mat.label,
                style: TextStyle(
                  color: mat.fgColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DemoChartArt extends StatelessWidget {
  const _DemoChartArt();

  @override
  Widget build(BuildContext context) {
    const heights = [0.42, 0.68, 0.52, 0.88, 0.72, 0.95, 0.60];
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: PecoxColors.mint100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFB3EED9)),
            ),
            child: const Text(
              'EJEMPLO DE PROGRESO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: PecoxColors.emerald700,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: heights.map((h) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FractionallySizedBox(
                    heightFactor: h,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [PecoxColors.emerald500, PecoxColors.emerald700],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Column(
          children: [
            Text(
              'Actividad ilustrativa',
              style: TextStyle(fontWeight: FontWeight.w800, color: PecoxColors.forest900),
            ),
            Text(
              'Los datos reales se cargarán desde tu historial',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: PecoxColors.textMuted),
            ),
          ],
        ),
      ],
    );
  }
}
