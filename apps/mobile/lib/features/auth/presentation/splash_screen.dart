import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/pecox_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.autoAdvance = true});

  final bool autoAdvance;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoAdvance) {
      _timer = Timer(const Duration(milliseconds: 1400), () {
        if (mounted && !_hasError) {
          context.go('/onboarding');
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PecoxColors.forest900,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0D2E24),
                PecoxColors.forest900,
                Color(0xFF095641),
              ],
            ),
          ),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: PecoxColors.emerald500,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                    bottomLeft: Radius.circular(8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.22),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.eco_outlined,
                  size: 40,
                  color: PecoxColors.forest900,
                ),
              ),
              const SizedBox(height: 18),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(text: 'PECOX '),
                    TextSpan(
                      text: 'Vision',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF85E8C4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Reconoce. Aprende. Recicla.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFFCDE8DE),
                ),
              ),
              const Spacer(),
              if (_hasError)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.28),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'No se pudo verificar la sesión inicial.',
                        style: TextStyle(color: Color(0xFFFBD5D6), fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          setState(() => _hasError = false);
                          context.go('/onboarding');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: PecoxColors.forest900,
                        ),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              else ...[
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFF85E8C4),
                  ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => context.go('/onboarding'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFB5E9D7),
                    minimumSize: const Size(48, 48),
                  ),
                  child: const Text('Continuar ahora'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
