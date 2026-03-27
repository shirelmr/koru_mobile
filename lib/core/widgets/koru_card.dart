import 'package:flutter/material.dart';
import '../theme/colors.dart';

class KoruCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;

  const KoruCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color ?? KoruColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: KoruColors.border, width: 0.5),
        ),
        child: child,
      ),
    );
  }
}
