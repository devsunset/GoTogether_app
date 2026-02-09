import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

import 'kakao_map_widget_stub.dart' if (dart.library.html) 'kakao_map_widget_web.dart' as web_embed;

/// 투게더/모임 장소 카카오맵 연동 (상세=표시만, 편집=클릭으로 장소 선택)
/// 모바일: Flutter SDK(kakao_map_sdk)로 지도 표시. 웹: SDK 미지원으로 카카오맵 JavaScript API 임베드(iframe)로 동일하게 지도 표시.
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
    if (kIsWeb) {
      // 편집 모드: 초기 좌표 없어도 지도 표시 후 클릭으로 위치 선택 (Vue와 동일). 보기 모드: 좌표 있을 때만 지도 표시.
      final showMap = widget.mode == 'edit' ||
          (widget.lat != null && widget.lng != null);
      if (showMap) {
        return web_embed.WebKakaoMapEmbed(
          lat: widget.lat ?? _seoulLat,
          lng: widget.lng ?? _seoulLng,
          height: widget.height,
          mode: widget.mode,
          onLocationSelected: widget.onLocationSelected,
        );
      }
      return _buildWebFallback();
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
