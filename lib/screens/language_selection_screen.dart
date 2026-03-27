import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/colors.dart';
import '../core/theme/text_styles.dart';
import '../providers/language_provider.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 64),
              const Text('Kōru', style: KoruTextStyles.display),
              const SizedBox(height: 32),
              const Text(
                'Choose your language\nElige tu idioma',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: KoruColors.dark,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 48),
              _LanguageCard(
                flag: '🇺🇸',
                language: 'English',
                code: 'en',
                onTap: () {
                  ref.read(languageProvider.notifier).state = 'en';
                  context.go('/onboarding/select');
                },
              ),
              const SizedBox(height: 16),
              _LanguageCard(
                flag: '🇪🇸',
                language: 'Español',
                code: 'es',
                onTap: () {
                  ref.read(languageProvider.notifier).state = 'es';
                  context.go('/onboarding/select');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String flag;
  final String language;
  final String code;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.flag,
    required this.language,
    required this.code,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: KoruColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: KoruColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                language,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: KoruColors.dark,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: KoruColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}
