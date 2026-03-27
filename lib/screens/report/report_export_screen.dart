import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/koru_button.dart';

class ReportExportScreen extends StatefulWidget {
  const ReportExportScreen({super.key});

  @override
  State<ReportExportScreen> createState() => _ReportExportScreenState();
}

class _ReportExportScreenState extends State<ReportExportScreen> {
  bool _exporting = false;
  bool _done = false;

  Future<void> _export() async {
    setState(() => _exporting = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _exporting = false;
      _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Report'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _done ? _DoneView(onDone: () => context.go('/check-in')) : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose format',
                style: KoruTextStyles.headline,
              ),
              const SizedBox(height: 8),
              const Text(
                'Share your health report with your doctor',
                style: KoruTextStyles.bodyMuted,
              ),
              const SizedBox(height: 32),
              _FormatCard(
                emoji: '📄',
                title: 'PDF Document',
                description: 'Standard format, printable',
                onTap: _export,
              ),
              const SizedBox(height: 12),
              _FormatCard(
                emoji: '📊',
                title: 'CSV Spreadsheet',
                description: 'Raw data for analysis',
                onTap: _export,
              ),
              const SizedBox(height: 12),
              _FormatCard(
                emoji: '✉️',
                title: 'Send via email',
                description: 'Email directly to your care team',
                onTap: _export,
              ),
              const Spacer(),
              if (_exporting)
                const Column(
                  children: [
                    LinearProgressIndicator(color: KoruColors.mid),
                    SizedBox(height: 12),
                    Text(
                      'Generating report...',
                      style: KoruTextStyles.bodyMuted,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormatCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _FormatCard({
    required this.emoji,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: KoruColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: KoruColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: KoruTextStyles.title),
                  Text(description, style: KoruTextStyles.bodyMuted),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: KoruColors.muted),
          ],
        ),
      ),
    );
  }
}

class _DoneView extends StatelessWidget {
  final VoidCallback onDone;
  const _DoneView({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('✅', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 20),
        const Text('Report ready!', style: KoruTextStyles.headline),
        const SizedBox(height: 8),
        const Text(
          'Your health report has been generated.\nShare it with your doctor.',
          style: KoruTextStyles.bodyMuted,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        KoruButton(
          label: 'Back to Check-In',
          onPressed: onDone,
        ),
      ],
    );
  }
}
