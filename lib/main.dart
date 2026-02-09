/// GoTogether Flutter 앱 진입점
///
/// 백엔드(gotogether-backend) API와 연동하는 모바일/웹 클라이언트.
/// Android·iOS·Web 지원. 웹 빌드 시 에뮬레이터 없이 브라우저에서 확인 가능.
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/ui/app_theme.dart';

import 'ui/navigation_main_screen.dart';

void main() async {
  setup();
  WidgetsFlutterBinding.ensureInitialized();

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
        primarySwatch: Colors.blue,
        textTheme: AppTheme.textTheme,
        platform: TargetPlatform.iOS,
      ),
      home: NavigationHomeScreen(),
    );
  }
}

/// HEX 문자열을 [Color]로 변환하는 유틸리티 (예: #54D3C2).
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
