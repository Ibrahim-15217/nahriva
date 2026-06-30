import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static TextStyle displayLarge = const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    letterSpacing: -1.5,
  );

  static TextStyle displayMedium = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static TextStyle headline1 = const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static TextStyle headline2 = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static TextStyle headline3 = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static TextStyle title = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle subtitle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static TextStyle body = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static TextStyle bodySmall = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static TextStyle label = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle caption = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  static TextStyle button = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static TextStyle overline = const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
  );
}
