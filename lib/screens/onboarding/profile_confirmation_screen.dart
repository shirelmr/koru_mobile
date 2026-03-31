import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/strings.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/koru_button.dart';
import '../../models/app_models.dart';
import '../../providers/app_provider.dart';

class ProfileConfirmationScreen extends ConsumerWidget {
  const ProfileConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected =
        ref.watch(selectedProfileProvider) ?? UserProfile.generalHealth;
    final s = ref.watch(stringsProvider);

    final (emoji, title, items) = switch (selected) {
      UserProfile.diabetes => ('🩸', s.profileDiabetes, s.trackingItemsDiabetes),
      UserProfile.generalHealth => ('💚', s.profileGeneralHealth, s.trackingItemsGeneral),
    };

    return Scaffold(
      backgroundColor: KoruColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),
                      Text(emoji, style: const TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(title, style: KoruTextStyles.display),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '${s.confirmTitle} ${s.confirmFootnote}',
                          textAlign: TextAlign.center,
                          style: KoruTextStyles.bodyMuted,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _es(s) ? 'Tu registro diario incluirá:' : 'Your daily check-in will include:',
                              style: KoruTextStyles.title,
                            ),
                            const SizedBox(height: 16),
                            ...items.map((item) => _TrackingItemPill(label: item)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              KoruButton(
                label: s.startJournaling,
                icon: Icons.arrow_forward,
                onPressed: () {
                  ref.read(appProvider.notifier).completeOnboarding(selected);
                },
              ),
              const SizedBox(height: 12),
              KoruButton(
                label: s.goBack,
                outline: true,
                onPressed: () => context.go('/onboarding/select'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  bool _es(S s) => s.isSpanish;
}

class _TrackingItemPill extends StatelessWidget {
  final String label;

  const _TrackingItemPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: KoruColors.background.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.diamond, size: 12, color: KoruColors.dark),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: KoruTextStyles.body.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
