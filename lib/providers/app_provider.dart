import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_models.dart';

// Shared across onboarding screens
final selectedProfileProvider = StateProvider<UserProfile?>((ref) => null);

class AppState {
  final bool hasCompletedOnboarding;
  final UserProfile profile;
  final List<CheckInEntry> entries;
  final int streak;
  final CheckInDraft draft;
  final ExtractedData? pendingExtraction;

  const AppState({
    this.hasCompletedOnboarding = false,
    this.profile = UserProfile.generalHealth,
    this.entries = const [],
    this.streak = 7,
    this.draft = const CheckInDraft(),
    this.pendingExtraction,
  });

  AppState copyWith({
    bool? hasCompletedOnboarding,
    UserProfile? profile,
    List<CheckInEntry>? entries,
    int? streak,
    CheckInDraft? draft,
    ExtractedData? pendingExtraction,
    bool clearExtraction = false,
  }) {
    return AppState(
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      profile: profile ?? this.profile,
      entries: entries ?? this.entries,
      streak: streak ?? this.streak,
      draft: draft ?? this.draft,
      pendingExtraction:
          clearExtraction ? null : (pendingExtraction ?? this.pendingExtraction),
    );
  }
}

class AppNotifier extends StateNotifier<AppState> {
  AppNotifier() : super(AppState(entries: _mockEntries));

  void completeOnboarding(UserProfile profile) {
    state = state.copyWith(
      hasCompletedOnboarding: true,
      profile: profile,
    );
  }

  void updateDraft(CheckInDraft draft) {
    state = state.copyWith(draft: draft);
  }

  void resetDraft() {
    state = state.copyWith(draft: const CheckInDraft());
  }

  ExtractedData extractFromDraft() {
    final text = state.draft.text.toLowerCase();
    final extraction = ExtractedData(
      symptoms: _extractSymptoms(text),
      sleep: _extractSleep(text, state.draft.sleepQuality),
      intake: _extractIntake(text),
      stress: _extractStress(text, state.draft.stressLevel),
      exercise: _extractExercise(text),
      mood: _extractMood(text, state.draft.mood),
      glucose: state.draft.glucose != null
          ? '${state.draft.glucose!.toStringAsFixed(0)} mg/dL'
          : null,
      insulin: state.draft.insulinTaken ? 'Taken' : null,
      carbs: state.draft.carbIntake?.name.capitalize(),
      lastMeal: state.draft.lastMeal?.name.capitalize(),
    );
    state = state.copyWith(pendingExtraction: extraction);
    return extraction;
  }

