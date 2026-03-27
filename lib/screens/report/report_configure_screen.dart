import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/koru_button.dart';
import '../../models/app_models.dart';
import '../../providers/app_provider.dart';

enum ReportPeriod { week7, days30, days90, custom }

final reportConfigProvider =
    StateProvider<_ReportConfig>((ref) => const _ReportConfig());

class _ReportConfig {
  final ReportPeriod period;
  final bool includeGlucose;
  final bool includeInsulin;
  final bool includeFoods;
  final bool includeSleep;
  final bool includeSymptoms;
  final bool includeCorrelations;
  final bool includeNotes;
  final bool dayByDay;
  final String doctorNote;

  const _ReportConfig({
    this.period = ReportPeriod.days30,
    this.includeGlucose = true,
    this.includeInsulin = true,
    this.includeFoods = true,
    this.includeSleep = true,
    this.includeSymptoms = true,
    this.includeCorrelations = true,
    this.includeNotes = false,
    this.dayByDay = true,
    this.doctorNote = '',
  });

  _ReportConfig copyWith({
    ReportPeriod? period,
    bool? includeGlucose,
    bool? includeInsulin,
    bool? includeFoods,
    bool? includeSleep,
    bool? includeSymptoms,
    bool? includeCorrelations,
    bool? includeNotes,
    bool? dayByDay,
    String? doctorNote,
  }) {
    return _ReportConfig(
      period: period ?? this.period,
      includeGlucose: includeGlucose ?? this.includeGlucose,
      includeInsulin: includeInsulin ?? this.includeInsulin,
      includeFoods: includeFoods ?? this.includeFoods,
      includeSleep: includeSleep ?? this.includeSleep,
      includeSymptoms: includeSymptoms ?? this.includeSymptoms,
      includeCorrelations: includeCorrelations ?? this.includeCorrelations,
      includeNotes: includeNotes ?? this.includeNotes,
      dayByDay: dayByDay ?? this.dayByDay,
      doctorNote: doctorNote ?? this.doctorNote,
    );
  }
}

