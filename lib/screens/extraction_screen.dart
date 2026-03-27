import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/colors.dart';
import '../core/theme/text_styles.dart';
import '../core/widgets/koru_button.dart';
import '../core/widgets/koru_chip.dart';
import '../providers/app_provider.dart';

class ExtractionScreen extends ConsumerStatefulWidget {
  const ExtractionScreen({super.key});

  @override
  ConsumerState<ExtractionScreen> createState() => _ExtractionScreenState();
}

class _ExtractionScreenState extends ConsumerState<ExtractionScreen> {
  late Map<String, List<String>> _chips;

  @override
  void initState() {
    super.initState();
    final state = ref.read(appProvider);
    final ex = state.pendingExtraction;
    _chips = ex?.toChipMap(state.profile) ??
        {
          '😵 Symptoms': [],
          '😴 Sleep': [],
          '🍽 Intake': [],
          '😤 Stress': [],
          '🏃 Exercise': [],
          '😊 Mood': [],
        };
  }

  void _removeChip(String category, String chip) {
    setState(() {
      _chips[category]?.remove(chip);
    });
  }

  void _addChip(String category) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add to $category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter tag...'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        _chips[category]?.add(result.trim());
      });
    }
  }

  void _confirm() {
    ref.read(appProvider.notifier).confirmEntry();
    context.go('/check-in');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 20),
                        // Header
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: KoruColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ANALYSIS COMPLETE',
                              style: KoruTextStyles.label.copyWith(
                                color: KoruColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Here's what I found",
                          style: KoruTextStyles.headline,
                        ),
                        const SizedBox(height: 24),
                        // Chip grid
                        ..._buildChipGrid(),
                        const SizedBox(height: 32),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                children: [
                  KoruButton(
                    label: 'Confirm & Save',
                    icon: Icons.check,
                    onPressed: _confirm,
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text(
                      'Edit manually',
                      style: TextStyle(color: KoruColors.muted, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildChipGrid() {
    final keys = _chips.keys.toList();
    final rows = <Widget>[];
    for (int i = 0; i < keys.length; i += 2) {
      final leftKey = keys[i];
      final rightKey = i + 1 < keys.length ? keys[i + 1] : null;
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _ChipCell(
                categoryKey: leftKey,
                chips: _chips[leftKey] ?? [],
                onRemove: (chip) => _removeChip(leftKey, chip),
                onAdd: () => _addChip(leftKey),
              )),
              const SizedBox(width: 10),
              Expanded(
                child: rightKey != null
                    ? _ChipCell(
                        categoryKey: rightKey,
                        chips: _chips[rightKey] ?? [],
                        onRemove: (chip) => _removeChip(rightKey, chip),
                        onAdd: () => _addChip(rightKey),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      );
      rows.add(const SizedBox(height: 10));
    }
    return rows;
  }
}

class _ChipCell extends StatelessWidget {
  final String categoryKey;
  final List<String> chips;
  final ValueChanged<String> onRemove;
  final VoidCallback onAdd;

  const _ChipCell({
    required this.categoryKey,
    required this.chips,
    required this.onRemove,
    required this.onAdd,
  });

  bool get _isDanger {
    return categoryKey.contains('Symptom') || categoryKey.contains('Glucose');
  }

  bool get _isWarning {
    return categoryKey.contains('Intake') || categoryKey.contains('Carbs');
  }

  KoruChipVariant get _chipVariant {
    if (_isDanger) return KoruChipVariant.danger;
    if (_isWarning) return KoruChipVariant.warning;
    return KoruChipVariant.normal;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KoruColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KoruColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(categoryKey, style: KoruTextStyles.bodyMuted),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...chips.map(
                (chip) => KoruChip(
                  label: chip,
                  variant: _chipVariant,
                  onRemove: () => onRemove(chip),
                ),
              ),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    border: Border.all(color: KoruColors.border),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 16,
                    color: KoruColors.muted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
