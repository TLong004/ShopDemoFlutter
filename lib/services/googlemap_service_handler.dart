import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shopdemo/models/alarm_model.dart';
import 'package:shopdemo/models/user_location.dart';

@pragma('vm:entry-point')
void startMapTrackingService() {
  FlutterForegroundTask.setTaskHandler(MapTrackingServiceHandler());
}

class MapTrackingServiceHandler extends TaskHandler {
  StreamSubscription<Position>? _positionStream;
  List<UserLocation> _locationHistory = [];
  List<AlarmModel> _alarms = [];
  double _totalDistance = 0.0;
  UserLocation? _lastLocation;

  @override
  void onReceiveData(Object data) {
    if (data is! Map<String, dynamic>) return;

    if (data.containsKey('alarms')) {
      final List list = data['alarms'] as List;
      _alarms = list.map((e) => AlarmModel.fromJson(e as Map<String, dynamic>)).toList();
      dev.log('MapTrackingServiceHandler: nhận ${_alarms.length} alarms');
    }

    if (data['action'] == 'reset') {
      _locationHistory.clear();
      _totalDistance = 0.0;
      _lastLocation = null;
      dev.log('MapTrackingServiceHandler: đã reset lộ trình');
    }
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    dev.log('MapTrackingServiceHandler: bắt đầu tracking');

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      _onPositionChanged,
      onError: (e) => dev.log('MapTrackingServiceHandler: lỗi GPS: $e'),
    );
  }

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await _positionStream?.cancel();
    dev.log('MapTrackingServiceHandler: dừng tracking');
  }

  void _onPositionChanged(Position position) {
    dev.log('MapTrackingServiceHandler: GPS nhận: ${position.latitude}, ${position.longitude}');

    final newLocation = UserLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      speed: position.speed,
      altitude: position.altitude,
      timestamp: position.timestamp,
    );

    if (_lastLocation != null) {
      final double distance = _lastLocation!.distanceTo(
        newLocation.latitude,
        newLocation.longitude,
      );
      if (distance > 0) {
        _totalDistance += distance;
      }
    }

    _lastLocation = newLocation;
    _locationHistory.add(newLocation);

    bool isAlarmFiring = false;
    final List<AlarmModel> updatedAlarms = _alarms.map((alarm) {
      if (alarm.isActive && alarm.shouldTrigger(newLocation)) {
        dev.log('MapTrackingServiceHandler: ALARM FIRED: ${alarm.title}');
        isAlarmFiring = true;
        return alarm.copyWith(isActive: false);
      }
      return alarm;
    }).toList();
    _alarms = updatedAlarms;

    final UserLocation locationToSend = UserLocation(
      latitude: newLocation.latitude,
      longitude: newLocation.longitude,
      altitude: newLocation.altitude,
      speed: newLocation.speed,
      timestamp: newLocation.timestamp,
      isAlarmFiring: isAlarmFiring,
    );

    dev.log('MapTrackingServiceHandler: sendDataToMain isAlarmFiring=$isAlarmFiring');
    FlutterForegroundTask.sendDataToMain(locationToSend.toJson());

    FlutterForegroundTask.sendDataToMain({
      'type': 'tracking_stats',
      'totalDistance': _totalDistance,
      'routePointsCount': _locationHistory.length,
      'alarms': updatedAlarms.map((e) => e.toJson()).toList(),
    });

    FlutterForegroundTask.updateService(
      notificationTitle: isAlarmFiring
          ? '🔔 Đã đến: ${_alarms.firstWhere((a) => !a.isActive, orElse: () => AlarmModel(id: '', title: 'Điểm đến')).title}'
          : 'Đang theo dõi lộ trình',
      notificationText: isAlarmFiring
          ? 'Bạn đã đến đích!'
          : '${(_totalDistance / 1000).toStringAsFixed(2)} km • ${_locationHistory.length} điểm',
    );
  }
}