class ReportConfigureScreen extends ConsumerWidget {
  const ReportConfigureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(reportConfigProvider);
    final notifier = ref.read(reportConfigProvider.notifier);
    final entries = ref.watch(appProvider).entries;
    final isdia = ref.watch(appProvider).profile == UserProfile.diabetes;
    final periodEntries = _entriesForPeriod(entries, config.period);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Report'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 8),
            const Text(
              'To bring to your doctor',
              style: KoruTextStyles.bodyMuted,
            ),
            const SizedBox(height: 24),
            // Period selector
            Text('PERIOD'.toUpperCase(), style: KoruTextStyles.label),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: ReportPeriod.values.map((p) {
                final selected = config.period == p;
                return GestureDetector(
                  onTap: () =>
                      notifier.state = config.copyWith(period: p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? KoruColors.dark : KoruColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? KoruColors.dark : KoruColors.border,
                      ),
                    ),
                    child: Text(
                      _periodLabel(p),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: selected ? Colors.white : KoruColors.dark,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              _periodSubtitle(entries, config.period),
              style: KoruTextStyles.bodyMuted,
            ),
            const SizedBox(height: 24),
            // What to include
            Text('INCLUDE'.toUpperCase(), style: KoruTextStyles.label),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: KoruColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: KoruColors.border, width: 0.5),
              ),
              child: Column(
                children: [
                  if (isdia) ...[
                    _ToggleRow(
                      emoji: '🩸',
                      label: 'Detailed daily glucose',
                      value: config.includeGlucose,
                      onChanged: (v) =>
                          notifier.state = config.copyWith(includeGlucose: v),
                    ),
                    _ToggleRow(
                      emoji: '💉',
                      label: 'Insulin per day',
                      value: config.includeInsulin,
                      onChanged: (v) =>
                          notifier.state = config.copyWith(includeInsulin: v),
                    ),
                    _ToggleRow(
                      emoji: '🍽',
                      label: 'Foods consumed (day by day)',
                      value: config.includeFoods,
                      onChanged: (v) =>
                          notifier.state = config.copyWith(includeFoods: v),
                    ),
                  ],
                  _ToggleRow(
                    emoji: '😴',
                    label: 'Sleep hours per night',
                    value: config.includeSleep,
                    onChanged: (v) =>
                        notifier.state = config.copyWith(includeSleep: v),
                  ),
                  _ToggleRow(
                    emoji: '🤕',
                    label: 'Reported symptoms',
                    value: config.includeSymptoms,
                    onChanged: (v) =>
                        notifier.state = config.copyWith(includeSymptoms: v),
                  ),
                  _ToggleRow(
                    emoji: '🔗',
                    label: 'Detected correlations',
                    value: config.includeCorrelations,
                    onChanged: (v) => notifier.state =
                        config.copyWith(includeCorrelations: v),
                  ),
                  _ToggleRow(
                    emoji: '📝',
                    label: 'Patient notes (optional)',
                    value: config.includeNotes,
                    onChanged: (v) =>
                        notifier.state = config.copyWith(includeNotes: v),
                    last: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Detail level
            Text('DETAIL LEVEL'.toUpperCase(), style: KoruTextStyles.label),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _SelectTile(
                    label: 'Summary only',
                    selected: !config.dayByDay,
                    onTap: () =>
                        notifier.state = config.copyWith(dayByDay: false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SelectTile(
                    label: 'Day by day ✓',
                    selected: config.dayByDay,
                    onTap: () =>
                        notifier.state = config.copyWith(dayByDay: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Doctor note
            Text("DOCTOR'S NOTE (OPTIONAL)".toUpperCase(),
                style: KoruTextStyles.label),
            const SizedBox(height: 10),
            TextField(
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Add a note for your doctor...',
              ),
              onChanged: (v) =>
                  notifier.state = config.copyWith(doctorNote: v),
            ),
            const SizedBox(height: 32),
            KoruButton(
              label: 'View Report',
              icon: Icons.arrow_forward,
              onPressed: periodEntries.isEmpty
                  ? null
                  : () => context.go('/patterns/report/preview'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _periodLabel(ReportPeriod p) => switch (p) {
        ReportPeriod.week7 => '7 days',
        ReportPeriod.days30 => '30 days',
        ReportPeriod.days90 => '90 days',
        ReportPeriod.custom => 'Custom',
      };

  String _periodSubtitle(List<CheckInEntry> entries, ReportPeriod p) {
    final filtered = _entriesForPeriod(entries, p);
    if (filtered.isEmpty) return 'No entries found';
    final start = filtered.last.date;
    final end = filtered.first.date;
    final fmt = DateFormat('MMM d');
    return '${fmt.format(start)} – ${fmt.format(end)}, 2026 · ${filtered.length} entries';
  }

  List<CheckInEntry> _entriesForPeriod(
      List<CheckInEntry> entries, ReportPeriod p) {
    final days = switch (p) {
      ReportPeriod.week7 => 7,
      ReportPeriod.days30 => 30,
      ReportPeriod.days90 => 90,
      ReportPeriod.custom => 90,
    };
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return entries.where((e) => e.date.isAfter(cutoff)).toList();
  }
}

class _ToggleRow extends StatelessWidget {
  final String emoji;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool last;

  const _ToggleRow({
    required this.emoji,
    required this.label,
    required this.value,
    required this.onChanged,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label, style: KoruTextStyles.body),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeTrackColor: KoruColors.mid,
              ),
            ],
          ),
        ),
        if (!last)
          const Divider(height: 1, indent: 16, color: KoruColors.border),
      ],
    );
  }
}

class _SelectTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? KoruColors.dark : KoruColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? KoruColors.dark : KoruColors.border,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : KoruColors.dark,
          ),
        ),
      ),
    );
  }
}
