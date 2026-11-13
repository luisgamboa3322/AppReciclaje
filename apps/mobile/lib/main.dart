import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/router/app_router.dart';
import 'core/state/app_state.dart';
import 'core/theme/pecox_theme.dart';

void main() {
  runApp(const ProviderScope(child: PecoxVisionApp()));
}

class PecoxVisionApp extends ConsumerStatefulWidget {
  const PecoxVisionApp({super.key, this.initialLocation = '/'});

  final String initialLocation;

  @override
  ConsumerState<PecoxVisionApp> createState() => _PecoxVisionAppState();
}

class _PecoxVisionAppState extends ConsumerState<PecoxVisionApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createPecoxRouter(initialLocation: widget.initialLocation);
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a11y = ref.watch(appStateProvider.select((s) => s.accessibility));

    return MaterialApp.router(
      title: 'PECOX Vision',
      debugShowCheckedModeBanner: false,
      theme: PecoxTheme.light,
      routerConfig: _router,
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: a11y.largeText
                ? const TextScaler.linear(1.18)
                : mq.textScaler,
            disableAnimations: a11y.reduceMotion || mq.disableAnimations,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
