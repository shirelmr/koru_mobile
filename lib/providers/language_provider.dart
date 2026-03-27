import 'package:flutter_riverpod/flutter_riverpod.dart';

/// '' = not yet chosen, 'en' = English, 'es' = Spanish
final languageProvider = StateProvider<String>((ref) => '');
