import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/language_provider.dart';

final stringsProvider = Provider<S>((ref) => S(ref.watch(languageProvider)));

/// All UI strings for Kōru. Access via `ref.watch(stringsProvider)`.
class S {
  final String language;
  const S(this.language);
  bool get isSpanish => language == 'es';
  // Keep short alias for internal use
  bool get _es => isSpanish;

  // ── Language Selection ───────────────────────────────────────────────
  String get chooseLanguage => _es ? 'Elige tu idioma' : 'Choose your language';
  String get chooseLanguageSubtitle =>
      _es ? 'Puedes cambiarlo más tarde en ajustes' : 'You can change it later in settings';
  String get langEnglish => 'English';
  String get langSpanish => 'Español';

  // ── Common ───────────────────────────────────────────────────────────
  String get continueBtn => _es ? 'Continuar' : 'Continue';
  String get goBack => _es ? 'Volver' : 'Go back';
  String get save => _es ? 'Guardar' : 'Save';
  String get cancel => _es ? 'Cancelar' : 'Cancel';
  String get add => _es ? 'Añadir' : 'Add';
  String get appTitle => 'Kōru';

  // ── Onboarding — Profile Selection ──────────────────────────────────
  String get onboardingQuestion =>
      _es ? '¿Tienes alguna condición de salud específica?' : 'Do you have a specific health condition to track?';

  String get profileGeneralHealth => _es ? 'Salud General' : 'General Health';
  String get profileGeneralHealthDesc =>
      _es ? 'Sueño, ánimo, estrés, ejercicio y síntomas' : 'Sleep, mood, stress, exercise & symptoms';

  String get profileDiabetes => _es ? 'Diabetes' : 'Diabetes';
  String get profileDiabetesDesc =>
      _es ? 'Glucosa, insulina, carbohidratos + salud general' : 'Glucose, insulin, carbs + general health';

  String get profileHypertension => _es ? 'Hipertensión' : 'Hypertension';
  String get profileHypertensionDesc =>
      _es ? 'Presión arterial, medicación + salud general' : 'Blood pressure, medication + general health';

  // ── Onboarding — Profile Confirmation ───────────────────────────────
  String get confirmTitle =>
      _es ? 'Esto es lo que registrarás cada día:' : "Here's what you'll track daily:";
  String get confirmFootnote =>
      _es ? '+ Diario de texto libre · Diario de voz' : '+ Free-text journaling · Voice diary';
  String get startJournaling => _es ? 'Empezar a registrar' : 'Start Journaling';

  List<String> get trackingItemsGeneral => _es
      ? ['Calidad y horas de sueño', 'Ánimo y concentración', 'Estrés y tensión', 'Ejercicio', 'Síntomas', 'Notas de comida e ingesta']
      : ['Sleep quality & hours', 'Mood & focus', 'Stress & tension', 'Exercise', 'Symptoms', 'Food & intake notes'];

  List<String> get trackingItemsDiabetes => _es
      ? ['Glucosa (mg/dL)', 'Insulina tomada', 'Ingesta de carbohidratos', 'Tipo de comida', 'Calidad y horas de sueño', 'Ánimo y estrés', 'Síntomas y ejercicio']
      : ['Glucose (mg/dL)', 'Insulin taken', 'Carbohydrate intake', 'Meal type', 'Sleep quality & hours', 'Mood & stress level', 'Symptoms & exercise'];

  List<String> get trackingItemsHypertension => _es
      ? ['Lecturas de presión arterial', 'Medicación tomada', 'Ingesta de sal y cafeína', 'Calidad y horas de sueño', 'Ánimo y estrés', 'Síntomas y ejercicio']
      : ['Blood pressure readings', 'Medication taken', 'Salt & caffeine intake', 'Sleep quality & hours', 'Mood & stress level', 'Symptoms & exercise'];

