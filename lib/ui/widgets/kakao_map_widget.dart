import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Vue와 동일: 카카오맵 연동 (상세=표시만, 편집=클릭으로 장소 선택)
/// 모바일: WebView로 카카오맵 JS API 로드 후 지도 표시/클릭 이벤트 처리
/// 웹: WebView 미지원으로 좌표·링크 표시 및 편집 시 수동 좌표 입력 안내
///
/// 카카오맵 Flutter SDK(kakao_map_sdk) 사용 시: Dart SDK 3.5+ 필요.
/// 전환 방법은 doc/kakao_map_sdk_migration.md 참고.
class KakaoMapWidget extends StatefulWidget {
  /// 'view': 마커만 표시, 'edit': 클릭 시 마커 이동 + onLocationSelected 콜백
  final String mode;
  final double? lat;
  final double? lng;
  final double height;
  final void Function(double lat, double lng)? onLocationSelected;

  const KakaoMapWidget({
    Key? key,
    this.mode = 'view',
    this.lat,
    this.lng,
    this.height = 300,
    this.onLocationSelected,
  }) : super(key: key);

  @override
  State<KakaoMapWidget> createState() => _KakaoMapWidgetState();
}

class _KakaoMapWidgetState extends State<KakaoMapWidget> {
  static const String _kakaoAppKey = '66e0071736a9e3ccef3fa87fc5abacba';
  static const double _seoulLat = 37.56683319828021;
  static const double _seoulLng = 126.97857302284947;

  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) return;
    _initController();
  }

  void _initController() {
    final lat = widget.lat ?? _seoulLat;
    final lng = widget.lng ?? _seoulLng;
    final mode = widget.mode;
    final heightPx = widget.height.toInt();
    final html = _buildHtml(lat: lat, lng: lng, mode: mode, heightPx: heightPx);

    final ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (request.url.startsWith('https://dapi.kakao.com') ||
                request.url.startsWith('https://t1.kakaocdn.net') ||
                request.url.startsWith('about:blank')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'MapClient',
        onMessageReceived: (msg) {
          try {
            final map = jsonDecode(msg.message) as Map<String, dynamic>;
            final latV = map['lat'];
            final lngV = map['lng'];
            if (latV != null && lngV != null && mounted) {
              widget.onLocationSelected?.call(
                (latV as num).toDouble(),
                (lngV as num).toDouble(),
              );
            }
          } catch (_) {}
        },
      )
      ..loadHtmlString(html, baseUrl: 'https://dapi.kakao.com');

    _controller = ctrl;
  }

  String _buildHtml({
    required double lat,
    required double lng,
    required String mode,
    required int heightPx,
  }) {
    final isEdit = mode == 'edit';
    final isDefaultCenter =
        (lat - _seoulLat).abs() < 1e-6 && (lng - _seoulLng).abs() < 1e-6;
    final zoomLevel = (isEdit && isDefaultCenter) ? 9 : 4;
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { width: 100%; height: 100%; overflow: hidden; }
    #map { width: 100%; height: ${heightPx}px; min-height: 200px; }
  </style>
</head>
<body>
  <div id="map"></div>
  <script>
    function runMap() {
      if (typeof kakao === 'undefined') {
        setTimeout(runMap, 100);
        return;
      }
      var initialLat = $lat;
      var initialLng = $lng;
      var isEdit = $isEdit;
      var zoomLevel = $zoomLevel;

      kakao.maps.load(function() {
        var container = document.getElementById('map');
        if (!container) return;
        var options = {
          center: new kakao.maps.LatLng(initialLat, initialLng),
          level: zoomLevel
        };
        var map = new kakao.maps.Map(container, options);
        var markerPosition = new kakao.maps.LatLng(initialLat, initialLng);
        var marker = new kakao.maps.Marker({ position: markerPosition });
        marker.setMap(map);

        if (isEdit) {
          kakao.maps.event.addListener(map, 'click', function(mouseEvent) {
            var latlng = mouseEvent.latLng;
            marker.setPosition(latlng);
            var lat = latlng.getLat();
            var lng = latlng.getLng();
            if (window.MapClient && window.MapClient.postMessage) {
              window.MapClient.postMessage(JSON.stringify({ lat: lat, lng: lng }));
            }
          });
        }
      });
    }
    var s = document.createElement('script');
    s.src = 'https://dapi.kakao.com/v2/maps/sdk.js?autoload=false&appkey=$_kakaoAppKey';
    s.onload = runMap;
    s.onerror = function() { setTimeout(runMap, 200); };
    document.head.appendChild(s);
  </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || _controller == null) {
      return _buildWebFallback();
    }
    return SizedBox(
      height: widget.height,
      child: WebViewWidget(controller: _controller!),
    );
  }

  Widget _buildWebFallback() {
    final lat = widget.lat;
    final lng = widget.lng;
    final hasLocation = lat != null && lng != null;
    final mapUrl = hasLocation
        ? 'https://map.kakao.com/link/map/모임장소,$lat,$lng'
        : 'https://map.kakao.com/';
    final isEdit = widget.mode == 'edit';

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 12),
            Text(
              hasLocation
                  ? '모임 장소: ${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}'
                  : (isEdit
                      ? '웹에서는 지도에서 직접 위치를 선택할 수 없습니다. 아래 버튼으로 카카오맵을 열어 장소를 확인한 후, 앱에서 다시 선택해 주세요.'
                      : '등록된 모임 장소가 없습니다.'),
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.open_in_new, size: 18),
              label: Text(hasLocation ? '카카오맵에서 보기' : '카카오맵 열기'),
              onPressed: () async {
                final uri = Uri.parse(mapUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
