import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

enum KoruChipVariant { normal, danger, warning, active }

class KoruChip extends StatelessWidget {
  final String label;
  final KoruChipVariant variant;
  final VoidCallback? onRemove;

  const KoruChip({
    super.key,
    required this.label,
    this.variant = KoruChipVariant.normal,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (variant) {
      KoruChipVariant.danger => (KoruColors.dangerBg, KoruColors.danger),
      KoruChipVariant.warning => (KoruColors.warningBg, KoruColors.warning),
      KoruChipVariant.active => (KoruColors.dark, Colors.white),
      KoruChipVariant.normal => (KoruColors.chip, KoruColors.chipText),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: KoruTextStyles.chipLabel.copyWith(color: fg)),
          if (onRemove != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close, size: 14, color: fg.withValues(alpha: 0.7)),
            ),
          ],
        ],
      ),
    );
  }
}
