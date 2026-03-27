import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/theme.dart';
import 'providers/app_provider.dart';
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
  final notifier = ValueNotifier<bool>(
    ref.read(appProvider).hasCompletedOnboarding,
  );

  ref.listen(appProvider.select((s) => s.hasCompletedOnboarding), (_, next) {
    notifier.value = next;
  });

  return GoRouter(
    initialLocation: '/onboarding/select',
    refreshListenable: notifier,
    redirect: (context, state) {
      final onboarded = ref.read(appProvider).hasCompletedOnboarding;
      final isOnboarding = state.matchedLocation.startsWith('/onboarding');
      if (!onboarded && !isOnboarding) return '/onboarding/select';
      if (onboarded && isOnboarding) return '/check-in';
      return null;
    },
    routes: [
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
