import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/pecox_models.dart';
import '../theme/pecox_theme.dart';

class PecoxBrand extends StatelessWidget {
  const PecoxBrand({super.key, this.light = false});

  final bool light;

  @override
  Widget build(BuildContext context) {
    final textColor = light ? Colors.white : PecoxColors.forest900;
    final visionColor = light ? const Color(0xFF85E8C4) : PecoxColors.emerald700;
    final markBg = light ? PecoxColors.emerald500 : PecoxColors.forest900;
    final markFg = light ? PecoxColors.forest900 : Colors.white;

    return Semantics(
      label: 'PECOX Vision',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: markBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
                bottomLeft: Radius.circular(3),
              ),
            ),
            child: Icon(Icons.eco_outlined, size: 19, color: markFg),
          ),
          const SizedBox(width: 9),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: textColor,
              ),
              children: [
                const TextSpan(text: 'PECOX '),
                TextSpan(
                  text: 'Vision',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: visionColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PecoxSectionHeading extends StatelessWidget {
  const PecoxSectionHeading({
    super.key,
    required this.kicker,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String kicker;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kicker,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: PecoxColors.emerald700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: PecoxColors.forest900,
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton.icon(
            onPressed: onAction,
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.chevron_right, size: 18),
            label: Text(actionLabel!),
            style: TextButton.styleFrom(
              foregroundColor: PecoxColors.emerald700,
              minimumSize: const Size(48, 48),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }
}

class PecoxHonestyBanner extends StatelessWidget {
  const PecoxHonestyBanner({
    super.key,
    required this.title,
    required this.message,
    this.isWarning = false,
  });

  final String title;
  final String message;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWarning ? const Color(0xFFFFF3E0) : PecoxColors.warningBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isWarning ? Icons.warning_amber_rounded : Icons.info_outline,
            size: 19,
            color: PecoxColors.warningInk,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: PecoxColors.warningInk,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: PecoxColors.warningInk,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PecoxOfflineBanner extends StatelessWidget {
  const PecoxOfflineBanner({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF6D5A4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, size: 18, color: Color(0xFF7C4D0F)),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Sin conexión a internet. Algunas funciones requieren red.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7C4D0F),
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF7C4D0F),
              foregroundColor: Colors.white,
              minimumSize: const Size(48, 36),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Reintentar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class PecoxStateCard extends StatelessWidget {
  const PecoxStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.isError = false,
    this.isWarning = false,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool isError;
  final bool isWarning;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final iconBg = isError
        ? const Color(0xFFFDEBEC)
        : isWarning
            ? const Color(0xFFFFF5DF)
            : PecoxColors.mint100;
    final iconFg = isError
        ? PecoxColors.error
        : isWarning
            ? const Color(0xFF9A640B)
            : PecoxColors.emerald700;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: iconFg, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: PecoxColors.forest900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: PecoxColors.textMuted,
              ),
            ),
            if (primaryLabel != null && onPrimary != null) ...[
              const SizedBox(height: 18),
              ElevatedButton(onPressed: onPrimary, child: Text(primaryLabel!)),
            ],
            if (secondaryLabel != null && onSecondary != null) ...[
              const SizedBox(height: 10),
              OutlinedButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class PecoxMaterialIconTile extends StatelessWidget {
  const PecoxMaterialIconTile({
    super.key,
    required this.material,
    this.size = 48,
    this.iconSize = 24,
  });

  final MaterialDefinition material;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: material.bgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(material.icon, color: material.fgColor, size: iconSize),
    );
  }
}

class PecoxBottomNav extends StatelessWidget {
  const PecoxBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      backgroundColor: PecoxColors.surface,
      indicatorColor: PecoxColors.mint100,
      height: 74,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/home');
          case 1:
            context.push('/scanner');
          case 2:
            context.go('/history');
          case 3:
            context.go('/profile');
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home, color: PecoxColors.emerald700),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(Icons.qr_code_scanner_outlined),
          selectedIcon: Icon(Icons.qr_code_scanner, color: PecoxColors.emerald700),
          label: 'Escanear',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history, color: PecoxColors.emerald700),
          label: 'Historial',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person, color: PecoxColors.emerald700),
          label: 'Perfil',
        ),
      ],
    );
  }
}