  void confirmEntry() {
    if (state.pendingExtraction == null) return;
    final ex = state.pendingExtraction!;
    final entry = CheckInEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      text: state.draft.text,
      sleepQuality: state.draft.sleepQuality,
      stressLevel: state.draft.stressLevel,
      tension: state.draft.tension,
      mood: state.draft.mood,
      focus: state.draft.focus,
      symptoms: ex.symptoms,
      intake: ex.intake,
      exercise: ex.exercise,
      glucose: state.draft.glucose,
      insulinTaken: state.draft.insulinTaken,
      carbIntake: state.draft.carbIntake,
      lastMeal: state.draft.lastMeal,
    );
    state = state.copyWith(
      entries: [entry, ...state.entries],
      clearExtraction: true,
    );
    resetDraft();
  }

  List<String> _extractSymptoms(String text) {
    final symptoms = <String>[];
    if (text.contains('headache')) symptoms.add('Headache');
    if (text.contains('migraine')) symptoms.add('Migraine');
    if (text.contains('tired') || text.contains('fatigue')) {
      symptoms.add('Fatigue');
    }
    if (text.contains('nausea')) symptoms.add('Nausea');
    if (text.contains('stomach')) symptoms.add('Stomach ache');
    if (text.contains('dizz')) symptoms.add('Dizziness');
    if (text.contains('pain')) symptoms.add('Pain');
    if (symptoms.isEmpty && text.isNotEmpty) symptoms.add('General discomfort');
    return symptoms;
  }

  List<String> _extractSleep(String text, int? quality) {
    final sleep = <String>[];
    final hourMatch = RegExp(r'(\d+)\s*h').firstMatch(text);
    if (hourMatch != null) sleep.add('${hourMatch.group(1)}h sleep');
    if (quality != null) {
      const labels = ['', 'Poor', 'Below avg', 'Average', 'Good', 'Excellent'];
      sleep.add('Quality: ${labels[quality]}');
    }
    return sleep;
  }

  List<String> _extractIntake(String text) {
    final intake = <String>[];
    if (text.contains('coffee')) {
      final match = RegExp(r'(\d+)\s*coffee').firstMatch(text);
      intake.add(match != null ? 'Coffee ×${match.group(1)}' : 'Coffee');
    }
    if (text.contains('alcohol') || text.contains('beer') || text.contains('wine')) {
      intake.add('Alcohol');
    }
    if (text.contains('water')) intake.add('Water');
    if (text.contains('sugar')) intake.add('Sugar');
    if (text.contains('skip') && text.contains('meal')) intake.add('Skipped meal');
    return intake;
  }

  List<String> _extractStress(String text, int? level) {
    final stress = <String>[];
    if (text.contains('stress') || text.contains('anxious') || text.contains('worried')) {
      stress.add('Work stress');
    }
    if (level != null && level >= 4) stress.add('High stress day');
    return stress;
  }

  List<String> _extractExercise(String text) {
    final ex = <String>[];
    if (text.contains('run') || text.contains('jogging')) ex.add('Running');
    if (text.contains('yoga')) ex.add('Yoga');
    if (text.contains('gym') || text.contains('workout')) ex.add('Gym');
    if (text.contains('walk')) ex.add('Walking');
    if (text.contains('swim')) ex.add('Swimming');
    return ex;
  }

  List<String> _extractMood(String text, int? mood) {
    final result = <String>[];
    if (text.contains('happy') || text.contains('great')) result.add('Happy');
    if (text.contains('sad') || text.contains('down')) result.add('Low mood');
    if (text.contains('anxious')) result.add('Anxious');
    if (mood != null) {
      const labels = ['', 'Very bad', 'Bad', 'Neutral', 'Good', 'Great'];
      result.add(labels[mood]);
    }
    return result;
  }

  static final List<CheckInEntry> _mockEntries = [
    CheckInEntry(
      id: '1',
      date: DateTime(2026, 3, 27),
      text: 'Felt tired all day, had a headache in the afternoon, drank 3 coffees to keep going.',
      sleepQuality: 2,
      stressLevel: 4,
      mood: 2,
      focus: 2,
      symptoms: ['Headache', 'Fatigue'],
      intake: ['Coffee ×3'],
      glucose: 145,
      insulinTaken: true,
      carbIntake: CarbIntake.high,
      lastMeal: MealType.dinner,
    ),
    CheckInEntry(
      id: '2',
      date: DateTime(2026, 3, 26),
      text: 'Great day! Went for a morning run, slept 8h, feeling energized.',
      sleepQuality: 5,
      stressLevel: 1,
      mood: 5,
      focus: 5,
      symptoms: [],
      intake: ['Water'],
      exercise: ['Running'],
      glucose: 98,
      insulinTaken: false,
      carbIntake: CarbIntake.low,
      lastMeal: MealType.lunch,
    ),
    CheckInEntry(
      id: '3',
      date: DateTime(2026, 3, 25),
      text: 'Stressful work day, skipped lunch, coffee after coffee.',
      sleepQuality: 3,
      stressLevel: 5,
      mood: 2,
      focus: 3,
      symptoms: ['Fatigue'],
      intake: ['Coffee ×4', 'Skipped meal'],
      glucose: 120,
      insulinTaken: true,
      carbIntake: CarbIntake.low,
      lastMeal: MealType.breakfast,
    ),
    CheckInEntry(
      id: '4',
      date: DateTime(2026, 3, 24),
      text: 'Yoga session in the morning. Felt calm, slept 7h.',
      sleepQuality: 4,
      stressLevel: 2,
      mood: 4,
      focus: 4,
      symptoms: [],
      intake: ['Water'],
      exercise: ['Yoga'],
      glucose: 95,
      insulinTaken: false,
      carbIntake: CarbIntake.medium,
      lastMeal: MealType.dinner,
    ),
    CheckInEntry(
      id: '5',
      date: DateTime(2026, 3, 23),
      text: 'Headache again after too much coffee. Slept poorly last night.',
      sleepQuality: 2,
      stressLevel: 4,
      mood: 2,
      focus: 2,
      symptoms: ['Headache'],
      intake: ['Coffee ×3'],
      glucose: 138,
      insulinTaken: true,
      carbIntake: CarbIntake.high,
      lastMeal: MealType.dinner,
    ),
    CheckInEntry(
      id: '6',
      date: DateTime(2026, 3, 22),
      text: 'Relaxed weekend day. Slept 9h, went for a walk, had a good lunch.',
      sleepQuality: 5,
      stressLevel: 1,
      mood: 5,
      focus: 4,
      symptoms: [],
      intake: ['Water'],
      exercise: ['Walking'],
      glucose: 88,
      insulinTaken: false,
      carbIntake: CarbIntake.medium,
      lastMeal: MealType.lunch,
    ),
    CheckInEntry(
      id: '7',
      date: DateTime(2026, 3, 21),
      text: 'Normal day, felt okay. Nothing special to report.',
      sleepQuality: 3,
      stressLevel: 3,
      mood: 3,
      focus: 3,
      symptoms: [],
      intake: ['Coffee ×1'],
      glucose: 105,
      insulinTaken: false,
      carbIntake: CarbIntake.medium,
      lastMeal: MealType.dinner,
    ),
    CheckInEntry(
      id: '8',
      date: DateTime(2026, 3, 20),
      text: 'Stomach ache and nausea. Skipped dinner, rested early.',
      sleepQuality: 3,
      stressLevel: 2,
      mood: 2,
      focus: 2,
      symptoms: ['Stomach ache', 'Nausea'],
      intake: ['Skipped meal'],
      glucose: 112,
      insulinTaken: true,
      carbIntake: CarbIntake.low,
      lastMeal: MealType.lunch,
    ),
  ];
}

extension StringX on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

final appProvider = StateNotifierProvider<AppNotifier, AppState>(
  (ref) => AppNotifier(),
);
