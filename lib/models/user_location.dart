import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserLocation {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? speed;
  final DateTime timestamp;
  final bool isAlarmFiring;

  UserLocation({required this.latitude, required this.longitude, this.altitude, this.speed, required this.timestamp, this.isAlarmFiring = false});

  LatLng toLatLng() => LatLng(latitude, longitude);

  double distanceTo(double otherLat, double otherLng) {
    var p = 0.017453292519943295;
    var c = math.cos;
    var a = 0.5 - c((otherLat - latitude) * p) / 2 +
        c(latitude * p) * c(otherLat * p) *
            (1 - c((otherLng - longitude) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a)) * 1000;
  }

  Map<String, dynamic> toJson() => {
    'type': 'location',
    'latitude': latitude,
    'longitude': longitude,
    'altitude': altitude,
    'speed': speed,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'isAlarmFiring': isAlarmFiring,
  };

  factory UserLocation.fromJson(Map<String, dynamic> json) => UserLocation(
    latitude: json['latitude'],
    longitude: json['longitude'],
    altitude: json['altitude'],
    speed: json['speed'],
    timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
    isAlarmFiring: json['isAlarmFiring'] ?? false,
  );

  static bool containsData(Map<String, dynamic> json) =>
      json['type'] == 'location';
}