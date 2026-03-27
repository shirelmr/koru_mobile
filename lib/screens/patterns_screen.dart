import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/colors.dart';
import '../core/theme/text_styles.dart';
import '../core/widgets/stat_card.dart';
import '../models/app_models.dart';
import '../providers/app_provider.dart';

class PatternsScreen extends ConsumerWidget {
  const PatternsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final entries = state.entries;
    final isdia = state.profile == UserProfile.diabetes;

    if (entries.length < 7) {
      return _LockedView(count: entries.length);
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Your Patterns',
                          style: KoruTextStyles.headline,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/patterns/report'),
                        child: const Text(
                          '📋 Report',
                          style: TextStyle(color: KoruColors.mid),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Based on ${entries.length} entries',
                    style: KoruTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: 20),
                  _StatGrid(entries: entries),
                  const SizedBox(height: 24),
                  _SectionLabel('Mood Distribution'),
                  const SizedBox(height: 12),
                  _MoodDistributionBar(entries: entries),
                  if (isdia) ...[
                    const SizedBox(height: 24),
                    _SectionLabel('Glucose Over Time'),
                    const SizedBox(height: 12),
                    _GlucoseChart(entries: entries),
                  ],
                  const SizedBox(height: 24),
                  _SectionLabel('Most Frequent Symptoms'),
                  const SizedBox(height: 12),
                  _SymptomList(entries: entries),
                  const SizedBox(height: 24),
                  _SectionLabel('Correlations'),
                  const SizedBox(height: 12),
                  ..._mockCorrelations.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CorrelationCard(card: c),
                    ),
                  ),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _mockCorrelations = [
  (
    conditionA: 'Coffee ×3+',
    conditionB: 'Headache',
    badge: 'HIGH',
    timesOut: 3,
    timesTotal: 4,
    correlation: 0.82,
    color: KoruColors.danger,
  ),
  (
    conditionA: 'Poor Sleep',
    conditionB: 'Low Mood',
    badge: 'HIGH',
    timesOut: 4,
    timesTotal: 5,
    correlation: 0.78,
    color: KoruColors.danger,
  ),
  (
    conditionA: 'Exercise',
    conditionB: 'Good Mood',
    badge: 'POSITIVE',
    timesOut: 3,
    timesTotal: 3,
    correlation: 0.91,
    color: KoruColors.success,
  ),
  (
    conditionA: 'High Stress',
    conditionB: 'Sleep Issues',
    badge: 'MEDIUM',
    timesOut: 2,
    timesTotal: 4,
    correlation: 0.55,
    color: KoruColors.neutralMood,
  ),
];

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: KoruTextStyles.label);
  }
}

class _StatGrid extends StatelessWidget {
  final List<CheckInEntry> entries;
  const _StatGrid({required this.entries});

  @override
  Widget build(BuildContext context) {
    final avgSleep = entries
        .where((e) => e.sleepQuality != null)
        .map((e) => e.sleepQuality!)
        .fold(0, (a, b) => a + b);
    final sleepCount =
        entries.where((e) => e.sleepQuality != null).length;
    final avgSleepStr = sleepCount > 0
        ? '${(avgSleep / sleepCount).toStringAsFixed(1)}/5'
        : '--';

    final exerciseDays =
        entries.where((e) => e.exercise.isNotEmpty).length;
    final exercisePct = '${((exerciseDays / entries.length) * 100).round()}%';

    final goodDays =
        entries.where((e) => e.moodCategory == MoodCategory.good).length;
    final goodPct = '${((goodDays / entries.length) * 100).round()}%';

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.3,
      children: [
        StatCard(
          emoji: '📅',
          value: '${entries.length}',
          label: 'Total Entries',
        ),
        StatCard(
          emoji: '😴',
          value: avgSleepStr,
          label: 'Avg Sleep',
        ),
        StatCard(
          emoji: '🏃',
          value: exercisePct,
          label: 'Exercise Days',
        ),
        StatCard(
          emoji: '😊',
          value: goodPct,
          label: 'Good Days',
        ),
      ],
    );
  }
}

class _MoodDistributionBar extends StatelessWidget {
  final List<CheckInEntry> entries;
  const _MoodDistributionBar({required this.entries});

