/// 앱 전역 색상·타이포. Vue와 유사한 모던 톤.
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // 배경·표면
  static const Color notWhite = Color(0xFFF8FAFC);
  static const Color nearlyWhite = Color(0xFFF8FAFC);
  static const Color white = Color(0xFFFFFFFF);
  static const Color nearlyBlack = Color(0xFF0F172A);
  static const Color grey = Color(0xFF64748B);
  static const Color dark_grey = Color(0xFF334155);

  // 텍스트
  static const Color darkText = Color(0xFF334155);
  static const Color darkerText = Color(0xFF1E293B);
  static const Color lightText = Color(0xFF64748B);
  static const Color deactivatedText = Color(0xFF94A3B8);
  static const Color dismissibleBackground = Color(0xFF475569);
  static const Color chipBackground = Color(0xFFF1F5F9);
  static const Color spacer = Color(0xFFE2E8F0);
  static const String fontName = 'WorkSans';

  // 모던 액센트
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);

  static const TextTheme textTheme = TextTheme(
    headline4: display1,
    headline5: headline,
    headline6: title,
    subtitle2: subtitle,
    bodyText2: body2,
    bodyText1: body1,
    caption: caption,
  );

  static const TextStyle display1 = TextStyle(
    // h4 -> display1
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 36,
    letterSpacing: 0.4,
    height: 0.9,
    color: darkerText,
  );

  static const TextStyle headline = TextStyle(
    // h5 -> headline
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.27,
    color: darkerText,
  );

  static const TextStyle title = TextStyle(
    // h6 -> title
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 0.18,
    color: darkerText,
  );

  static const TextStyle subtitle = TextStyle(
    // subtitle2 -> subtitle
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: -0.04,
    color: darkText,
  );

  static const TextStyle body2 = TextStyle(
    // body1 -> body2
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.2,
    color: darkText,
  );

  static const TextStyle body1 = TextStyle(
    // body2 -> body1
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: -0.05,
    color: darkText,
  );

  static const TextStyle caption = TextStyle(
    // Caption -> caption
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.2,
    color: lightText, // was lightText
  );
}
