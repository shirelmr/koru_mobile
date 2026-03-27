import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/strings.dart';
import '../core/theme/colors.dart';
import '../core/theme/text_styles.dart';
import '../core/widgets/koru_chip.dart';
import '../core/widgets/mood_dot.dart';
import '../models/app_models.dart';
import '../providers/app_provider.dart';
import '../providers/language_provider.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  DateTime _month = DateTime(2026, 3);

  void _prevMonth() => setState(() => _month = DateTime(_month.year, _month.month - 1));
  void _nextMonth() => setState(() => _month = DateTime(_month.year, _month.month + 1));

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(appProvider).entries;
    final s = ref.watch(stringsProvider);
    final lang = ref.watch(languageProvider);
    final locale = lang == 'es' ? 'es' : 'en';
    final visible = entries.where((e) => e.date.year == _month.year && e.date.month == _month.month).toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),
                  Text(s.yourTimeline, style: KoruTextStyles.headline),
                  const SizedBox(height: 4),
                  Text(s.timelineSubtitle, style: KoruTextStyles.bodyMuted),
                  const SizedBox(height: 20),
                  _MonthNav(month: _month, onPrev: _prevMonth, onNext: _nextMonth, locale: locale),
                  const SizedBox(height: 16),
                ]),
              ),
            ),
            if (visible.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(s: s),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _TimelineRow(entry: visible[index], s: s, locale: locale),
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
  final String locale;

  const _MonthNav({required this.month, required this.onPrev, required this.onNext, required this.locale});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left), color: KoruColors.muted),
        Expanded(
          child: Center(
            child: Text(DateFormat('MMMM yyyy', locale).format(month), style: KoruTextStyles.title),
          ),
        ),
        IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right), color: KoruColors.muted),
      ],
    );
  }
}

class _TimelineRow extends StatefulWidget {
  final CheckInEntry entry;
  final S s;
  final String locale;
  const _TimelineRow({required this.entry, required this.s, required this.locale});

  @override
  State<_TimelineRow> createState() => _TimelineRowState();
}

class _TimelineRowState extends State<_TimelineRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    final s = widget.s;
    final allChips = [...e.symptoms, ...e.intake, ...e.exercise];
    final visibleChips = allChips.take(3).toList();
    final overflow = allChips.length - visibleChips.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(color: KoruColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: KoruColors.border, width: 0.5)),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text(e.date.day.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: KoruColors.dark)),
                        Text(DateFormat('EEE', widget.locale).format(e.date), style: KoruTextStyles.label),
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
                              Expanded(child: Text(e.text, maxLines: 1, overflow: TextOverflow.ellipsis, style: KoruTextStyles.bodyMuted)),
                            ],
                          ),
                          if (visibleChips.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                ...visibleChips.map((c) => KoruChip(label: c)),
                                if (overflow > 0) KoruChip(label: s.moreChips(overflow)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: KoruColors.muted),
                  ],
                ),
              ),
            ),
            if (_expanded) ...[
              const Divider(height: 1, color: KoruColors.border),
              Padding(padding: const EdgeInsets.all(14), child: _ExpandedDetail(entry: e, s: s)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExpandedDetail extends StatelessWidget {
  final CheckInEntry entry;
  final S s;
  const _ExpandedDetail({required this.entry, required this.s});

  @override
  Widget build(BuildContext context) {
    final e = entry;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (e.sleepQuality != null) _Tile(emoji: '😴', label: s.tileSleep, value: '${e.sleepQuality}/5'),
            if (e.stressLevel != null) _Tile(emoji: '😤', label: s.tileStress, value: '${e.stressLevel}/5'),
            if (e.mood != null) _Tile(emoji: '😊', label: s.tileMood, value: '${e.mood}/5'),
            if (e.focus != null) _Tile(emoji: '🎯', label: s.tileFocus, value: '${e.focus}/5'),
            if (e.glucose != null) _Tile(emoji: '🩸', label: s.tileGlucose, value: '${e.glucose!.toStringAsFixed(0)} mg/dL', danger: e.glucose! > 140),
            if (e.carbIntake != null) _Tile(emoji: '🥗', label: s.tileCarbs, value: _carbLabel(e.carbIntake!, s)),
            if (e.lastMeal != null) _Tile(emoji: '🍽', label: s.tileLastMeal, value: _mealLabel(e.lastMeal!, s)),
          ],
        ),
        if (e.text.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(s.yourEntry.toUpperCase(), style: KoruTextStyles.label),
          const SizedBox(height: 4),
          Text(e.text, style: KoruTextStyles.body),
        ],
      ],
    );
  }

  String _carbLabel(CarbIntake c, S s) => switch (c) {
    CarbIntake.low => s.carbLow,
    CarbIntake.medium => s.carbMedium,
    CarbIntake.high => s.carbHigh,
  };

  String _mealLabel(MealType m, S s) => switch (m) {
    MealType.breakfast => s.mealBreakfast,
    MealType.lunch => s.mealLunch,
    MealType.dinner => s.mealDinner,
    MealType.snack => s.mealSnack,
  };
}

class _Tile extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final bool danger;

  const _Tile({required this.emoji, required this.label, required this.value, this.danger = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: danger ? KoruColors.dangerBg : KoruColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: danger ? KoruColors.danger.withValues(alpha: 0.3) : KoruColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji),
          Text(label.toUpperCase(), style: KoruTextStyles.label.copyWith(fontSize: 10)),
          Text(value, style: KoruTextStyles.title.copyWith(fontSize: 14, color: danger ? KoruColors.danger : KoruColors.dark)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final S s;
  const _EmptyState({required this.s});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📅', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 16),
          Text(s.noEntriesThisMonth, style: KoruTextStyles.title),
          const SizedBox(height: 8),
          Text(s.startFirstCheckIn, style: KoruTextStyles.bodyMuted),
        ],
      ),
    );
  }
}
