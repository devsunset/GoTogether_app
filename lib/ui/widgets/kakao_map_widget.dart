import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Vue와 동일: 카카오맵 연동 (상세=표시만, 편집=클릭으로 장소 선택)
/// WebView로 카카오맵 JS API 로드 후 지도 표시/클릭 이벤트 처리
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

  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    final lat = widget.lat ?? _seoulLat;
    final lng = widget.lng ?? _seoulLng;
    final mode = widget.mode;
    final html = _buildHtml(lat: lat, lng: lng, mode: mode);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'MapClient',
        onMessageReceived: (JavaScriptMessageMessage msg) {
          try {
            final map = jsonDecode(msg.message) as Map<String, dynamic>;
            final latV = map['lat'];
            final lngV = map['lng'];
            if (latV != null && lngV != null) {
              widget.onLocationSelected?.call(
                (latV as num).toDouble(),
                (lngV as num).toDouble(),
              );
            }
          } catch (_) {}
        },
      )
      ..loadHtmlString(html, baseUrl: 'https://dapi.kakao.com');
  }

  String _buildHtml({required double lat, required double lng, required String mode}) {
    final isEdit = mode == 'edit';
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { width: 100%; height: 100%; }
    #map { width: 100%; height: 100%; min-height: 200px; }
  </style>
</head>
<body>
  <div id="map"></div>
  <script src="https://dapi.kakao.com/v2/maps/sdk.js?autoload=false&appkey=$_kakaoAppKey"></script>
  <script>
    var initialLat = $lat;
    var initialLng = $lng;
    var isEdit = $isEdit;

    kakao.maps.load(function() {
      var container = document.getElementById('map');
      var options = {
        center: new kakao.maps.LatLng(initialLat, initialLng),
        level: isEdit && (initialLat === $_seoulLat && initialLng === $_seoulLng) ? 9 : 4
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
  </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _buildWebFallback();
    }
    return SizedBox(
      height: widget.height,
      child: WebViewWidget(controller: _controller),
    );
  }

  /// 웹 플랫폼: WebView 제한으로 카카오맵 페이지 링크 안내
  Widget _buildWebFallback() {
    final lat = widget.lat;
    final lng = widget.lng;
    final hasLocation = lat != null && lng != null;
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 48, color: Colors.grey[600]),
          const SizedBox(height: 12),
          Text(
            hasLocation
                ? '모임 장소: ${lat!.toStringAsFixed(5)}, ${lng!.toStringAsFixed(5)}'
                : '지도는 iOS/Android 앱에서 확인할 수 있습니다.',
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          if (hasLocation) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('카카오맵에서 보기'),
              onPressed: () {
                final url = 'https://map.kakao.com/link/map/모임장소,$lat,$lng';
                // url_launcher 사용 가능 시 열기. 여기서는 단순 표시만.
              },
            ),
          ],
        ],
      ),
    );
  }
}
