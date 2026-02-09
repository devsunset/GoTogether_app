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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
          primary: const Color(0xFF6366F1),
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 1.5,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF1E293B),
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            fontFamily: AppTheme.fontName,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: Color(0xFF1E293B),
          ),
        ),
        cardTheme: CardTheme(
          elevation: AppTheme.cardElevation,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
          margin: const EdgeInsets.symmetric(horizontal: AppTheme.paddingScreen, vertical: 6),
          clipBehavior: Clip.antiAlias,
        ),
        listTileTheme: ListTileThemeData(
          contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingCard, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
          minLeadingWidth: 40,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
          ),
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
            elevation: 0,
            textStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.3),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
            elevation: 0,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF6366F1),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFF1F5F9),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
        ),
        dividerColor: const Color(0xFFE2E8F0),
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
