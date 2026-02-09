# 카카오맵 Flutter SDK(kakao_map_sdk) 연동

프로젝트는 **kakao_map_sdk**로 카카오맵을 연동합니다. (Flutter 3.33 / Dart 3.5+ 환경)

## 제약 사항

- **kakao_map_sdk**는 **Dart SDK 3.5 이상**이 필요합니다.
- Flutter 3.33.x 이상(또는 Dart 3.5+ 포함 버전)에서 사용 가능합니다.

## 전환 절차 (Dart 3.5+ 환경에서)

### 1. pubspec.yaml

- `environment.sdk`를 `">=3.5.0 <4.0.0"`으로 변경
- `webview_flutter` 제거, `kakao_map_sdk: ^1.2.3` 추가

```yaml
environment:
  sdk: ">=3.5.0 <4.0.0"

dependencies:
  # webview_flutter 제거
  kakao_map_sdk: ^1.2.3
```

### 2. main.dart

- `runApp` 전에 카카오맵 SDK 초기화 추가

```dart
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

void main() async {
  setup();
  WidgetsFlutterBinding.ensureInitialized();
  await KakaoMapSdk.instance.initialize('66e0071736a9e3ccef3fa87fc5abacba');
  // ... 나머지
  runApp(MyApp());
}
```

### 3. lib/ui/widgets/kakao_map_widget.dart

- WebView 대신 `KakaoMap` 위젯 사용
- `KakaoMapOption(position: LatLng(lat, lng), zoomLevel: 14)`
- `onMapReady`: `controller.labelLayer.addPoi(...)` 로 마커 1개 추가 (PoiStyle에 `KImage.fromAsset('assets/icon/app_icon.png', 48, 48)` 사용)
- 편집 모드: `onTerrainClick`에서 클릭 좌표(`LatLng`)로 마커 갱신 후 `onLocationSelected?.call(lat, lng)` 호출
- 웹은 SDK 웹 지원이 실험적이므로 기존처럼 좌표·링크 폴백 UI 유지

### 4. 웹 (선택)

- `web/index.html`에 카카오맵 스크립트 추가 (JavaScript 키 사용)

```html
<script type="text/javascript" src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=YOUR_JAVASCRIPT_APPKEY"></script>
```

### 5. Android

- `AndroidManifest.xml`: `INTERNET` 권한 있음. 필요 시 `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` 추가
- 패키지 readme/ProGuard 가이드에 따라 난독화 규칙 추가

### 6. iOS

- 패키지 문서에 따른 Info.plist 및 네이티브 설정 확인

---

정리하면, **지금은 Dart 3.4 환경이라 kakao_map_sdk를 쓰지 않고 WebView 방식으로 유지**했고,  
**Dart 3.5+로 올린 뒤** 위 단계대로 적용하면 카카오맵 Flutter SDK로 연동할 수 있습니다.
