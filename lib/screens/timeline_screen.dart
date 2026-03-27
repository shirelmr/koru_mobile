import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/theme/colors.dart';
import '../core/theme/text_styles.dart';
import '../core/widgets/koru_chip.dart';
import '../core/widgets/mood_dot.dart';
import '../models/app_models.dart';
import '../providers/app_provider.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  DateTime _month = DateTime(2026, 3);

  void _prevMonth() => setState(() {
        _month = DateTime(_month.year, _month.month - 1);
      });

  void _nextMonth() => setState(() {
        _month = DateTime(_month.year, _month.month + 1);
      });

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(appProvider).entries;
    final visible = entries
        .where((e) => e.date.year == _month.year && e.date.month == _month.month)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),
                  const Text('Your Timeline', style: KoruTextStyles.headline),
                  const SizedBox(height: 4),
                  const Text(
                    'Track how you\'ve been feeling',
                    style: KoruTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: 20),
                  _MonthNav(
                    month: _month,
                    onPrev: _prevMonth,
                    onNext: _nextMonth,
                  ),
                  const SizedBox(height: 16),
                ]),
              ),
            ),
            if (visible.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = visible[index];
                      return _TimelineRow(entry: entry);
                    },
                    childCount: visible.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _MonthNav extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthNav({required this.month, required this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onPrev,
          icon: const Icon(Icons.chevron_left),
          color: KoruColors.muted,
        ),
        Expanded(
          child: Center(
            child: Text(
              DateFormat('MMMM yyyy').format(month),
              style: KoruTextStyles.title,
            ),
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
          color: KoruColors.muted,
        ),
      ],
    );
  }
}

class _TimelineRow extends StatefulWidget {
  final CheckInEntry entry;
  const _TimelineRow({required this.entry});

  @override
  State<_TimelineRow> createState() => _TimelineRowState();
}

class _TimelineRowState extends State<_TimelineRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    final allChips = [...e.symptoms, ...e.intake, ...e.exercise];
    final visibleChips = allChips.take(3).toList();
    final overflow = allChips.length - visibleChips.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: KoruColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: KoruColors.border, width: 0.5),
        ),
        child: Column(
          children: [
            // Collapsed row
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day number
                    Column(
                      children: [
                        Text(
                          e.date.day.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: KoruColors.dark,
                          ),
                        ),
                        Text(
                          DateFormat('EEE').format(e.date),
                          style: KoruTextStyles.label,
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              MoodDot(mood: e.moodCategory),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  e.text,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: KoruTextStyles.bodyMuted,
                                ),
                              ),
                            ],
                          ),
                          if (visibleChips.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                ...visibleChips.map(
                                  (c) => KoruChip(label: c),
                                ),
                                if (overflow > 0)
                                  KoruChip(label: '+$overflow more'),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: KoruColors.muted,
                    ),
                  ],
                ),
              ),
            ),
            // Expanded detail
            if (_expanded) ...[
              const Divider(height: 1, color: KoruColors.border),
              Padding(
                padding: const EdgeInsets.all(14),
                child: _ExpandedDetail(entry: e),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExpandedDetail extends StatelessWidget {
  final CheckInEntry entry;
  const _ExpandedDetail({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (entry.sleepQuality != null)
              _Tile(
                emoji: '😴',
                label: 'Sleep',
                value: '${entry.sleepQuality}/5',
              ),
            if (entry.stressLevel != null)
              _Tile(
                emoji: '😤',
                label: 'Stress',
                value: '${entry.stressLevel}/5',
              ),
            if (entry.mood != null)
              _Tile(
                emoji: '😊',
                label: 'Mood',
                value: '${entry.mood}/5',
              ),
            if (entry.focus != null)
              _Tile(
                emoji: '🎯',
                label: 'Focus',
                value: '${entry.focus}/5',
              ),
            if (entry.glucose != null)
              _Tile(
                emoji: '🩸',
                label: 'Glucose',
                value: '${entry.glucose!.toStringAsFixed(0)} mg/dL',
                danger: entry.glucose! > 140,
              ),
            if (entry.carbIntake != null)
              _Tile(
                emoji: '🥗',
                label: 'Carbs',
                value: entry.carbIntake!.name[0].toUpperCase() +
                    entry.carbIntake!.name.substring(1),
              ),
            if (entry.lastMeal != null)
              _Tile(
                emoji: '🍽',
                label: 'Last Meal',
                value: entry.lastMeal!.name[0].toUpperCase() +
                    entry.lastMeal!.name.substring(1),
              ),
          ],
        ),
        if (entry.text.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Your Entry', style: KoruTextStyles.label),
          const SizedBox(height: 4),
          Text(entry.text, style: KoruTextStyles.body),
        ],
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final bool danger;

  const _Tile({
    required this.emoji,
    required this.label,
    required this.value,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: danger ? KoruColors.dangerBg : KoruColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: danger ? KoruColors.danger.withValues(alpha: 0.3) : KoruColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji),
          Text(
            label.toUpperCase(),
            style: KoruTextStyles.label.copyWith(fontSize: 10),
          ),
          Text(
            value,
            style: KoruTextStyles.title.copyWith(
              fontSize: 14,
              color: danger ? KoruColors.danger : KoruColors.dark,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📅', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 16),
          const Text('No entries this month', style: KoruTextStyles.title),
          const SizedBox(height: 8),
          Text(
            'Start your first check-in today',
            style: KoruTextStyles.bodyMuted,
          ),
        ],
      ),
    );
  }
}
