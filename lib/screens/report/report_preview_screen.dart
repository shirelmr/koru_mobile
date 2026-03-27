import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/strings.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/koru_button.dart';
import '../../core/widgets/koru_chip.dart';
import '../../models/app_models.dart';
import '../../providers/app_provider.dart';
import 'report_configure_screen.dart';

class ReportPreviewScreen extends ConsumerWidget {
  const ReportPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appProvider);
    final config = ref.watch(reportConfigProvider);
    final entries = appState.entries;
    final isdia = appState.profile == UserProfile.diabetes;
    final s = ref.watch(stringsProvider);

    final glucoseEntries = entries.where((e) => e.glucose != null).toList();
    final avgGlucose = glucoseEntries.isEmpty
        ? null
        : glucoseEntries.map((e) => e.glucose!).reduce((a, b) => a + b) /
            glucoseEntries.length;
    final highSpikes =
        glucoseEntries.where((e) => e.glucose! > 140).length;
    final insulinDays = entries.where((e) => e.insulinTaken).length;
    final insulinPct = entries.isEmpty
        ? 0
        : ((insulinDays / entries.length) * 100).round();

    final allSymptoms = <String, int>{};
    for (final e in entries) {
      for (final s in e.symptoms) {
        allSymptoms[s] = (allSymptoms[s] ?? 0) + 1;
      }
    }
    final topFoods = s.isSpanish
        ? <String>{'Café ×3+', 'Comida saltada', 'Agua', 'Alcohol'}
        : <String>{'Coffee ×3+', 'Skipped meal', 'Water', 'Alcohol'};

    return Scaffold(
      appBar: AppBar(
        title: Text(s.reportPreview),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/patterns/report/preview/export'),
            icon: const Icon(Icons.share_outlined, size: 18),
            label: Text(s.export),
            style: TextButton.styleFrom(foregroundColor: KoruColors.mid),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Dark header card
          Container(
            color: KoruColors.dark,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Kōru',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Georgia',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: KoruColors.sage.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isdia ? '🩸 Diabetes' : '💚 General Health',
                        style: const TextStyle(
                          color: KoruColors.sage,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _periodLabel(config.period, entries),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${entries.length} ${s.daysLabel}',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isdia && avgGlucose != null) ...[
                  _SectionHeader(s.glucoseSummary),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: KoruColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: KoruColors.border, width: 0.5)),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _StatPill(label: s.avgGlucose, value: '${avgGlucose.toStringAsFixed(0)} mg/dL', highlight: avgGlucose > 140),
                            const SizedBox(width: 10),
                            _StatPill(label: s.spikesLabel, value: '$highSpikes ${s.daysLabel}', highlight: highSpikes > 3),
                            const SizedBox(width: 10),
                            _StatPill(label: s.insulinTakenLabel, value: '$insulinPct%'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _GlucoseBar(entries: entries, s: s),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                _SectionHeader(s.foodsIntake),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: topFoods.map((f) => KoruChip(label: f, variant: (f.contains('Café') || f.contains('Coffee') || f.contains('Skip') || f.contains('saltada')) ? KoruChipVariant.warning : KoruChipVariant.normal)).toList(),
                ),
                if (allSymptoms.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _SectionHeader(s.detectedCorrelations),
                  const SizedBox(height: 12),
                  _CorrelationList(s: s),
                ],
                const SizedBox(height: 24),
                _SectionHeader(s.dayByDaySection),
                const SizedBox(height: 12),
                ...entries.take(5).map((e) => _DayRow(entry: e)),
                if (entries.length > 5) ...[
                  const SizedBox(height: 8),
                  Center(child: Text(s.moreDays(entries.length - 5), style: KoruTextStyles.bodyMuted)),
                ],
                const SizedBox(height: 40),
                KoruButton(
                  label: s.exportPdf,
                  icon: Icons.picture_as_pdf_outlined,
                  onPressed: () =>
                      context.go('/patterns/report/preview/export'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _periodLabel(ReportPeriod p, List<CheckInEntry> entries) {
    if (entries.isEmpty) return '';
    final fmt = DateFormat('MMM d, yyyy');
    return '${fmt.format(entries.last.date)} – ${fmt.format(entries.first.date)}';
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: KoruTextStyles.label);
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _StatPill({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: highlight ? KoruColors.dangerBg : KoruColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: highlight ? KoruColors.danger : KoruColors.dark,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: KoruColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlucoseBar extends StatelessWidget {
  final List<CheckInEntry> entries;
  final S s;
  const _GlucoseBar({required this.entries, required this.s});

  @override
  Widget build(BuildContext context) {
    final glucoseEntries =
        entries.where((e) => e.glucose != null).take(10).toList().reversed.toList();
    if (glucoseEntries.isEmpty) return const SizedBox();
    final inRange =
        glucoseEntries.where((e) => e.glucose! >= 70 && e.glucose! <= 140).length;
    final rangePct = (inRange / glucoseEntries.length * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: glucoseEntries.map((e) {
            final g = e.glucose!;
            final color = g > 140
                ? KoruColors.danger
                : g < 70
                    ? KoruColors.neutralMood
                    : KoruColors.success;
            final barH = (g / 200 * 40).clamp(4.0, 40.0);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: barH,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${e.date.day}',
                      style: const TextStyle(
                        fontSize: 9,
                        color: KoruColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(s.daysInRange(rangePct), style: KoruTextStyles.bodyMuted),
      ],
    );
  }
}

class _CorrelationList extends StatelessWidget {
  final S s;
  const _CorrelationList({required this.s});

  @override
  Widget build(BuildContext context) {
    final items = s.isSpanish
        ? [('Café ×3+', 'Dolor de cabeza', '82%'), ('Mal sueño', 'Bajo ánimo', '78%'), ('Ejercicio', 'Buen ánimo', '91%')]
        : [('Coffee ×3+', 'Headache', '82%'), ('Poor Sleep', 'Low Mood', '78%'), ('Exercise', 'Good Mood', '91%')];
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${item.$1} → ${item.$2}',
                  style: KoruTextStyles.body,
                ),
              ),
              Text(item.$3, style: KoruTextStyles.bodyMuted),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DayRow extends StatefulWidget {
  final CheckInEntry entry;
  const _DayRow({required this.entry});

  @override
  State<_DayRow> createState() => _DayRowState();
}

class _DayRowState extends State<_DayRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: KoruColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: KoruColors.border, width: 0.5),
        ),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      DateFormat('MMM d').format(e.date),
                      style: KoruTextStyles.title,
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: switch (e.moodCategory) {
                          MoodCategory.good => KoruColors.success,
                          MoodCategory.neutral => KoruColors.neutralMood,
                          MoodCategory.bad => KoruColors.danger,
                        },
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (e.glucose != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: e.glucose! > 140
                              ? KoruColors.dangerBg
                              : KoruColors.chip,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${e.glucose!.toStringAsFixed(0)} mg/dL',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: e.glucose! > 140
                                ? KoruColors.danger
                                : KoruColors.chipText,
                          ),
                        ),
                      ),
                    const Spacer(),
                    if (e.symptoms.isNotEmpty)
                      KoruChip(
                        label: e.symptoms.first,
                        variant: KoruChipVariant.danger,
                      ),
                    const SizedBox(width: 4),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 18,
                      color: KoruColors.muted,
                    ),
                  ],
                ),
              ),
            ),
            if (_expanded) ...[
              const Divider(height: 1, color: KoruColors.border),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Text(e.text, style: KoruTextStyles.bodyMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
