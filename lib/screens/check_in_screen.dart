import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/strings.dart';
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
  late AnimationController _waveController;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _recordTimer?.cancel();
    _waveController.dispose();
    super.dispose();
  }

  void _toggleRecording(S s) {
    if (_isRecording) {
      setState(() => _isRecording = false);
      _recordTimer?.cancel();
      _waveController.stop();
      final demo = s.isSpanish
          ? 'Me desperté con dolor de cabeza, dormí 5 horas, tomé dos cafés esta mañana.'
          : 'Woke up with a headache, slept 5 hours, had two coffees this morning.';
      _textController.text = demo;
      ref.read(appProvider.notifier).updateDraft(
            ref.read(appProvider).draft.copyWith(text: _textController.text),
          );
    } else {
      setState(() {
        _isRecording = true;
        _recordSeconds = 0;
      });
      _waveController.repeat();
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() => _recordSeconds++);
        if (_recordSeconds >= 30) _toggleRecording(s);
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
    final s = ref.watch(stringsProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  _Header(streak: state.streak, s: s),
                  const SizedBox(height: 20),
                  _VoiceCard(
                    isRecording: _isRecording,
                    seconds: _recordSeconds,
                    waveController: _waveController,
                    onToggle: () => _toggleRecording(s),
                    s: s,
                  ),
                  const SizedBox(height: 16),
                  _FreeTextField(
                    controller: _textController,
                    onMic: () => _toggleRecording(s),
                    onChanged: (v) => ref
                        .read(appProvider.notifier)
                        .updateDraft(draft.copyWith(text: v)),
                    s: s,
                  ),
                  const SizedBox(height: 24),
                  Text(s.optionalSliders.toUpperCase(), style: KoruTextStyles.label),
                  const SizedBox(height: 12),
                  _SlidersCard(
                    draft: draft,
                    onChanged: (d) => ref.read(appProvider.notifier).updateDraft(d),
                    s: s,
                  ),
                  if (isdia) ...[
                    const SizedBox(height: 24),
                    Text(s.diabetesFields.toUpperCase(), style: KoruTextStyles.label),
                    const SizedBox(height: 12),
                    _DiabetesCard(
                      draft: draft,
                      onChanged: (d) => ref.read(appProvider.notifier).updateDraft(d),
                      s: s,
                    ),
                  ],
                  const SizedBox(height: 32),
                  KoruButton(
                    label: s.analyzeBtn,
                    icon: Icons.auto_awesome,
                    loading: _isAnalyzing,
                    onPressed: _textController.text.trim().isEmpty ? null : _analyze,
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

class _Header extends StatelessWidget {
  final int streak;
  final S s;
  const _Header({required this.streak, required this.s});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(s.appTitle, style: KoruTextStyles.headline),
        const SizedBox(width: 8),
        Text('· ${s.checkIn}', style: KoruTextStyles.body.copyWith(color: KoruColors.muted)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: KoruColors.dark, borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              Container(width: 7, height: 7, decoration: const BoxDecoration(color: KoruColors.sage, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(s.dayStreak(streak), style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

class _VoiceCard extends StatelessWidget {
  final bool isRecording;
  final int seconds;
  final AnimationController waveController;
  final VoidCallback onToggle;
  final S s;

  const _VoiceCard({required this.isRecording, required this.seconds, required this.waveController, required this.onToggle, required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: KoruColors.dark, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: KoruColors.sage, size: 16),
              const SizedBox(width: 6),
              Text(s.voiceCardLabel, style: KoruTextStyles.label.copyWith(color: KoruColors.sage, letterSpacing: 0.8)),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRecording ? KoruColors.danger : KoruColors.sage,
                boxShadow: isRecording ? [BoxShadow(color: KoruColors.danger.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 4)] : null,
              ),
              child: Icon(isRecording ? Icons.stop : Icons.mic, color: Colors.white, size: 30),
            ),
          ),
          const SizedBox(height: 16),
          if (isRecording)
            Column(children: [
              _WaveformWidget(controller: waveController),
              const SizedBox(height: 8),
              Text(s.listeningTimer(seconds), style: const TextStyle(color: Colors.white54, fontSize: 13)),
            ])
          else
            Text(s.tapToRecord, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
        ],
      ),
    );
  }
}

class _WaveformWidget extends StatelessWidget {
  final AnimationController controller;
  const _WaveformWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(20, (i) {
            final phase = (controller.value * 2 * pi) + (i * 0.4);
            final height = 4.0 + 12.0 * ((sin(phase) + 1) / 2);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 3,
              height: height,
              decoration: BoxDecoration(color: KoruColors.sage.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(2)),
            );
          }),
        );
      },
    );
  }
}

class _FreeTextField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onMic;
  final ValueChanged<String> onChanged;
  final S s;

  const _FreeTextField({required this.controller, required this.onMic, required this.onChanged, required this.s});

  @override
  State<_FreeTextField> createState() => _FreeTextFieldState();
}

