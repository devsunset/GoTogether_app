/// 홈 화면 색상·타이포. AppTheme과 통일된 톤.
import 'package:flutter/material.dart';
import 'package:gotogether/ui/app_theme.dart';

class HomeTheme {
  HomeTheme._();
  static const Color nearlyWhite = Color(0xFFFAFAFA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F3FF);
  static const Color nearlyDarkBlue = Color(0xFF4F46E5);
  static const Color nearlyYellow = Color(0xFFF59E0B);
  static const Color nearlyRed = Color(0xFFEF4444);
  static const Color nearlyGreen = Color(0xFF10B981);

  static const Color nearlyBlue = Color(0xFF6366F1);
  static const Color nearlyBlack = Color(0xFF1E1B4B);
  static const Color grey = Color(0xFF64748B);
  static const Color dark_grey = Color(0xFF4338CA);

  static const Color darkText = Color(0xFF3730A3);
  static const Color darkerText = Color(0xFF1E1B4B);
  static const Color lightText = Color(0xFF6B7280);
  static const Color deactivatedText = Color(0xFF9CA3AF);
  static const Color dismissibleBackground = Color(0xFF5B21B6);
  static const Color spacer = Color(0xFFE9E5FF);
  static const String fontName = AppTheme.fontName;

  static const TextTheme textTheme = TextTheme(
    headlineMedium: display1,
    headlineSmall: headline,
    titleLarge: title,
    titleSmall: subtitle,
    bodyMedium: body2,
    bodyLarge: body1,
    bodySmall: caption,
  );

  static const TextStyle display1 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w700,
    fontSize: 32,
    letterSpacing: -0.5,
    height: 1.1,
    color: darkerText,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w600,
    fontSize: 22,
    letterSpacing: 0.2,
    color: darkerText,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    letterSpacing: 0.15,
    color: darkerText,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: -0.04,
    color: darkText,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.2,
    color: darkText,
  );

  static const TextStyle body1 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: -0.05,
    color: darkText,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.2,
    color: lightText, // was lightText
  );
}
