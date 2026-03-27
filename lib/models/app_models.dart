enum UserProfile { generalHealth, diabetes, hypertension }

enum MoodCategory { good, neutral, bad }

enum CarbIntake { low, medium, high }

enum MealType { breakfast, lunch, dinner, snack }

class CheckInEntry {
  final String id;
  final DateTime date;
  final String text;
  final int? sleepQuality;
  final int? stressLevel;
  final int? tension;
  final int? mood;
  final int? focus;
  final List<String> symptoms;
  final List<String> intake;
  final List<String> exercise;
  final List<String> extraTags;
  // Diabetes fields
  final double? glucose;
  final bool insulinTaken;
  final CarbIntake? carbIntake;
  final MealType? lastMeal;

  const CheckInEntry({
    required this.id,
    required this.date,
    required this.text,
    this.sleepQuality,
    this.stressLevel,
    this.tension,
    this.mood,
    this.focus,
    this.symptoms = const [],
    this.intake = const [],
    this.exercise = const [],
    this.extraTags = const [],
    this.glucose,
    this.insulinTaken = false,
    this.carbIntake,
    this.lastMeal,
  });

  MoodCategory get moodCategory {
    if (mood == null) return MoodCategory.neutral;
    if (mood! >= 4) return MoodCategory.good;
    if (mood! <= 2) return MoodCategory.bad;
    return MoodCategory.neutral;
  }

  CheckInEntry copyWith({
    String? id,
    DateTime? date,
    String? text,
    int? sleepQuality,
    int? stressLevel,
    int? tension,
    int? mood,
    int? focus,
    List<String>? symptoms,
    List<String>? intake,
    List<String>? exercise,
    List<String>? extraTags,
    double? glucose,
    bool? insulinTaken,
    CarbIntake? carbIntake,
    MealType? lastMeal,
  }) {
    return CheckInEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      text: text ?? this.text,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      stressLevel: stressLevel ?? this.stressLevel,
      tension: tension ?? this.tension,
      mood: mood ?? this.mood,
      focus: focus ?? this.focus,
      symptoms: symptoms ?? this.symptoms,
      intake: intake ?? this.intake,
      exercise: exercise ?? this.exercise,
      extraTags: extraTags ?? this.extraTags,
      glucose: glucose ?? this.glucose,
      insulinTaken: insulinTaken ?? this.insulinTaken,
      carbIntake: carbIntake ?? this.carbIntake,
      lastMeal: lastMeal ?? this.lastMeal,
    );
  }
}

class CheckInDraft {
  final String text;
  final int? sleepQuality;
  final int? stressLevel;
  final int? tension;
  final int? mood;
  final int? focus;
  final double? glucose;
  final bool insulinTaken;
  final CarbIntake? carbIntake;
  final MealType? lastMeal;

  const CheckInDraft({
    this.text = '',
    this.sleepQuality,
    this.stressLevel,
    this.tension,
    this.mood,
    this.focus,
    this.glucose,
    this.insulinTaken = false,
    this.carbIntake,
    this.lastMeal,
  });

  CheckInDraft copyWith({
    String? text,
    int? sleepQuality,
    int? stressLevel,
    int? tension,
    int? mood,
    int? focus,
    double? glucose,
    bool? insulinTaken,
    CarbIntake? carbIntake,
    MealType? lastMeal,
  }) {
    return CheckInDraft(
      text: text ?? this.text,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      stressLevel: stressLevel ?? this.stressLevel,
      tension: tension ?? this.tension,
      mood: mood ?? this.mood,
      focus: focus ?? this.focus,
      glucose: glucose ?? this.glucose,
      insulinTaken: insulinTaken ?? this.insulinTaken,
      carbIntake: carbIntake ?? this.carbIntake,
      lastMeal: lastMeal ?? this.lastMeal,
    );
  }
}

class ExtractedData {
  final List<String> symptoms;
  final List<String> sleep;
  final List<String> intake;
  final List<String> stress;
  final List<String> exercise;
  final List<String> mood;
  final String? glucose;
  final String? insulin;
  final String? carbs;
  final String? lastMeal;

  ExtractedData({
    this.symptoms = const [],
    this.sleep = const [],
    this.intake = const [],
    this.stress = const [],
    this.exercise = const [],
    this.mood = const [],
    this.glucose,
    this.insulin,
    this.carbs,
    this.lastMeal,
  });

  Map<String, List<String>> toChipMap(
    UserProfile profile, {
    String catSymptoms = '😵 Symptoms',
    String catSleep = '😴 Sleep',
    String catIntake = '🍽 Intake',
    String catStress = '😤 Stress',
    String catExercise = '🏃 Exercise',
    String catMood = '😊 Mood',
    String catGlucose = '🩸 Glucose',
    String catInsulin = '💉 Insulin',
    String catCarbs = '🥗 Carbs',
    String catLastMeal = '🍴 Last Meal',
  }) {
    final map = <String, List<String>>{
      catSymptoms: List.from(symptoms),
      catSleep: List.from(sleep),
      catIntake: List.from(intake),
      catStress: List.from(stress),
      catExercise: List.from(exercise),
      catMood: List.from(mood),
    };
    if (profile == UserProfile.diabetes) {
      if (glucose != null) map[catGlucose] = [glucose!];
      if (insulin != null) map[catInsulin] = [insulin!];
      if (carbs != null) map[catCarbs] = [carbs!];
      if (lastMeal != null) map[catLastMeal] = [lastMeal!];
    }
    return map;
  }
}

class CorrelationCard {
  final String conditionA;
  final String conditionB;
  final String badge;
  final int timesOut;
  final int timesTotal;
  final double correlation;

  const CorrelationCard({
    required this.conditionA,
    required this.conditionB,
    required this.badge,
    required this.timesOut,
    required this.timesTotal,
    required this.correlation,
  });
}
