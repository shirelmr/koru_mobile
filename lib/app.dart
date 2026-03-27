import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/theme.dart';
import 'providers/app_provider.dart';
import 'providers/language_provider.dart';
import 'screens/language_selection_screen.dart';
import 'screens/shell_screen.dart';
import 'screens/onboarding/profile_selection_screen.dart';
import 'screens/onboarding/profile_confirmation_screen.dart';
import 'screens/check_in_screen.dart';
import 'screens/extraction_screen.dart';
import 'screens/timeline_screen.dart';
import 'screens/patterns_screen.dart';
import 'screens/report/report_configure_screen.dart';
import 'screens/report/report_preview_screen.dart';
import 'screens/report/report_export_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Re-evaluate redirect whenever language or onboarding state changes
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/language',
    refreshListenable: notifier,
    redirect: (context, state) {
      final lang = ref.read(languageProvider);
      final onboarded = ref.read(appProvider).hasCompletedOnboarding;
      final loc = state.matchedLocation;

      final isLang = loc == '/language';
      final isOnboarding = loc.startsWith('/onboarding');

      // No language chosen yet → language screen
      if (lang.isEmpty && !isLang) return '/language';
      // Language chosen, not onboarded → onboarding
      if (lang.isNotEmpty && !onboarded && !isOnboarding && !isLang) {
        return '/onboarding/select';
      }
      // Fully set up → main app
      if (lang.isNotEmpty && onboarded && (isLang || isOnboarding)) {
        return '/check-in';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/language',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: '/onboarding/select',
        builder: (context, state) => const ProfileSelectionScreen(),
      ),
      GoRoute(
        path: '/onboarding/confirm',
        builder: (context, state) => const ProfileConfirmationScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ShellScreen(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/check-in',
              builder: (context, state) => const CheckInScreen(),
              routes: [
                GoRoute(
                  path: 'extraction',
                  builder: (context, state) => const ExtractionScreen(),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/timeline',
              builder: (context, state) => const TimelineScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/patterns',
              builder: (context, state) => const PatternsScreen(),
              routes: [
                GoRoute(
                  path: 'report',
                  builder: (context, state) => const ReportConfigureScreen(),
                  routes: [
                    GoRoute(
                      path: 'preview',
                      builder: (context, state) => const ReportPreviewScreen(),
                      routes: [
                        GoRoute(
                          path: 'export',
                          builder: (context, state) =>
                              const ReportExportScreen(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
});

/// Listens to both language and onboarding state so the router re-evaluates
/// redirect whenever either changes.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen(languageProvider, (prev, next) => notifyListeners());
    ref.listen(
      appProvider.select((s) => s.hasCompletedOnboarding),
      (prev, next) => notifyListeners(),
    );
  }
}

class KoruApp extends ConsumerWidget {
  const KoruApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Kōru',
      theme: koruTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
