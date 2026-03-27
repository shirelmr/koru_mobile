import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../core/theme/colors.dart';
import '../core/theme/text_styles.dart';
import '../core/widgets/koru_button.dart';
import '../core/widgets/dot_selector.dart';
import '../models/app_models.dart';
import '../providers/app_provider.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen>
    with TickerProviderStateMixin {
  final _textController = TextEditingController();
  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;
  late AnimationController _pulseController;
  bool _isAnalyzing = false;

  // Simulated stat values — replace with real data from provider
  final double _sleepHours = 7.33; // 7h 20m
  final double _waterLiters = 1.2;
  final bool _exerciseDone = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _recordTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    if (_isRecording) {
      setState(() => _isRecording = false);
      _recordTimer?.cancel();
      _pulseController.stop();
      _textController.text =
          'Woke up with a headache, slept 5 hours, had two coffees this morning.';
      ref.read(appProvider.notifier).updateDraft(
            ref.read(appProvider).draft.copyWith(text: _textController.text),
          );
    } else {
      setState(() {
        _isRecording = true;
        _recordSeconds = 0;
      });
      _pulseController.repeat();
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() => _recordSeconds++);
        if (_recordSeconds >= 120) _toggleRecording();
      });
    }
  }

  Future<void> _analyze() async {
    if (_textController.text.trim().isEmpty) return;
    ref.read(appProvider.notifier).updateDraft(
          ref.read(appProvider).draft.copyWith(text: _textController.text),
        );
    setState(() => _isAnalyzing = true);
    await Future.delayed(const Duration(milliseconds: 2200));
    ref.read(appProvider.notifier).extractFromDraft();
    if (mounted) {
      setState(() => _isAnalyzing = false);
      context.go('/check-in/extraction');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final draft = state.draft;
    final isdia = state.profile == UserProfile.diabetes;
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: KoruColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),

                  // ── Header ──────────────────────────────────────
                  _TopBar(streak: state.streak),
                  const SizedBox(height: 28),

                  // ── Title + Date ─────────────────────────────────
                  Text(
                    'How are you today?',
                    textAlign: TextAlign.center,
                    style: KoruTextStyles.display,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('EEEE, MMMM d').format(today).toUpperCase(),
                    textAlign: TextAlign.center,
                    style: KoruTextStyles.label.copyWith(letterSpacing: 2),
                  ),
                  const SizedBox(height: 32),

                  // ── Push to Talk Button ──────────────────────────
                  _PushToTalkButton(
                    isRecording: _isRecording,
                    seconds: _recordSeconds,
                    pulseController: _pulseController,
                    onTap: _toggleRecording,
                  ),
                  const SizedBox(height: 20),

                  // ── Week Strip ───────────────────────────────────
                  _WeekStrip(today: today),
                  const SizedBox(height: 28),

                  // ── Stat Cards ───────────────────────────────────
                  _StatCardsRow(
                    sleepHours: _sleepHours,
                    waterLiters: _waterLiters,
                    exerciseDone: _exerciseDone,
                  ),
                  const SizedBox(height: 32),

                  // ── Divider before text area ─────────────────────
                  const Divider(color: KoruColors.border, height: 1),
                  const SizedBox(height: 24),

                  // ── Free Text ────────────────────────────────────
                  _SectionLabel('Tell us more'),
                  const SizedBox(height: 10),
                  _FreeTextField(
                    controller: _textController,
                    onMic: _toggleRecording,
                    onChanged: (v) => ref
                        .read(appProvider.notifier)
                        .updateDraft(draft.copyWith(text: v)),
                  ),
                  const SizedBox(height: 24),

                  // ── Optional Sliders ─────────────────────────────
                  _SectionLabel('Optional — Sliders'),
                  const SizedBox(height: 12),
                  _SlidersCard(
                    draft: draft,
                    onChanged: (d) =>
                        ref.read(appProvider.notifier).updateDraft(d),
                  ),

                  // ── Diabetes Fields ──────────────────────────────
                  if (isdia) ...[
                    const SizedBox(height: 24),
                    _SectionLabel('Diabetes Fields'),
                    const SizedBox(height: 12),
                    _DiabetesCard(
                      draft: draft,
                      onChanged: (d) =>
                          ref.read(appProvider.notifier).updateDraft(d),
                    ),
                  ],
                  const SizedBox(height: 32),

                  // ── Analyze CTA ──────────────────────────────────
                  KoruButton(
                    label: 'Analyze',
                    icon: Icons.auto_awesome,
                    loading: _isAnalyzing,
                    onPressed:
                        _textController.text.trim().isEmpty ? null : _analyze,
                  ),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// TOP BAR
// ─────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final int streak;
  const _TopBar({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Logo
        Text('Kōru', style: KoruTextStyles.headline),
        const SizedBox(width: 8),
        Text(
          'Check-In',
          style: KoruTextStyles.body.copyWith(color: KoruColors.muted),
        ),
        const Spacer(),
        // Streak badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: KoruColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: KoruColors.border, width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: KoruColors.mid,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$streak day streak',
                style: TextStyle(
                  fontSize: 12,
                  color: KoruColors.dark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// PUSH TO TALK BUTTON  (big circle with Kōru spiral)
// ─────────────────────────────────────────────────────────────────
class _PushToTalkButton extends StatelessWidget {
  final bool isRecording;
  final int seconds;
  final AnimationController pulseController;
  final VoidCallback onTap;

  const _PushToTalkButton({
    required this.isRecording,
    required this.seconds,
    required this.pulseController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Glow ring + circle
        AnimatedBuilder(
          animation: pulseController,
          builder: (context, child) {
            final glow = isRecording
                ? (0.3 + 0.15 * sin(pulseController.value * 2 * pi))
                : 0.0;
            return Center(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: KoruColors.background,
                  boxShadow: [
                    BoxShadow(
                      color: KoruColors.mid.withValues(alpha: glow),
                      blurRadius: 40,
                      spreadRadius: 12,
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    margin: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRecording ? KoruColors.danger : KoruColors.mid,
                    ),
                    child: CustomPaint(
                      painter: _SpiralPainter(isRecording: isRecording),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // "Push to talk" / "Listening..." label
        if (isRecording)
          Text(
            'Listening... 0:${seconds.toString().padLeft(2, '0')}',
            style: KoruTextStyles.body.copyWith(color: KoruColors.danger),
          )
        else
          Text(
            'Push to talk',
            style: KoruTextStyles.body.copyWith(color: KoruColors.muted),
          ),
      ],
    );
  }
}

// Draws the Kōru spiral logo inside the circle
class _SpiralPainter extends CustomPainter {
  final bool isRecording;
  const _SpiralPainter({required this.isRecording});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Draw a logarithmic spiral (kōru shape)
    bool first = true;
    for (double t = 0; t <= 4.8 * pi; t += 0.05) {
      final r = 2.0 * exp(0.18 * t);
      final x = cx + r * cos(t - pi / 2);
      final y = cy + r * sin(t - pi / 2);
      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    // Small dot at the center of the spiral
    canvas.drawCircle(
      Offset(cx, cy - 2),
      3,
      Paint()..color = Colors.white.withValues(alpha: 0.6),
    );
  }

  @override
  bool shouldRepaint(covariant _SpiralPainter old) =>
      old.isRecording != isRecording;
}

// ─────────────────────────────────────────────────────────────────
// WEEK STRIP  (L  M  [M]  J  V)
// ─────────────────────────────────────────────────────────────────
class _WeekStrip extends StatelessWidget {
  final DateTime today;
  const _WeekStrip({required this.today});

  @override
  Widget build(BuildContext context) {
    // Monday=1 ... Friday=5 in Dart (weekday). Show Mon-Fri.
    final labels = ['L', 'M', 'M', 'J', 'V'];
    // weekday: Mon=1, Tue=2, Wed=3, Thu=4, Fri=5
    // index in labels: Mon=0, Tue=1, Wed=2, Thu=3, Fri=4
    final todayIndex = (today.weekday - 1).clamp(0, 4);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(labels.length * 2 - 1, (i) {
        // Even indices = day item, odd indices = line separator
        if (i.isOdd) {
          final dayIndex = i ~/ 2;
          final nextIndex = dayIndex + 1;
          final lineActive =
              dayIndex < todayIndex || nextIndex <= todayIndex;
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              color: lineActive ? KoruColors.mid : KoruColors.border,
            ),
          );
        }

        final dayIndex = i ~/ 2;
        final isToday = dayIndex == todayIndex;
        final isPast = dayIndex < todayIndex;

        return Column(
          children: [
            if (isToday)
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: KoruColors.mid,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[dayIndex],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              )
            else
              SizedBox(
                width: 36,
                height: 36,
                child: Center(
                  child: Text(
                    labels[dayIndex],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color:
                          isPast ? KoruColors.dark : KoruColors.muted,
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// STAT CARDS  (Sleep · Water · Exercise)
// ─────────────────────────────────────────────────────────────────
class _StatCardsRow extends StatelessWidget {
  final double sleepHours;
  final double waterLiters;
  final bool exerciseDone;

  const _StatCardsRow({
    required this.sleepHours,
    required this.waterLiters,
    required this.exerciseDone,
  });

  String _formatSleep(double h) {
    final hrs = h.floor();
    final mins = ((h - hrs) * 60).round();
    return '${hrs}h ${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'SLEEP',
            value: _formatSleep(sleepHours),
            dotColor: KoruColors.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'WATER',
            value: '${waterLiters}L',
            dotColor: KoruColors.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'EXERCISE',
            value: exerciseDone ? 'Done' : '---',
            dotColor:
                exerciseDone ? KoruColors.success : KoruColors.danger,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color dotColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: KoruColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KoruColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: KoruTextStyles.label.copyWith(letterSpacing: 0.8),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: KoruColors.dark,
              fontFamily: 'Georgia',
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// HELPERS (unchanged from original)
// ─────────────────────────────────────────────────────────────────
class _FreeTextField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onMic;
  final ValueChanged<String> onChanged;

  const _FreeTextField({
    required this.controller,
    required this.onMic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 4,
      maxLines: 8,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText:
            'Write freely or tap the mic...\n\ne.g. "Woke up with a headache, slept 5h, had two coffees"',
        hintStyle: KoruTextStyles.bodyMuted,
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 60),
          child: IconButton(
            icon: const Icon(Icons.mic_none, color: KoruColors.muted),
            onPressed: onMic,
          ),
        ),
        alignLabelWithHint: true,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: KoruTextStyles.label);
  }
}

class _SlidersCard extends StatelessWidget {
  final CheckInDraft draft;
  final ValueChanged<CheckInDraft> onChanged;

  const _SlidersCard({required this.draft, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KoruColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KoruColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          DotSelector(
            label: 'Sleep Quality',
            value: draft.sleepQuality,
            onChanged: (v) => onChanged(draft.copyWith(sleepQuality: v)),
          ),
          const Divider(height: 20, color: KoruColors.border),
          DotSelector(
            label: 'Stress Level',
            value: draft.stressLevel,
            onChanged: (v) => onChanged(draft.copyWith(stressLevel: v)),
          ),
          const Divider(height: 20, color: KoruColors.border),
          DotSelector(
            label: 'Tension',
            value: draft.tension,
            onChanged: (v) => onChanged(draft.copyWith(tension: v)),
          ),
          const Divider(height: 20, color: KoruColors.border),
          DotSelector(
            label: 'Mood',
            value: draft.mood,
            onChanged: (v) => onChanged(draft.copyWith(mood: v)),
          ),
          const Divider(height: 20, color: KoruColors.border),
          DotSelector(
            label: 'Focus',
            value: draft.focus,
            onChanged: (v) => onChanged(draft.copyWith(focus: v)),
          ),
        ],
      ),
    );
  }
}

class _DiabetesCard extends StatelessWidget {
  final CheckInDraft draft;
  final ValueChanged<CheckInDraft> onChanged;

  const _DiabetesCard({required this.draft, required this.onChanged});

  @override
  Widget build(BuildContext context) {
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
              const Text('🩸', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              const Expanded(
                  child: Text('Glucose (mg/dL)', style: KoruTextStyles.body)),
              SizedBox(
                width: 80,
                height: 38,
                child: TextField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: '---',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  onChanged: (v) =>
                      onChanged(draft.copyWith(glucose: double.tryParse(v))),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: KoruColors.border),
          Row(
            children: [
              const Text('💉', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              const Expanded(
                  child: Text('Insulin taken', style: KoruTextStyles.body)),
              Switch(
                value: draft.insulinTaken,
                onChanged: (v) => onChanged(draft.copyWith(insulinTaken: v)),
                activeTrackColor: KoruColors.mid,
              ),
            ],
          ),
          const Divider(height: 20, color: KoruColors.border),
          const Row(
            children: [
              Text('🥗', style: TextStyle(fontSize: 20)),
              SizedBox(width: 10),
              Text('Carb Intake', style: KoruTextStyles.body),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: CarbIntake.values
                .map(
                  (c) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _SelectChip(
                        label:
                            c.name[0].toUpperCase() + c.name.substring(1),
                        selected: draft.carbIntake == c,
                        onTap: () => onChanged(draft.copyWith(carbIntake: c)),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const Divider(height: 20, color: KoruColors.border),
          const Row(
            children: [
              Text('🍽', style: TextStyle(fontSize: 20)),
              SizedBox(width: 10),
              Text('Last Meal', style: KoruTextStyles.body),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MealType.values
                .map(
                  (m) => _SelectChip(
                    label: m.name[0].toUpperCase() + m.name.substring(1),
                    selected: draft.lastMeal == m,
                    onTap: () => onChanged(draft.copyWith(lastMeal: m)),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? KoruColors.dark : KoruColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? KoruColors.dark : KoruColors.border,
            width: 0.5,
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