/// GoTogether Flutter 앱 진입점
///
/// 백엔드(gotogether-backend) API와 연동하는 모바일/웹 클라이언트.
/// Android·iOS·Web 지원. 웹 빌드 시 에뮬레이터 없이 브라우저에서 확인 가능.
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/ui/app_theme.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

import 'ui/navigation_main_screen.dart';

void main() async {
  setup();
  WidgetsFlutterBinding.ensureInitialized();

  await KakaoMapSdk.instance.initialize('66e0071736a9e3ccef3fa87fc5abacba');

  // 웹이 아닐 때만 화면 방향 고정 (웹에서는 setPreferredOrientations 미지원)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  runApp(MyApp());
}

/// 루트 위젯. 테마·시스템 UI·홈 화면 설정.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ));
    }
    return MaterialApp(
      title: 'GoTogether',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // 색상 체계: primary·surface·container
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primary,
          brightness: Brightness.light,
          primary: AppTheme.primary,
          primaryContainer: AppTheme.chipBackground,
          surface: AppTheme.surface,
          surfaceContainerHighest: AppTheme.white,
        ),
        scaffoldBackgroundColor: AppTheme.surface,
        // 앱바·카드·리스트타일·입력·버튼·칩
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 2,
          backgroundColor: Colors.transparent,
          foregroundColor: AppTheme.darkerText,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            fontFamily: AppTheme.fontName,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: AppTheme.darkerText,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: AppTheme.primary.withOpacity(0.08),
          color: AppTheme.cardSurface,
          surfaceTintColor: AppTheme.primary.withOpacity(0.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          margin: const EdgeInsets.symmetric(horizontal: AppTheme.paddingScreen, vertical: 6),
          clipBehavior: Clip.antiAlias,
        ),
        listTileTheme: ListTileThemeData(
          contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingCard, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
          minLeadingWidth: 40,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppTheme.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            borderSide: const BorderSide(color: AppTheme.border, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            borderSide: const BorderSide(color: AppTheme.primary, width: 2),
          ),
          hintStyle: const TextStyle(color: AppTheme.deactivatedText),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            elevation: 2,
            shadowColor: AppTheme.primary.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            ),
            textStyle: const TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              letterSpacing: 0.4,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.white,
            foregroundColor: AppTheme.primary,
            elevation: 2,
            shadowColor: AppTheme.primary.withOpacity(0.2),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              side: const BorderSide(color: AppTheme.border, width: 1.2),
            ),
            textStyle: const TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppTheme.chipBackground,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
          labelStyle: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.darkText),
        ),
        dividerColor: AppTheme.border,
        textTheme: AppTheme.textTheme,
        platform: TargetPlatform.iOS,
      ),
      home: NavigationHomeScreen(),
    );
  }
}

/// HEX 색상 문자열을 [Color]로 변환. 홈·통계·공지 등에서 사용.
class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }
}
