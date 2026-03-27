import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/strings.dart';
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
    final s = ref.watch(stringsProvider);

    if (entries.length < 7) {
      return _LockedView(count: entries.length, s: s);
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
                      Expanded(child: Text(s.yourPatterns, style: KoruTextStyles.headline)),
                      TextButton(
                        onPressed: () => context.go('/patterns/report'),
                        child: Text(s.reportBtn, style: const TextStyle(color: KoruColors.mid)),
                      ),
                    ],
                  ),
                  Text(s.basedOnEntries(entries.length), style: KoruTextStyles.bodyMuted),
                  const SizedBox(height: 20),
                  _StatGrid(entries: entries, s: s),
                  const SizedBox(height: 24),
                  _SectionLabel(s.moodDistribution),
                  const SizedBox(height: 12),
                  _MoodDistributionBar(entries: entries, s: s),
                  if (isdia) ...[
                    const SizedBox(height: 24),
                    _SectionLabel(s.glucoseOverTime),
                    const SizedBox(height: 12),
                    _GlucoseChart(entries: entries, s: s),
                  ],
                  const SizedBox(height: 24),
                  _SectionLabel(s.mostFrequentSymptoms),
                  const SizedBox(height: 12),
                  _SymptomList(entries: entries, s: s),
                  const SizedBox(height: 24),
                  _SectionLabel(s.correlations),
                  const SizedBox(height: 12),
                  ..._buildCorrelations(s).map(
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

  List<_CorrelationData> _buildCorrelations(S s) => [
        _CorrelationData(conditionA: s.isSpanish ? 'Café ×3+' : 'Coffee ×3+', conditionB: s.isSpanish ? 'Dolor de cabeza' : 'Headache', badge: s.badgeHigh, timesOut: 3, timesTotal: 4, correlation: 0.82, color: KoruColors.danger),
        _CorrelationData(conditionA: s.isSpanish ? 'Mal sueño' : 'Poor Sleep', conditionB: s.isSpanish ? 'Bajo ánimo' : 'Low Mood', badge: s.badgeHigh, timesOut: 4, timesTotal: 5, correlation: 0.78, color: KoruColors.danger),
        _CorrelationData(conditionA: s.isSpanish ? 'Ejercicio' : 'Exercise', conditionB: s.isSpanish ? 'Buen ánimo' : 'Good Mood', badge: s.badgePositive, timesOut: 3, timesTotal: 3, correlation: 0.91, color: KoruColors.success),
        _CorrelationData(conditionA: s.isSpanish ? 'Estrés alto' : 'High Stress', conditionB: s.isSpanish ? 'Problemas de sueño' : 'Sleep Issues', badge: s.badgeMedium, timesOut: 2, timesTotal: 4, correlation: 0.55, color: KoruColors.neutralMood),
      ];
}

class _CorrelationData {
  final String conditionA, conditionB, badge;
  final int timesOut, timesTotal;
  final double correlation;
  final Color color;
  const _CorrelationData({required this.conditionA, required this.conditionB, required this.badge, required this.timesOut, required this.timesTotal, required this.correlation, required this.color});
}

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
  final S s;
  const _StatGrid({required this.entries, required this.s});

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
        StatCard(emoji: '📅', value: '${entries.length}', label: s.statTotalEntries),
        StatCard(emoji: '😴', value: avgSleepStr, label: s.statAvgSleep),
        StatCard(emoji: '🏃', value: exercisePct, label: s.statExerciseDays),
        StatCard(emoji: '😊', value: goodPct, label: s.statGoodDays),
      ],
    );
  }
}

class _MoodDistributionBar extends StatelessWidget {
  final List<CheckInEntry> entries;
  final S s;
  const _MoodDistributionBar({required this.entries, required this.s});

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
              _Legend(color: KoruColors.success, label: '${s.moodGood} ${(goodPct * 100).round()}%'),
              const SizedBox(width: 16),
              _Legend(color: KoruColors.neutralMood, label: '${s.moodNeutral} ${(neutralPct * 100).round()}%'),
              const SizedBox(width: 16),
              _Legend(color: KoruColors.danger, label: '${s.moodBad} ${(badPct * 100).round()}%'),
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
  final S s;
  const _GlucoseChart({required this.entries, required this.s});

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
                  s.avgGlucoseLabel(avg.toStringAsFixed(0)),
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
  final S s;
  const _SymptomList({required this.entries, required this.s});

  @override
  Widget build(BuildContext context) {
    final freq = <String, int>{};
    for (final e in entries) {
      for (final s in e.symptoms) {
        freq[s] = (freq[s] ?? 0) + 1;
      }
    }
    if (freq.isEmpty) {
      return Text(s.noSymptomsRecorded, style: KoruTextStyles.bodyMuted);
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

class _CorrelationCard extends ConsumerWidget {
  final _CorrelationData card;
  const _CorrelationCard({required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
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
              Expanded(child: Text('${card.conditionA} → ${card.conditionB}', style: KoruTextStyles.title)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: card.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: Text(card.badge, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: card.color, letterSpacing: 0.8)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            s.correlationStat(card.timesOut, card.timesTotal, (card.correlation * 100).round()),
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
  final S s;
  const _LockedView({required this.count, required this.s});

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
              Text(s.yourPatterns, style: KoruTextStyles.headline),
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    const Text('🔍', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(s.patternsUnlockAfter7, style: KoruTextStyles.title),
                    const SizedBox(height: 8),
                    Text(
                      s.daysToUnlock(count),
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
