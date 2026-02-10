// 웹 전용: iframe으로 카카오맵 JavaScript API 지도 표시 (Flutter SDK는 웹 미지원)
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 웹에서 카카오맵 지도를 iframe으로 표시. 편집 모드에서 클릭 시 마커 이동 후 onLocationSelected 호출 (Vue와 동일).
class WebKakaoMapEmbed extends StatefulWidget {
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
  State<WebKakaoMapEmbed> createState() => _WebKakaoMapEmbedState();
}

class _WebKakaoMapEmbedState extends State<WebKakaoMapEmbed> {
  static int _viewCounter = 0;
  late String _viewType;
  bool _registered = false;
  dynamic _messageListener;

  @override
  void initState() {
    super.initState();
    _viewType = 'kakao-map-embed-${_viewCounter++}';
    _registerView();
    if (widget.mode == 'edit' && widget.onLocationSelected != null) {
      _messageListener = (html.Event e) {
        final event = e as html.MessageEvent;
        final data = event.data;
        if (data is! Map) return;
        if (data['type'] == 'kakao-map-location') {
          final lat = (data['lat'] is num) ? (data['lat'] as num).toDouble() : null;
          final lng = (data['lng'] is num) ? (data['lng'] as num).toDouble() : null;
          if (lat != null && lng != null && mounted) {
            widget.onLocationSelected!(lat, lng);
          }
        }
      };
      html.window.addEventListener('message', _messageListener);
    }
  }

  @override
  void dispose() {
    if (_messageListener != null) {
      html.window.removeEventListener('message', _messageListener);
    }
    super.dispose();
  }

  void _registerView() {
    if (_registered) return;
    final lat = widget.lat;
    final lng = widget.lng;
    // 루트 기준 절대 경로로 iframe 로드 (Flutter 웹 서버가 web/ 파일을 루트에 서빙)
    final params = <String, String>{
      'lat': lat.toString(),
      'lng': lng.toString(),
      'level': '3',
    };
    if (widget.mode == 'edit') params['edit'] = '1';
    final query = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    final pathPrefix = Uri.base.path == '/' || Uri.base.path.isEmpty ? '' : Uri.base.path.replaceAll(RegExp(r'/$'), '');
    final embedSrc = '${pathPrefix}/kakao_map_embed.html?$query';
    final iframe = html.IFrameElement()
      ..src = embedSrc
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.border = 'none'
      ..style.display = 'block';
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => iframe,
    );
    _registered = true;
  }

  @override
  Widget build(BuildContext context) {
    final mapUrl =
        'https://map.kakao.com/link/map/모임장소,${widget.lat},${widget.lng}';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          height: widget.height,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: HtmlElementView(viewType: _viewType),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('카카오맵에서 크게 보기'),
            onPressed: () async {
              final uri = Uri.parse(mapUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ),
      ],
    );
  }
}