  // ── Check-In ─────────────────────────────────────────────────────────
  String get checkIn => _es ? 'Registro' : 'Check-In';
  String dayStreak(int n) => _es ? '$n días seguidos' : '$n day streak';
  String get voiceCardLabel =>
      _es ? 'Deja que la IA analice tu ánimo' : 'Let AI scan your mood';
  String get tapToRecord => _es ? 'Toca para grabar' : 'Tap to start recording';
  String listeningTimer(int s) =>
      _es ? 'Escuchando... 0:${s.toString().padLeft(2, '0')}' : 'Listening... 0:${s.toString().padLeft(2, '0')}';
  String get freeTextHint =>
      _es ? 'Escribe libremente o toca el micrófono...' : 'Write freely or tap the mic...';
  String get freeTextPlaceholder =>
      _es ? 'Ej. "Me desperté con dolor de cabeza, dormí 5h, tomé dos cafés"'
          : 'e.g. "Woke up with a headache, slept 5h, had two coffees"';
  String get optionalSliders => _es ? 'Opcional — Indicadores' : 'Optional — Sliders';
  String get diabetesFields => _es ? 'Campos de diabetes' : 'Diabetes Fields';
  String get sleepQuality => _es ? 'Calidad del sueño' : 'Sleep Quality';
  String get stressLevel => _es ? 'Nivel de estrés' : 'Stress Level';
  String get tension => _es ? 'Tensión' : 'Tension';
  String get mood => _es ? 'Ánimo' : 'Mood';
  String get focus => _es ? 'Concentración' : 'Focus';
  String get glucoseLabel => _es ? 'Glucosa (mg/dL)' : 'Glucose (mg/dL)';
  String get insulinTaken => _es ? 'Insulina tomada' : 'Insulin taken';
  String get carbIntakeLabel => _es ? 'Ingesta de carbohidratos' : 'Carb Intake';
  String get lastMealLabel => _es ? 'Última comida' : 'Last Meal';
  String get carbLow => _es ? 'Baja' : 'Low';
  String get carbMedium => _es ? 'Media' : 'Medium';
  String get carbHigh => _es ? 'Alta' : 'High';
  String get mealBreakfast => _es ? 'Desayuno' : 'Breakfast';
  String get mealLunch => _es ? 'Almuerzo' : 'Lunch';
  String get mealDinner => _es ? 'Cena' : 'Dinner';
  String get mealSnack => _es ? 'Merienda' : 'Snack';
  String get analyzeBtn => _es ? 'Analizar' : 'Analyze';

  // ── Extraction ───────────────────────────────────────────────────────
  String get analysisComplete => _es ? 'ANÁLISIS COMPLETO' : 'ANALYSIS COMPLETE';
  String get hereIsWhatIFound => _es ? 'Esto es lo que encontré' : "Here's what I found";
  String get confirmAndSave => _es ? 'Confirmar y guardar' : 'Confirm & Save';
  String get editManually => _es ? 'Editar manualmente' : 'Edit manually';
  String get addTagHint => _es ? 'Escribe etiqueta...' : 'Enter tag...';
  String addToCategory(String cat) => _es ? 'Añadir a $cat' : 'Add to $cat';

  // Chip category labels
  String get catSymptoms => _es ? '😵 Síntomas' : '😵 Symptoms';
  String get catSleep => _es ? '😴 Sueño' : '😴 Sleep';
  String get catIntake => _es ? '🍽 Ingesta' : '🍽 Intake';
  String get catStress => _es ? '😤 Estrés' : '😤 Stress';
  String get catExercise => _es ? '🏃 Ejercicio' : '🏃 Exercise';
  String get catMood => _es ? '😊 Ánimo' : '😊 Mood';
  String get catGlucose => _es ? '🩸 Glucosa' : '🩸 Glucose';
  String get catInsulin => _es ? '💉 Insulina' : '💉 Insulin';
  String get catCarbs => _es ? '🥗 Carbohidratos' : '🥗 Carbs';
  String get catLastMeal => _es ? '🍴 Última comida' : '🍴 Last Meal';

