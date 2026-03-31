import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/strings.dart';
import '../core/theme/colors.dart';
import '../core/theme/text_styles.dart';
import '../providers/app_provider.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen>
    with TickerProviderStateMixin {
  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;
  late AnimationController _waveController;

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
    _recordTimer?.cancel();
    _waveController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    if (_isRecording) {
      setState(() => _isRecording = false);
      _recordTimer?.cancel();
      _waveController.stop();
    } else {
      setState(() {
        _isRecording = true;
        _recordSeconds = 0;
      });
      _waveController.repeat();
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() => _recordSeconds++);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final s = ref.watch(stringsProvider);
    final dateStr = DateFormat('EEEE, MMMM d').format(DateTime.now()).toUpperCase();

    return Scaffold(
      backgroundColor: KoruColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _Header(streak: state.streak, s: s),
                const SizedBox(height: 32),
                Text(
                  s.isSpanish ? '¿Cómo estás hoy?' : 'How are you today?',
                  style: KoruTextStyles.display.copyWith(fontStyle: FontStyle.normal),
                ),
                const SizedBox(height: 8),
                Text(
                  dateStr,
                  style: KoruTextStyles.label.copyWith(letterSpacing: 1.5),
                ),
                const SizedBox(height: 48),
                _BigMicButton(
                  isRecording: _isRecording,
                  seconds: _recordSeconds,
                  waveController: _waveController,
                  onTap: _toggleRecording,
                  s: s,
                ),
                const SizedBox(height: 48),
                const _WeeklyStreak(),
                const SizedBox(height: 32),
                const Row(
                  children: [
                    Expanded(child: _StatusCard(label: 'SLEEP', value: '7h 20m', color: KoruColors.mid)),
                    SizedBox(width: 12),
                    Expanded(child: _StatusCard(label: 'WATER', value: '1.2L', color: KoruColors.mid)),
                    SizedBox(width: 12),
                    Expanded(child: _StatusCard(label: 'EXERCISE', value: '---', color: KoruColors.danger, isAlert: true)),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
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
        Text('Check-In', style: KoruTextStyles.bodyMuted),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: KoruColors.chip.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: KoruColors.mid, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                s.dayStreak(streak),
                style: KoruTextStyles.label.copyWith(color: KoruColors.dark),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BigMicButton extends StatelessWidget {
  final bool isRecording;
  final int seconds;
  final AnimationController waveController;
  final VoidCallback onTap;
  final S s;

  const _BigMicButton({
    required this.isRecording,
    required this.seconds,
    required this.waveController,
    required this.onTap,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isRecording) ...[
                _Ripple(delay: 0, controller: waveController),
                _Ripple(delay: 0.3, controller: waveController),
                _Ripple(delay: 0.6, controller: waveController),
              ],
              Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: KoruColors.mid,
                ),
                child: Center(
                  child: isRecording
                      ? _WaveformWidget(controller: waveController)
                      : CustomPaint(
                          size: const Size(80, 80),
                          painter: _KoruLogoPainter(),
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (isRecording)
          Column(
            children: [
              Text(
                s.isSpanish ? 'Escuchando...' : 'Listening...',
                style: KoruTextStyles.title.copyWith(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: KoruColors.danger, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(
                    '0:${seconds.toString().padLeft(2, '0')}',
                    style: KoruTextStyles.title.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              IconButton.filled(
                onPressed: onTap,
                icon: const Icon(Icons.pause, size: 28),
                style: IconButton.styleFrom(
                  backgroundColor: KoruColors.mid,
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                s.isSpanish ? 'TEMAS A SEGUIR' : 'TOPICS TO FOLLOW',
                style: KoruTextStyles.label,
              ),
              const SizedBox(height: 12),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _TopicChip(label: 'Sueño', completed: true),
                  _TopicChip(label: 'Sueño', completed: true),
                  _TopicChip(label: 'Sueño', completed: false),
                  _TopicChip(label: 'Sueño', completed: false),
                  _TopicChip(label: 'Sueño', completed: true),
                  _TopicChip(label: 'Sueño', completed: false),
                  _TopicChip(label: 'Sueño', completed: false),
                  _TopicChip(label: 'Sueño', completed: false),
                ],
              ),
            ],
          )
        else
          Text(
            s.isSpanish ? 'Toca para hablar' : 'Push to talk',
            style: KoruTextStyles.title.copyWith(fontStyle: FontStyle.italic),
          ),
      ],
    );
  }
}

class _Ripple extends StatelessWidget {
  final double delay;
  final AnimationController controller;
  const _Ripple({required this.delay, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double val = (controller.value + delay) % 1.0;
        return Container(
          width: 180 + (val * 100),
          height: 180 + (val * 100),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: KoruColors.mid.withValues(alpha: 1.0 - val),
              width: 1,
            ),
          ),
        );
      },
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
          children: List.generate(15, (i) {
            final phase = (controller.value * 2 * pi) + (i * 0.4);
            final height = 10.0 + 30.0 * ((sin(phase) + 1) / 2);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 3,
              height: height,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(2)),
            );
          }),
        );
      },
    );
  }
}

class _KoruLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();
    // Simplified spiral/koru shape
    path.moveTo(size.width * 0.5, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.1, size.height * 0.7, size.width * 0.3, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.05, size.width * 0.8, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.7, size.width * 0.6, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.4, size.height * 0.85, size.width * 0.45, size.height * 0.6);
    
    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset(size.width * 0.53, size.height * 0.55), 2, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WeeklyStreak extends StatelessWidget {
  const _WeeklyStreak();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _DayIndicator(label: 'L', active: true),
        _DayIndicator(label: 'M', active: true),
        _DayIndicator(label: 'M', active: true, isCurrent: true),
        _DayIndicator(label: 'J', active: false),
        _DayIndicator(label: 'V', active: false),
      ],
    );
  }
}

class _DayIndicator extends StatelessWidget {
  final String label;
  final bool active;
  final bool isCurrent;

  const _DayIndicator({required this.label, required this.active, this.isCurrent = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            width: 32,
            height: isCurrent ? 32 : 6,
            decoration: BoxDecoration(
              color: isCurrent ? Colors.transparent : (active ? KoruColors.mid : KoruColors.border),
              borderRadius: BorderRadius.circular(10),
              border: isCurrent ? Border.all(color: KoruColors.mid, width: 4) : null,
            ),
            child: isCurrent ? Center(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: KoruColors.dark))) : null,
          ),
          if (!isCurrent) ...[
            const SizedBox(height: 8),
            Text(label, style: KoruTextStyles.label.copyWith(color: active ? KoruColors.dark : KoruColors.muted)),
          ],
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isAlert;

  const _StatusCard({required this.label, required this.value, required this.color, this.isAlert = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KoruColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Georgia', fontSize: 10, color: KoruColors.muted)),
          const SizedBox(height: 4),
          Text(value, style: KoruTextStyles.title.copyWith(fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  final String label;
  final bool completed;

  const _TopicChip({required this.label, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: completed ? KoruColors.mid.withValues(alpha: 0.2) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: KoruColors.border, width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: KoruColors.dark,
          decoration: completed ? TextDecoration.lineThrough : null,
        ),
      ),
    );
  }
}
