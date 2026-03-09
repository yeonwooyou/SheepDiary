import 'package:google_maps_flutter/google_maps_flutter.dart';

CameraUpdate getBoundsCameraUpdate(Set<LatLng> positions, {double padding = 50}) {
  if (positions.isEmpty) {
    throw ArgumentError("좌표가 하나도 없습니다.");
  }

  final latitudes = positions.map((p) => p.latitude).toList();
  final longitudes = positions.map((p) => p.longitude).toList();

  final southwest = LatLng(
    latitudes.reduce((a, b) => a < b ? a : b),
    longitudes.reduce((a, b) => a < b ? a : b),
  );

  final northeast = LatLng(
    latitudes.reduce((a, b) => a > b ? a : b),
    longitudes.reduce((a, b) => a > b ? a : b),
  );

  final bounds = LatLngBounds(southwest: southwest, northeast: northeast);

  return CameraUpdate.newLatLngBounds(bounds, padding);
}