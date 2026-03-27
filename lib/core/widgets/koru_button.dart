import 'package:flutter/material.dart';
import '../theme/colors.dart';

class KoruButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outline;
  final bool loading;
  final IconData? icon;

  const KoruButton({
    super.key,
    required this.label,
    this.onPressed,
    this.outline = false,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: outline
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: KoruColors.mid, width: 1.5),
                foregroundColor: KoruColors.mid,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: _child(),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    onPressed == null ? KoruColors.border : KoruColors.mid,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: _child(),
            ),
    );
  }

  Widget _child() {
    if (loading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        if (icon != null) ...[
          const SizedBox(width: 6),
          Icon(icon, size: 18),
        ],
      ],
    );
  }
}