class _FreeTextFieldState extends State<_FreeTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      minLines: 4,
      maxLines: 8,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: '${widget.s.freeTextHint}\n\n${widget.s.freeTextPlaceholder}',
        hintStyle: KoruTextStyles.bodyMuted,
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 60),
          child: IconButton(icon: const Icon(Icons.mic_none, color: KoruColors.muted), onPressed: widget.onMic),
        ),
        alignLabelWithHint: true,
      ),
    );
  }
}

class _SlidersCard extends StatelessWidget {
  final CheckInDraft draft;
  final ValueChanged<CheckInDraft> onChanged;
  final S s;

  const _SlidersCard({required this.draft, required this.onChanged, required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: KoruColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: KoruColors.border, width: 0.5)),
      child: Column(
        children: [
          DotSelector(label: s.sleepQuality, value: draft.sleepQuality, onChanged: (v) => onChanged(draft.copyWith(sleepQuality: v))),
          const Divider(height: 20, color: KoruColors.border),
          DotSelector(label: s.stressLevel, value: draft.stressLevel, onChanged: (v) => onChanged(draft.copyWith(stressLevel: v))),
          const Divider(height: 20, color: KoruColors.border),
          DotSelector(label: s.tension, value: draft.tension, onChanged: (v) => onChanged(draft.copyWith(tension: v))),
          const Divider(height: 20, color: KoruColors.border),
          DotSelector(label: s.mood, value: draft.mood, onChanged: (v) => onChanged(draft.copyWith(mood: v))),
          const Divider(height: 20, color: KoruColors.border),
          DotSelector(label: s.focus, value: draft.focus, onChanged: (v) => onChanged(draft.copyWith(focus: v))),
        ],
      ),
    );
  }
}

class _DiabetesCard extends StatelessWidget {
  final CheckInDraft draft;
  final ValueChanged<CheckInDraft> onChanged;
  final S s;

  const _DiabetesCard({required this.draft, required this.onChanged, required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: KoruColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: KoruColors.border, width: 0.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🩸', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(child: Text(s.glucoseLabel, style: KoruTextStyles.body)),
              SizedBox(
                width: 80,
                height: 38,
                child: TextField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(hintText: '---', contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                  onChanged: (v) => onChanged(draft.copyWith(glucose: double.tryParse(v))),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: KoruColors.border),
          Row(
            children: [
              const Text('💉', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(child: Text(s.insulinTaken, style: KoruTextStyles.body)),
              Switch(value: draft.insulinTaken, onChanged: (v) => onChanged(draft.copyWith(insulinTaken: v)), activeTrackColor: KoruColors.mid),
            ],
          ),
          const Divider(height: 20, color: KoruColors.border),
          Row(children: [const Text('🥗', style: TextStyle(fontSize: 20)), const SizedBox(width: 10), Text(s.carbIntakeLabel, style: KoruTextStyles.body)]),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: _SelectChip(label: s.carbLow, selected: draft.carbIntake == CarbIntake.low, onTap: () => onChanged(draft.copyWith(carbIntake: CarbIntake.low))))),
              Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: _SelectChip(label: s.carbMedium, selected: draft.carbIntake == CarbIntake.medium, onTap: () => onChanged(draft.copyWith(carbIntake: CarbIntake.medium))))),
              Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: _SelectChip(label: s.carbHigh, selected: draft.carbIntake == CarbIntake.high, onTap: () => onChanged(draft.copyWith(carbIntake: CarbIntake.high))))),
            ],
          ),
          const Divider(height: 20, color: KoruColors.border),
          Row(children: [const Text('🍽', style: TextStyle(fontSize: 20)), const SizedBox(width: 10), Text(s.lastMealLabel, style: KoruTextStyles.body)]),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SelectChip(label: s.mealBreakfast, selected: draft.lastMeal == MealType.breakfast, onTap: () => onChanged(draft.copyWith(lastMeal: MealType.breakfast))),
              _SelectChip(label: s.mealLunch, selected: draft.lastMeal == MealType.lunch, onTap: () => onChanged(draft.copyWith(lastMeal: MealType.lunch))),
              _SelectChip(label: s.mealDinner, selected: draft.lastMeal == MealType.dinner, onTap: () => onChanged(draft.copyWith(lastMeal: MealType.dinner))),
              _SelectChip(label: s.mealSnack, selected: draft.lastMeal == MealType.snack, onTap: () => onChanged(draft.copyWith(lastMeal: MealType.snack))),
            ],
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

  const _SelectChip({required this.label, required this.selected, required this.onTap});

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
          border: Border.all(color: selected ? KoruColors.dark : KoruColors.border, width: 0.5),
        ),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: selected ? Colors.white : KoruColors.dark)),
      ),
    );
  }
}