  // ── Timeline ─────────────────────────────────────────────────────────
  String get yourTimeline => _es ? 'Tu historial' : 'Your Timeline';
  String get timelineSubtitle =>
      _es ? 'Registra cómo te has sentido' : "Track how you've been feeling";
  String get noEntriesThisMonth =>
      _es ? 'Sin registros este mes' : 'No entries this month';
  String get startFirstCheckIn =>
      _es ? 'Empieza tu primer registro hoy' : 'Start your first check-in today';
  String get yourEntry => _es ? 'Tu entrada' : 'Your Entry';
  String moreChips(int n) => '+$n ${_es ? 'más' : 'more'}';

  // Tile labels
  String get tileSleep => _es ? 'Sueño' : 'Sleep';
  String get tileStress => _es ? 'Estrés' : 'Stress';
  String get tileMood => _es ? 'Ánimo' : 'Mood';
  String get tileFocus => _es ? 'Concentración' : 'Focus';
  String get tileGlucose => _es ? 'Glucosa' : 'Glucose';
  String get tileCarbs => _es ? 'Carbohidratos' : 'Carbs';
  String get tileLastMeal => _es ? 'Última comida' : 'Last Meal';

  // ── Bottom Navigation ─────────────────────────────────────────────────
  String get navCheckIn => _es ? 'Registro' : 'Check-In';
  String get navTimeline => _es ? 'Historial' : 'Timeline';
  String get navPatterns => _es ? 'Patrones' : 'Patterns';

  // ── Patterns ─────────────────────────────────────────────────────────
  String get yourPatterns => _es ? 'Tus patrones' : 'Your Patterns';
  String basedOnEntries(int n) =>
      _es ? 'Basado en $n registros' : 'Based on $n entries';
  String get reportBtn => _es ? '📋 Informe' : '📋 Report';
  String get statTotalEntries => _es ? 'Total registros' : 'Total Entries';
  String get statAvgSleep => _es ? 'Sueño promedio' : 'Avg Sleep';
  String get statExerciseDays => _es ? 'Días ejercicio' : 'Exercise Days';
  String get statGoodDays => _es ? 'Días buenos' : 'Good Days';
  String get moodDistribution => _es ? 'Distribución del ánimo' : 'Mood Distribution';
  String get moodGood => _es ? 'Bueno' : 'Good';
  String get moodNeutral => _es ? 'Neutral' : 'Neutral';
  String get moodBad => _es ? 'Malo' : 'Bad';
  String get glucoseOverTime => _es ? 'Glucosa en el tiempo' : 'Glucose Over Time';
  String get mostFrequentSymptoms =>
      _es ? 'Síntomas más frecuentes' : 'Most Frequent Symptoms';
  String get noSymptomsRecorded =>
      _es ? 'Sin síntomas registrados.' : 'No symptoms recorded.';
  String get correlations => _es ? 'Correlaciones' : 'Correlations';
  String get patternsUnlockAfter7 =>
      _es ? 'Los patrones se desbloquean después de 7 días' : 'Patterns unlock after 7 days';
  String daysToUnlock(int n) =>
      _es ? '$n de 7 días registrados para desbloquear tus patrones'
          : '$n of 7 days logged to unlock your patterns';
  String avgGlucoseLabel(String val) =>
      _es ? 'Promedio $val mg/dL' : 'Avg $val mg/dL';

  // Correlation badges
  String get badgeHigh => _es ? 'ALTO' : 'HIGH';
  String get badgeMedium => _es ? 'MEDIO' : 'MEDIUM';
  String get badgePositive => _es ? 'POSITIVO' : 'POSITIVE';
  String correlationStat(int out, int total, int pct) =>
      _es ? '$out de $total veces · $pct% correlación' : '$out of $total times · $pct% correlation';

