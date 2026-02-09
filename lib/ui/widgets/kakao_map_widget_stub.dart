// 비웹 환경용 스텁 (kakao_map_widget_web.dart 대신 조건부 import용)
import 'package:flutter/material.dart';

/// 웹이 아닌 환경에서는 사용되지 않음 (모바일은 네이티브 KakaoMap 사용).
class WebKakaoMapEmbed extends StatelessWidget {
  final double lat;
  final double lng;
  final double height;
  final String mode;
  final void Function(double lat, double lng)? onLocationSelected;

  const WebKakaoMapEmbed({
    Key? key,
    required this.lat,
    required this.lng,
    this.height = 280,
    this.mode = 'view',
    this.onLocationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, child: const Center(child: Text('지도 (웹에서만 표시)')));
  }
}
