import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class DotSelector extends StatelessWidget {
  final String label;
  final int? value;
  final int count;
  final ValueChanged<int> onChanged;

  const DotSelector({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.count = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: KoruTextStyles.bodyMuted),
        ),
        const Spacer(),
        Row(
          children: List.generate(count, (i) {
            final index = i + 1;
            final filled = value != null && index <= value!;
            return GestureDetector(
              onTap: () => onChanged(index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? KoruColors.mid : KoruColors.border,
                ),
                child: filled
                    ? null
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }
}
