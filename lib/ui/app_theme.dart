/// 앱 전역 색상·타이포·레이아웃 토큰. 따뜻하고 세련된 톤.
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // 배경·표면 (회색 대신 부드러운 라벤더/크림)
  static const Color notWhite = Color(0xFFF5F3FF);
  static const Color nearlyWhite = Color(0xFFFAFAFA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color nearlyBlack = Color(0xFF1E1B4B);
  static const Color grey = Color(0xFF64748B);
  static const Color dark_grey = Color(0xFF4338CA);

  // 텍스트
  static const Color darkText = Color(0xFF3730A3);
  static const Color darkerText = Color(0xFF1E1B4B);
  static const Color lightText = Color(0xFF6B7280);
  static const Color deactivatedText = Color(0xFF9CA3AF);
  static const Color dismissibleBackground = Color(0xFF5B21B6);
  static const Color chipBackground = Color(0xFFEDE9FE);
  static const Color spacer = Color(0xFFE9E5FF);
  static const String fontName = 'WorkSans';

  // 메인 액센트 (인디고·바이올렛)
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color surface = Color(0xFFF5F3FF);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE9E5FF);
  static const Color borderFocus = Color(0xFFA5B4FC);

  // 레이아웃 토큰 (일관된 여백·반경)
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double cardElevation = 1.0;
  static const double cardElevationHover = 2.0;
  static const double paddingScreen = 20.0;
  static const double paddingCard = 16.0;

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
