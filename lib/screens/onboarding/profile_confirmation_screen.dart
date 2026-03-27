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
      UserProfile.hypertension => ('❤️', s.profileHypertension, s.trackingItemsHypertension),
      UserProfile.generalHealth => ('💚', s.profileGeneralHealth, s.trackingItemsGeneral),
    };

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Text('$emoji $title', style: KoruTextStyles.headline),
              const SizedBox(height: 8),
              Text(s.confirmTitle, style: KoruTextStyles.bodyMuted),
              const SizedBox(height: 24),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: KoruColors.sage,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(item, style: KoruTextStyles.body),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: KoruColors.chip,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(s.confirmFootnote, style: KoruTextStyles.bodyMuted),
              ),
              const Spacer(),
              KoruButton(
                label: s.startJournaling,
                icon: Icons.arrow_forward,
                onPressed: () {
                  ref.read(appProvider.notifier).completeOnboarding(selected);
                },
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: () => context.go('/onboarding/select'),
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: Text(s.goBack),
                  style: TextButton.styleFrom(
                    foregroundColor: KoruColors.muted,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
