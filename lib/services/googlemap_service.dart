import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shopdemo/models/alarm_model.dart';
import 'package:shopdemo/models/user_location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shopdemo/services/googlemap_service_handler.dart';

typedef LocationCallback = void Function(UserLocation location);
typedef TrackingStatsCallback = void Function(Map<String, dynamic> stats);
typedef AlarmCallback = void Function(String alarmId);


class GooglemapService {
  GooglemapService._();

  static final GooglemapService instance = GooglemapService._();

  Future<void> _requestPlatformPermissions() async {
    final NotificationPermission notificationPermission = await FlutterForegroundTask.requestNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (Platform.isAndroid) {
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
    }
  }

  Future<void> _requestLocationPermisstions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Quyền GPS bị từ chối vĩnh viễn. Vào Settings để cấp quyền.');
    }
    if (permission == LocationPermission.denied) {
      throw Exception('Cần cấp quyền GPS để theo dõi lộ trình.');
    }

    if (Platform.isAndroid) {
    final status = await Permission.locationAlways.status;
    if (!status.isGranted) {
      await Permission.locationAlways.request();
    }
  }
  }

  void init() {
    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'map_tracking_service',
        channelName: 'Map Tracking Service',
        channelDescription: 'Đang theo dõi lộ trình của bạn',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(), 
        autoRunOnBoot: false,     
        allowWakeLock: true,       
        allowWifiLock: true,     
      ),
    );
  }

  Future<void> start({List<AlarmModel> alarms = const []}) async {
    await _requestPlatformPermissions();
    await _requestLocationPermisstions();

    final isRunning = await FlutterForegroundTask.isRunningService;
    if (isRunning) {
      print('=== Service already running, skip start ===');
      return; 
    }

    final ServiceRequestResult result = await FlutterForegroundTask.startService(
      serviceId: 600,
      notificationTitle: 'Đang theo dõi lộ trình',
      notificationText: '0.00 km • 0 điểm',
      callback: startMapTrackingService,
    );

    if (result is ServiceRequestFailure) {
      throw Exception('Không thể khởi động dịch vụ: ${result.error}');
    }

    if (alarms.isNotEmpty) {
      sendAlarms(alarms);
    }
  }

  Future<void> stop() async {
    final ServiceRequestResult result =
        await FlutterForegroundTask.stopService();
    if (result is ServiceRequestFailure) {
      throw result.error;
    }
  }

  Future<void> resetRoute() async {
    FlutterForegroundTask.sendDataToTask({'action': 'reset'});
  }

  void sendAlarms(List<AlarmModel> alarms) {
    FlutterForegroundTask.sendDataToTask({
      'alarms': alarms.map((e) => e.toJson()).toList(),
    });
  }

  Future<bool> get isRunningService => FlutterForegroundTask.isRunningService;

  final List<LocationCallback> _locationCallbacks = [];
  final List<TrackingStatsCallback> _statsCallbacks = [];

  void _onReceiveTaskData(Object data) {
    if (data is! Map<String, dynamic>) return;

    if (UserLocation.containsData(data)) {
      final UserLocation location = UserLocation.fromJson(data);
      for (final cb in _locationCallbacks.toList()) {
        cb(location);
      }
    }

    if (data['type'] == 'tracking_stats') {
      for (final cb in _statsCallbacks.toList()) {
        cb(data);
      }
    }
  }

  void addLocationCallback(LocationCallback callback) {
    if (!_locationCallbacks.contains(callback)) {
      _locationCallbacks.add(callback);
    }
  }

  void removeLocationCallback(LocationCallback callback) {
    _locationCallbacks.remove(callback);
  }

  void addStatsCallback(TrackingStatsCallback callback) {
    if (!_statsCallbacks.contains(callback)) {
      _statsCallbacks.add(callback);
    }
  }

  void removeStatsCallback(TrackingStatsCallback callback) {
    _statsCallbacks.remove(callback);
  }
}