import 'package:flutter/material.dart';
import 'colors.dart';

class KoruTextStyles {
  KoruTextStyles._();

  static const TextStyle display = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,
    color: KoruColors.dark,
    height: 1.2,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: KoruColors.dark,
    height: 1.3,
  );

  static const TextStyle title = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: KoruColors.dark,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: KoruColors.dark,
    height: 1.5,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: KoruColors.muted,
    height: 1.5,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: KoruColors.muted,
    letterSpacing: 1.0,
  );

  static const TextStyle chipLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: KoruColors.chipText,
  );
}
