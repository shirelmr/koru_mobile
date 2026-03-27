import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    final info = _profileInfo(selected);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Text(
                '${info.emoji} ${info.title}',
                style: KoruTextStyles.headline,
              ),
              const SizedBox(height: 8),
              const Text(
                'Here\'s what you\'ll track daily:',
                style: KoruTextStyles.bodyMuted,
              ),
              const SizedBox(height: 24),
              ...info.trackingItems.map(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: KoruColors.chip,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '+ Free-text journaling · Voice diary',
                  style: KoruTextStyles.bodyMuted,
                ),
              ),
              const Spacer(),
              KoruButton(
                label: 'Start Journaling',
                icon: Icons.arrow_forward,
                onPressed: () {
                  ref
                      .read(appProvider.notifier)
                      .completeOnboarding(selected);
                },
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: () => context.go('/onboarding/select'),
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Go back'),
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

  _ProfileInfo _profileInfo(UserProfile profile) {
    return switch (profile) {
      UserProfile.diabetes => _ProfileInfo(
          emoji: '🩸',
          title: 'Diabetes',
          trackingItems: [
            'Glucose (mg/dL)',
            'Insulin taken',
            'Carbohydrate intake',
            'Meal type',
            'Sleep quality & hours',
            'Mood & stress level',
            'Symptoms & exercise',
          ],
        ),
      UserProfile.hypertension => _ProfileInfo(
          emoji: '❤️',
          title: 'Hypertension',
          trackingItems: [
            'Blood pressure readings',
            'Medication taken',
            'Salt & caffeine intake',
            'Sleep quality & hours',
            'Mood & stress level',
            'Symptoms & exercise',
          ],
        ),
      UserProfile.generalHealth => _ProfileInfo(
          emoji: '💚',
          title: 'General Health',
          trackingItems: [
            'Sleep quality & hours',
            'Mood & focus',
            'Stress & tension',
            'Exercise',
            'Symptoms',
            'Food & intake notes',
          ],
        ),
    };
  }
}

class _ProfileInfo {
  final String emoji;
  final String title;
  final List<String> trackingItems;

  const _ProfileInfo({
    required this.emoji,
    required this.title,
    required this.trackingItems,
  });
}
