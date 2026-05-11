import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shopdemo/models/user_location.dart';

class MapTrackingState {
  final List<UserLocation> routePoints;
  final UserLocation? currentLocation;
  final bool isTracking;
  final double totalDistance;

  MapTrackingState({
    this.routePoints = const [],
    this.currentLocation,
    this.isTracking = false,
    this.totalDistance = 0.0,
  });

  List<LatLng> get polylineCoordinates => routePoints.map((loc) => LatLng(loc.latitude, loc.longitude)).toList();
}