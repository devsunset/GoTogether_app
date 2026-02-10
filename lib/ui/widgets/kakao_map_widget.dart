import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

// 웹: iframe으로 kakao_map_embed.html 로드 (카카오맵 JS API). 모바일: stub 사용.
import 'package:gotogether/ui/widgets/kakao_map_widget_stub.dart'
    if (dart.library.html) 'package:gotogether/ui/widgets/kakao_map_widget_web.dart' as web_embed;

/// 투게더/모임 장소 카카오맵 연동 (상세=표시만, 편집=클릭으로 장소 선택)
/// 모바일(Android/iOS): Flutter SDK(kakao_map_sdk)로 지도 표시.
/// 웹: iframe + kakao_map_embed.html(카카오맵 JS API)로 지도 표시, 편집 시 postMessage로 좌표 전달.
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
  static const double _seoulLat = 37.56683319828021;
  static const double _seoulLng = 126.97857302284947;

  KakaoMapController? _mapController;
  Poi? _markerPoi;

  double get _lat => widget.lat ?? _seoulLat;
  double get _lng => widget.lng ?? _seoulLng;

  Future<void> _addMarkerAt(LatLng position) async {
    final ctrl = _mapController;
    if (ctrl == null) return;
    if (_markerPoi != null) {
      await ctrl.labelLayer.removePoi(_markerPoi!);
      _markerPoi = null;
    }
    final style = PoiStyle(
      icon: KImage.fromAsset('assets/icon/app_icon.png', 48, 48),
    );
    final poi = await ctrl.labelLayer.addPoi(
      position,
      style: style,
      id: 'meeting_poi',
    );
    if (mounted) _markerPoi = poi;
  }

  @override
  Widget build(BuildContext context) {
    // 웹: kakao_map_sdk 미지원 → iframe으로 kakao_map_embed.html(카카오맵 JS API) 사용
    if (kIsWeb) {
      return web_embed.WebKakaoMapEmbed(
        lat: _lat,
        lng: _lng,
        height: widget.height,
        mode: widget.mode,
        onLocationSelected: widget.onLocationSelected,
      );
    }

    final option = KakaoMapOption(
      position: LatLng(_lat, _lng),
      zoomLevel: 14,
    );

    return SizedBox(
      height: widget.height,
      child: KakaoMap(
        option: option,
        onMapReady: (KakaoMapController controller) async {
          _mapController = controller;
          await _addMarkerAt(LatLng(_lat, _lng));
        },
        onTerrainClick: widget.mode == 'edit'
            ? (KPoint point, LatLng position) async {
                await _addMarkerAt(position);
                _mapController?.moveCamera(
                  CameraUpdate.newCenterPosition(position, zoomLevel: 14),
                );
                widget.onLocationSelected?.call(
                  position.latitude,
                  position.longitude,
                );
              }
            : null,
        onMapError: (Error error) {
          if (kDebugMode) {
            // ignore: avoid_print
            print('KakaoMap error: $error');
          }
        },
      ),
    );
  }
}
