import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const StatCard({
    super.key,
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KoruColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KoruColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: KoruColors.dark,
            ),
          ),
          const SizedBox(height: 2),
          Text(label.toUpperCase(), style: KoruTextStyles.label),
        ],
      ),
    );
  }
}
