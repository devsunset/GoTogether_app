# GoTogether_app

GoTogether 모바일/웹 클라이언트 (Flutter).  
백엔드 [gotogether-backend](https://github.com/devsunset/gotogether-backend) API와 연동하며, Vue 프론트와 동일한 기능을 제공합니다.

## 요구사항

- Flutter SDK (stable, 3.33.x 이상 권장)
- Dart 3.5+ (카카오맵 Flutter SDK 연동용)

## Cursor / VS Code에서 Git 인식

**"Scanning folder for Git repositories..."에서 멈출 때**  
워크스페이스를 **이 프로젝트 루트(GoTogether_app 폴더)**로 열어 주세요.

- ✅ `File > Open Folder` → **GoTogether_app** 선택  
- ❌ 상위 폴더(예: devwork)를 열면 Git 스캔이 길어지거나 멈출 수 있음  

`.vscode/settings.json`에 Git 스캔 깊이(`git.repositoryScanMaxDepth: 1`)가 설정되어 있어, 루트를 이 폴더로 열면 바로 인식됩니다.

## 실행 방법

### 웹 (브라우저에서 확인)

Android Termux/Ubuntu 등 에뮬레이터를 쓸 수 없는 환경에서는 **웹**으로 실행해 브라우저(Firefox, Chrome 등)에서 확인할 수 있습니다.

```bash
# 웹 지원 활성화 (최초 1회)
flutter config --enable-web

# 웹 서버로 실행 후 브라우저에서 http://localhost:8080 접속
flutter run -d web-server --web-port=8080

# Firefox 등에서 embedded_views/CanvasKit 오류 없이 실행 (권장)
./run_web.sh
# 또는
flutter run -d web-server --web-port=8080 --web-renderer html

# Chrome 디바이스로 실행
flutter run -d chrome
```

### Android / iOS

```bash
flutter run
```

## 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점, 테마·시스템 UI
├── data/
│   ├── di/
│   │   └── service_locator.dart   # GetIt 의존성 주입
│   ├── models/               # API 응답·리스트 모델
│   ├── network/
│   │   ├── api/constant/endpoints.dart   # API 경로·타임아웃
│   │   ├── dio_client.dart  # Dio + JWT·401 재시도
│   │   └── dio_client_*.dart # 플랫폼별(IO/Web) SSL 설정
│   └── repository/          # API 호출 래퍼
└── ui/
    ├── app_theme.dart
    ├── navigation_main_screen.dart   # Drawer + 화면 전환
    ├── home/                 # 메인(통계·공지·Recent Together)
    ├── sign/                 # 로그인·회원가입
    ├── together/             # Together 목록·상세·작성·수정·댓글·카카오맵
    ├── post/                 # Post 목록·상세·작성·수정·댓글
    ├── memo/                 # 쪽지 받은/보낸·작성
    ├── member/               # 회원(UserInfo) 목록
    ├── profile/              # 내 프로필·수정
    ├── custom_drawer/        # 사이드 메뉴
    └── widgets/              # HtmlEditorField(Quill), 카카오맵, HtmlContentView 등
```

## 구현 기능

| 구분 | 내용 |
|------|------|
| **인증** | 로그인(Sign-In), 회원가입(Register, 이메일 포함), JWT·Refresh Token 자동 갱신 |
| **홈** | 통계·공지·Recent Together Top 3 (API 연동). 메모 아이콘은 **로그인 시에만** 표시 |
| **Together** | 목록(검색·페이징)·상세·작성·수정·삭제·댓글, 카카오맵(WebView) 장소 표시·편집 |
| **Post** | 목록(검색·페이징)·상세·작성·수정·삭제·댓글 |
| **본문 에디터** | Quill 기반 HTML 에디터(Together/Post 작성·수정). 웹에서는 iframe 로드 타이밍 차이로 초기값을 타이머 폴링으로 설정 |
| **Memo** | 받은/보낸 목록·작성 |
| **Member** | UserInfo 목록(검색·페이징), Github/Homepage 링크 오픈 |
| **Profile** | UserInfo 조회·수정(Introduce, Note, Github, Homepage, Skill) |

## 웹 빌드 시 참고

- **Future already completed**: 웹에서는 `LogInterceptor`를 비활성화해 두었으며, 401 재시도 시 handler 이중 완료를 방지합니다. (`dio_client.dart`)
- **embedded_views assertion**: Together 상세 등에서 발생 시 `--web-renderer html`로 실행하거나 `./run_web.sh` 사용하면 해소됩니다.
- **dart:io**: 웹에서는 사용하지 않으며, HTTP 클라이언트는 플랫폼별 스텁(`dio_client_stub` / `dio_client_io`)으로 분리되어 있습니다.
- **카카오맵**: 웹에서는 WebView 미지원으로 지도 클릭 선택 불가. 좌표·카카오맵 링크 표시 및 편집 안내 UI 사용.
- **HTML 에디터(Quill)**: 웹뷰(webviewx) 웹 구현에서 iframe 첫 로드 시 `onPageFinished`가 호출되지 않아, 패키지 기본 초기값 설정이 동작하지 않습니다. `HtmlEditorField`에서 **지연 후 주기적 setText 폴링**으로 수정 화면 초기 본문을 설정합니다.
- **파비콘**: `web/favicon.svg`(둥근 사각형 + G)를 사용하며, `web/index.html`에서 SVG 우선 로드합니다.

## 카카오맵 Flutter SDK 전환

Dart 3.5+ 환경에서 네이티브 카카오맵 SDK 사용 시: [doc/kakao_map_sdk_migration.md](doc/kakao_map_sdk_migration.md) 참고.

## 관련 저장소

- [gotogether-backend](https://github.com/devsunset/gotogether-backend) - API 서버
- [gotogether-frontend-vue](https://github.com/devsunset/gotogether-frontend-vue) - Vue 프론트

## UI 템플릿

[Best-Flutter-UI-Templates](https://github.com/mitesh77/Best-Flutter-UI-Templates)
