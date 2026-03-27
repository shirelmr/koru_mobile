import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/strings.dart';
import '../core/theme/colors.dart';

class ShellScreen extends ConsumerWidget {
  final StatefulNavigationShell shell;

  const ShellScreen({super.key, required this.shell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);

    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: KoruColors.dark,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.radio_button_checked_rounded,
                  label: s.navCheckIn,
                  selected: shell.currentIndex == 0,
                  onTap: () => shell.goBranch(0),
                ),
                _NavItem(
                  icon: Icons.show_chart_rounded,
                  label: s.navTimeline,
                  selected: shell.currentIndex == 1,
                  onTap: () => shell.goBranch(1),
                ),
                _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: s.navPatterns,
                  selected: shell.currentIndex == 2,
                  onTap: () => shell.goBranch(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? Colors.white : KoruColors.sage,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? Colors.white : KoruColors.sage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