  // ── Report — Configure ───────────────────────────────────────────────
  String get generateReport => _es ? 'Generar informe' : 'Generate Report';
  String get reportSubtitle => _es ? 'Para llevar a tu médico' : 'To bring to your doctor';
  String get period => _es ? 'PERÍODO' : 'PERIOD';
  String get period7d => _es ? '7 días' : '7 days';
  String get period30d => _es ? '30 días' : '30 days';
  String get period90d => _es ? '90 días' : '90 days';
  String get periodCustom => _es ? 'Personalizado' : 'Custom';
  String get includeLabel => _es ? 'INCLUIR' : 'INCLUDE';
  String get includeGlucose => _es ? 'Glucosa diaria detallada' : 'Detailed daily glucose';
  String get includeInsulin => _es ? 'Insulina por día' : 'Insulin per day';
  String get includeFoods => _es ? 'Alimentos consumidos (día a día)' : 'Foods consumed (day by day)';
  String get includeSleep => _es ? 'Horas de sueño por noche' : 'Sleep hours per night';
  String get includeSymptoms => _es ? 'Síntomas reportados' : 'Reported symptoms';
  String get includeCorrelations => _es ? 'Correlaciones detectadas' : 'Detected correlations';
  String get includeNotes => _es ? 'Notas del paciente (opcional)' : 'Patient notes (optional)';
  String get detailLevel => _es ? 'NIVEL DE DETALLE' : 'DETAIL LEVEL';
  String get summaryOnly => _es ? 'Solo resumen' : 'Summary only';
  String get dayByDay => _es ? 'Día a día ✓' : 'Day by day ✓';
  String get doctorNoteLabel => _es ? 'NOTA PARA EL MÉDICO (OPCIONAL)' : "DOCTOR'S NOTE (OPTIONAL)";
  String get doctorNoteHint => _es ? 'Añade una nota para tu médico...' : 'Add a note for your doctor...';
  String get viewReport => _es ? 'Ver informe' : 'View Report';
  String get noEntriesFound => _es ? 'No se encontraron registros' : 'No entries found';

  // ── Report — Preview ─────────────────────────────────────────────────
  String get reportPreview => _es ? 'Vista previa del informe' : 'Report Preview';
  String get export => _es ? 'Exportar' : 'Export';
  String get glucoseSummary => _es ? 'Resumen de glucosa' : 'Glucose Summary';
  String get avgGlucose => _es ? 'Glucosa promedio' : 'Avg Glucose';
  String get spikesLabel => _es ? 'Picos >140' : 'Spikes >140';
  String get insulinTakenLabel => _es ? 'Insulina tomada' : 'Insulin taken';
  String get daysLabel => _es ? 'días' : 'days';
  String get foodsIntake => _es ? 'Alimentos e ingesta' : 'Foods & Intake';
  String get detectedCorrelations => _es ? 'Correlaciones detectadas' : 'Detected Correlations';
  String get dayByDaySection => _es ? 'Día a día' : 'Day by Day';
  String moreDays(int n) => _es ? '+ $n días más' : '+ $n more days';
  String daysInRange(int pct) =>
      _es ? '$pct% de días en rango (70–140 mg/dL)' : '$pct% days in range (70–140 mg/dL)';
  String get exportPdf => _es ? 'Exportar PDF' : 'Export PDF';

  // ── Report — Export ───────────────────────────────────────────────────
  String get exportReport => _es ? 'Exportar informe' : 'Export Report';
  String get chooseFormat => _es ? 'Elige el formato' : 'Choose format';
  String get exportSubtitle =>
      _es ? 'Comparte tu informe de salud con tu médico' : 'Share your health report with your doctor';
  String get formatPdf => _es ? 'Documento PDF' : 'PDF Document';
  String get formatPdfDesc => _es ? 'Formato estándar, imprimible' : 'Standard format, printable';
  String get formatCsv => _es ? 'Hoja de cálculo CSV' : 'CSV Spreadsheet';
  String get formatCsvDesc => _es ? 'Datos en bruto para análisis' : 'Raw data for analysis';
  String get formatEmail => _es ? 'Enviar por correo' : 'Send via email';
  String get formatEmailDesc =>
      _es ? 'Envía directamente a tu equipo médico' : 'Email directly to your care team';
  String get generatingReport => _es ? 'Generando informe...' : 'Generating report...';
  String get reportReady => _es ? '¡Informe listo!' : 'Report ready!';
  String get reportReadyDesc =>
      _es ? 'Tu informe de salud ha sido generado.\nCompártelo con tu médico.'
          : 'Your health report has been generated.\nShare it with your doctor.';
  String get backToCheckIn => _es ? 'Volver al registro' : 'Back to Check-In';
}
