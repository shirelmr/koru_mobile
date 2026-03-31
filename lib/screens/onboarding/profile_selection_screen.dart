import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/strings.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/koru_button.dart';
import '../../models/app_models.dart';
import '../../providers/app_provider.dart';

class ProfileSelectionScreen extends ConsumerWidget {
  const ProfileSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedProfileProvider);
    final s = ref.watch(stringsProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Text(s.appTitle, style: KoruTextStyles.display),
              const SizedBox(height: 8),
              Text(s.onboardingQuestion, style: KoruTextStyles.headline),
              const SizedBox(height: 32),
              _ProfileCard(
                icon: '💚',
                title: s.profileGeneralHealth,
                description: s.profileGeneralHealthDesc,
                profile: UserProfile.generalHealth,
                isSelected: selected == UserProfile.generalHealth,
                onTap: () => ref
                    .read(selectedProfileProvider.notifier)
                    .state = UserProfile.generalHealth,
              ),
              const SizedBox(height: 12),
              _ProfileCard(
                icon: '🩸',
                title: s.profileDiabetes,
                description: s.profileDiabetesDesc,
                profile: UserProfile.diabetes,
                isSelected: selected == UserProfile.diabetes,
                onTap: () => ref
                    .read(selectedProfileProvider.notifier)
                    .state = UserProfile.diabetes,
              ),
              const Spacer(),
              KoruButton(
                label: s.continueBtn,
                icon: Icons.arrow_forward,
                onPressed: selected == null
                    ? null
                    : () => context.go('/onboarding/confirm'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final UserProfile profile;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.profile,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? KoruColors.dark : KoruColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? KoruColors.dark : KoruColors.border,
            width: isSelected ? 2 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: KoruTextStyles.title.copyWith(
                      color: isSelected ? Colors.white : KoruColors.dark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: KoruTextStyles.bodyMuted.copyWith(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.7)
                          : KoruColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: KoruColors.sage, size: 22),
          ],
        ),
      ),
    );
  }
}