  @override
  Widget build(BuildContext context) {
    final good =
        entries.where((e) => e.moodCategory == MoodCategory.good).length;
    final neutral =
        entries.where((e) => e.moodCategory == MoodCategory.neutral).length;
    final bad =
        entries.where((e) => e.moodCategory == MoodCategory.bad).length;
    final total = entries.length;
    if (total == 0) return const SizedBox();

    final goodPct = good / total;
    final neutralPct = neutral / total;
    final badPct = bad / total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KoruColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KoruColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                Flexible(
                  flex: (goodPct * 100).round(),
                  child: Container(height: 16, color: KoruColors.success),
                ),
                Flexible(
                  flex: (neutralPct * 100).round(),
                  child: Container(height: 16, color: KoruColors.neutralMood),
                ),
                Flexible(
                  flex: (badPct * 100).round(),
                  child: Container(height: 16, color: KoruColors.danger),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Legend(color: KoruColors.success, label: 'Good ${(goodPct * 100).round()}%'),
              const SizedBox(width: 16),
              _Legend(color: KoruColors.neutralMood, label: 'Neutral ${(neutralPct * 100).round()}%'),
              const SizedBox(width: 16),
              _Legend(color: KoruColors.danger, label: 'Bad ${(badPct * 100).round()}%'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: KoruTextStyles.bodyMuted),
      ],
    );
  }
}

class _GlucoseChart extends StatelessWidget {
  final List<CheckInEntry> entries;
  const _GlucoseChart({required this.entries});

  @override
  Widget build(BuildContext context) {
    final glucoseEntries = entries
        .where((e) => e.glucose != null)
        .take(10)
        .toList()
        .reversed
        .toList();

    if (glucoseEntries.isEmpty) return const SizedBox();

    final avg = glucoseEntries
            .map((e) => e.glucose!)
            .reduce((a, b) => a + b) /
        glucoseEntries.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KoruColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KoruColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: avg > 140
                      ? KoruColors.dangerBg
                      : KoruColors.chip,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Avg ${avg.toStringAsFixed(0)} mg/dL',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: avg > 140 ? KoruColors.danger : KoruColors.chipText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                maxY: 200,
                minY: 0,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= glucoseEntries.length) return const SizedBox();
                        return Text(
                          '${glucoseEntries[idx].date.day}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: KoruColors.muted,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: glucoseEntries.asMap().entries.map((e) {
                  final g = e.value.glucose!;
                  final color = g > 140
                      ? KoruColors.danger
                      : g < 70
                          ? KoruColors.neutralMood
                          : KoruColors.success;
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(toY: g, color: color, width: 12, borderRadius: BorderRadius.circular(4)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SymptomList extends StatelessWidget {
  final List<CheckInEntry> entries;
  const _SymptomList({required this.entries});

  @override
  Widget build(BuildContext context) {
    final freq = <String, int>{};
    for (final e in entries) {
      for (final s in e.symptoms) {
        freq[s] = (freq[s] ?? 0) + 1;
      }
    }
    if (freq.isEmpty) {
      return const Text('No symptoms recorded.', style: KoruTextStyles.bodyMuted);
    }
    final sorted = freq.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = sorted.first.value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KoruColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KoruColors.border, width: 0.5),
      ),
      child: Column(
        children: sorted.map((e) {
          final pct = e.value / maxCount;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text(e.key, style: KoruTextStyles.body),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: KoruColors.border,
                      color: KoruColors.danger,
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${e.value}×', style: KoruTextStyles.bodyMuted),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CorrelationCard extends StatelessWidget {
  final ({
    String conditionA,
    String conditionB,
    String badge,
    int timesOut,
    int timesTotal,
    double correlation,
    Color color,
  }) card;

  const _CorrelationCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KoruColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KoruColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${card.conditionA} → ${card.conditionB}',
                  style: KoruTextStyles.title,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: card.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  card.badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: card.color,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${card.timesOut} of ${card.timesTotal} times · ${(card.correlation * 100).round()}% correlation',
            style: KoruTextStyles.bodyMuted,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: card.correlation,
              backgroundColor: KoruColors.border,
              color: card.color,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedView extends StatelessWidget {
  final int count;
  const _LockedView({required this.count});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text('Your Patterns', style: KoruTextStyles.headline),
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    const Text('🔍', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    const Text(
                      'Patterns unlock after 7 days',
                      style: KoruTextStyles.title,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$count of 7 days logged to unlock your patterns',
                      style: KoruTextStyles.bodyMuted,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: count / 7,
                        backgroundColor: KoruColors.border,
                        color: KoruColors.mid,
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
