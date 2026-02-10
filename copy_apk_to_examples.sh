#!/bin/sh
# APK 빌드 성공 시 /workspace/examples 로 복사
# 사용: flutter build apk --release 후 ./copy_apk_to_examples.sh
APK_SRC="build/app/outputs/flutter-apk/app-release.apk"
DEST_DIR="/workspace/examples"
if [ -f "$APK_SRC" ]; then
  cp "$APK_SRC" "$DEST_DIR/GoTogether-app-release.apk"
  echo "Copied APK to $DEST_DIR/GoTogether-app-release.apk"
else
  echo "APK not found. Run: flutter build apk --release"
  exit 1
fi
