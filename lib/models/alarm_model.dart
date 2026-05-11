import 'dart:math' as math;

import 'package:shopdemo/models/user_location.dart';

class AlarmModel {
  final String id;
  final String title;
  final DateTime? triggerTime;
  final UserLocation? targetLocation;
  final double radius;
  final bool isActive;

  AlarmModel({
    required this.id,
    this.title = "Thông báo",
    this.triggerTime,
    this.targetLocation,
    this.radius = 200, 
    this.isActive = true,
  });

  double distanceTo(double userLat, double userLng) {
    if (targetLocation == null) return double.maxFinite;
    
    var p = 0.017453292519943295;
    var c = math.cos;
    var a = 0.5 - c((targetLocation!.latitude - userLat) * p) / 2 +
        c(userLat * p) * c(targetLocation!.latitude * p) *
            (1 - c((targetLocation!.longitude - userLng) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a)) * 1000; 
  }

  bool shouldTrigger(UserLocation userLoc) {
    if (!isActive) return false;
    if (triggerTime != null && DateTime.now().isAfter(triggerTime!)) return true;
    if (targetLocation != null && distanceTo(userLoc.latitude, userLoc.longitude) <= radius) return true;
    return false;
  }

  AlarmModel copyWith({
    String? id,
    String? title,
    DateTime? triggerTime,
    UserLocation? targetLocation,
    double? radius,
    bool? isActive,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      title: title ?? this.title,
      triggerTime: triggerTime ?? this.triggerTime,
      targetLocation: targetLocation ?? this.targetLocation,
      radius: radius ?? this.radius,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'triggerTime': triggerTime?.millisecondsSinceEpoch,
    'targetLat': targetLocation?.latitude,
    'targetLng': targetLocation?.longitude,
    'radius': radius,
    'isActive': isActive,
  };

  factory AlarmModel.fromJson(Map<String, dynamic> json) => AlarmModel(
    id: json['id'],
    title: json['title'] ?? 'Thông báo',
    triggerTime: json['triggerTime'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['triggerTime'])
        : null,
    targetLocation: json['targetLat'] != null
        ? UserLocation(
            latitude: json['targetLat'],
            longitude: json['targetLng'],
            timestamp: DateTime.now(),
          )
        : null,
    radius: json['radius'] ?? 200,
    isActive: json['isActive'] ?? true,
  );  
}