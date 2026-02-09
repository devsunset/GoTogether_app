# GoTogether_app

GoTogether 모바일/웹 클라이언트 (Flutter).  
백엔드 [gotogether-backend](https://github.com/devsunset/gotogether-backend) API와 연동하며, Vue/React 프론트와 동일한 기능을 제공합니다.

## 요구사항

- Flutter SDK (stable, 2.17.5+)
- Dart 2.17.5+

## Cursor / VS Code에서 Git 인식

**"Scanning folder for Git repositories..."에서 멈출 때**  
워크스페이스를 **이 프로젝트 루트(GoTogether_app 폴더)**로 열어 주세요.

- ✅ `File > Open Folder` → **GoTogether_app** 선택  
- ❌ 상위 폴더(예: devwork)를 열면 Git 스캔이 길어지거나 멈출 수 있음  

`.vscode/settings.json`에 Git 스캔 깊이(`git.repositoryScanMaxDepth: 1`)가 설정되어 있어, 루트를 이 폴더로 열면 바로 인식됩니다.

## 실행 방법

### 웹 (에뮬레이터 없이 확인)

Android Termux/Ubuntu 등 에뮬레이터를 쓸 수 없는 환경에서는 **웹**으로 실행해 브라우저에서 확인할 수 있습니다.

```bash
# 웹 지원 활성화 (최초 1회)
flutter config --enable-web

# 웹 서버로 실행 후 브라우저에서 http://localhost:8080 접속
flutter run -d web-server --web-port=8080

# 또는 Chrome 디바이스로 실행
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
│   │   ├── dio_client.dart   # Dio + JWT·401 재시도
│   │   └── dio_client_*.dart # 플랫폼별(IO/Web) SSL 설정
│   └── repository/           # API 호출 래퍼
└── ui/
    ├── app_theme.dart
    ├── navigation_main_screen.dart   # Drawer + 화면 전환
    ├── home/                 # 메인(통계·공지·Recent Together)
    ├── sign/                 # 로그인·회원가입
    ├── together/             # Together 목록·상세·작성·수정·댓글
    ├── post/                 # Post 목록·상세·작성·수정·댓글
    ├── memo/                 # 쪽지 받은/보낸·작성
    ├── member/               # 회원(UserInfo) 목록
    ├── profile/              # 내 프로필·수정
    └── custom_drawer/        # 사이드 메뉴
```

## 구현 기능

| 구분 | 내용 |
|------|------|
| **인증** | 로그인(Sign-In), 회원가입(Register, 이메일 포함), JWT·Refresh Token 자동 갱신 |
| **홈** | 통계·공지·Recent Together Top 3 (API 연동) |
| **Together** | 목록(검색·페이징)·상세·작성·수정·삭제·댓글 |
| **Post** | 목록(검색·페이징)·상세·작성·수정·삭제·댓글 |
| **Memo** | 받은/보낸 목록·작성 |
| **Member** | UserInfo 목록(검색·페이징) |
| **Profile** | UserInfo 조회·수정(Introduce, Note, Github, Homepage, Skill) |

## 웹 빌드 시 참고

- **Future already completed**: 웹에서는 `LogInterceptor`를 비활성화해 두었습니다. (`dio_client.dart`)
- **dart:io**: 웹에서는 사용하지 않으며, HTTP 클라이언트는 플랫폼별 스텁(`dio_client_stub` / `dio_client_io`)으로 분리되어 있습니다.

## 관련 저장소

- [gotogether-backend](https://github.com/devsunset/gotogether-backend) - API 서버
- [gotogether-frontend-vue](https://github.com/devsunset/gotogether-frontend-vue) - Vue 프론트
- [gotogether-frontend-react](https://github.com/devsunset/gotogether-frontend-react) - React 프론트

## UI 템플릿

[Best-Flutter-UI-Templates](https://github.com/mitesh77/Best-Flutter-UI-Templates)
