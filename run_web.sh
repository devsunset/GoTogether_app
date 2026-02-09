#!/bin/sh
# 웹 서버 실행 (고정 포트 8080, HTML 렌더러 사용)
# HTML 렌더러: Firefox/Chrome에서 CanvasKit embedded_views 오류 방지
exec flutter run -d web-server --web-port=8080 --web-renderer html
