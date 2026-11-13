import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/guides/presentation/guide_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/profile/presentation/future_concepts_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/stats_screen.dart';
import '../../features/result/presentation/result_screen.dart';
import '../../features/scanner/presentation/analyzing_screen.dart';
import '../../features/scanner/presentation/preview_screen.dart';
import '../../features/scanner/presentation/scanner_screen.dart';

GoRouter createPecoxRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/scanner',
        builder: (context, state) => const ScannerScreen(),
      ),
      GoRoute(
        path: '/preview',
        builder: (context, state) => const PreviewScreen(),
      ),
      GoRoute(
        path: '/analyzing',
        builder: (context, state) => const AnalyzingScreen(),
      ),
      GoRoute(
        path: '/result',
        builder: (context, state) => const ResultScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/guide',
        builder: (context, state) => const GuideScreen(),
      ),
      GoRoute(
        path: '/stats',
        builder: (context, state) => const StatsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/future',
        builder: (context, state) => const FutureConceptsScreen(),
      ),
    ],
  );
}
