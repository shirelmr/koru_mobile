import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../theme/colors.dart';

class MoodDot extends StatelessWidget {
  final MoodCategory mood;
  final double size;

  const MoodDot({super.key, required this.mood, this.size = 10});

  @override
  Widget build(BuildContext context) {
    final color = switch (mood) {
      MoodCategory.good => KoruColors.success,
      MoodCategory.neutral => KoruColors.neutralMood,
      MoodCategory.bad => KoruColors.danger,
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
