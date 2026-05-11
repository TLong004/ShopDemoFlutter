import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shopdemo/models/alarm_model.dart';
import 'package:shopdemo/models/user_location.dart';
import 'package:shopdemo/services/googlemap_service.dart';

part 'map_tracking_event.dart';
part 'map_tracking_state.dart';

class MapTrackingBloc extends Bloc<MapTrackingEvent, MapTrackingState> {
  final GooglemapService _service;

  MapTrackingBloc({GooglemapService? service})
      : _service = service ?? GooglemapService.instance,
        super( MapTrackingInitial()) {
    _service.addLocationCallback(_onLocationUpdate);
    _service.addStatsCallback(_onStatsUpdate);
    _syncServiceState();
    on<StartTrackingEvent>(_onStartTracking);
    on<StopTrackingEvent>(_onStopTracking);
    on<ResetRouteEvent>(_onResetRoute);
    on<LocationUpdateEvent>(_onLocationUpdated);
    on<TrackingStatsUpdateEvent>(_onTrackingStatsUpdate);
    on<AddAlarmEvent>(_onAddAlarm);
    on<RemoveAlarmEvent>(_onRemoveAlarm);
    on<AlarmFiredEvent>(_onAlarmFired);
  }

  

  Future<void> _syncServiceState() async {
    final isRunning = await FlutterForegroundTask.isRunningService;
    print('=== syncServiceState: isRunning=$isRunning ===');
    if (isRunning) {
      emit(const MapTrackingLoaded(
        routePoints: [],
        totalDistance: 0.0,
      ));
    }
  }

  MapTrackingLoaded get _currentLoaded {
    final state = this.state;
    if (state is MapTrackingLoaded) return state;
    return const MapTrackingLoaded(
      routePoints: [],
      totalDistance: 0.0,
    );
  }

  Future<void> _onStartTracking(
    StartTrackingEvent event,
    Emitter<MapTrackingState> emit,
  ) async {
    debugPrint('=== _onStartTracking called ===');
    emit(MapTrackingLoading());
    try {
      final current = _currentLoaded;
      print('=== Calling _service.start() ===');
      await _service.start(alarms: current.activeAlarms);
      debugPrint('=== _service.start() SUCCESS ===');
      emit(MapTrackingLoaded(
        routePoints: current.routePoints,
        totalDistance: current.totalDistance,
        activeAlarms: current.activeAlarms,
        currentLocation: current.currentLocation,
      ));
    } catch (e) {
      print('=== _onStartTracking ERROR: $e ===');
      emit(MapTrackingError(e.toString()));
    }
  }
  void _onStopTracking(StopTrackingEvent event, Emitter<MapTrackingState> emit) async {
    try {
      await _service.stop();
      final current = _currentLoaded;
      emit(MapTrackingStopped(
        routePoints: current.routePoints,
        totalDistance: current.totalDistance,
        activeAlarms: current.activeAlarms,
        currentLocation: current.currentLocation,
      ));
    } catch (e) {
      emit(MapTrackingError(e.toString()));
    }
  }

  void _onResetRoute(ResetRouteEvent event, Emitter<MapTrackingState> emit) async {
    try {
      await _service.resetRoute();
      final current = _currentLoaded;
      emit(MapTrackingLoaded(
        routePoints: [],
        totalDistance: 0.0,
        activeAlarms: current.activeAlarms,
        currentLocation: current.currentLocation,
      ));
    } catch (e) {
      emit(MapTrackingError(e.toString()));
    }
  }

  void _onLocationUpdated(LocationUpdateEvent event, Emitter<MapTrackingState> emit) {
    final current = _currentLoaded;
    try {
      emit(MapTrackingLoaded(
        routePoints: [...current.routePoints, event.location],
        totalDistance: current.totalDistance,
        activeAlarms: current.activeAlarms,
        currentLocation: event.location,
        firedAlarm: null,
      ));
    } catch (e) {
      emit(MapTrackingError(e.toString()));
    }
  }
  void _onTrackingStatsUpdate(TrackingStatsUpdateEvent event, Emitter<MapTrackingState> emit) {
    final current = _currentLoaded;
    try {
      emit(MapTrackingLoaded(
        routePoints: current.routePoints,
        totalDistance: event.totalDistance,
        activeAlarms: current.activeAlarms,
        currentLocation: current.currentLocation,
        firedAlarm: null,
      ));
    } catch (e) {
      emit(MapTrackingError(e.toString()));
    }
  }
  void _onAddAlarm(AddAlarmEvent event, Emitter<MapTrackingState> emit) {
    final current = _currentLoaded;
    final updatedAlarms = List<AlarmModel>.from(current.activeAlarms)..add(event.alarm);
    emit(MapTrackingLoaded(
      routePoints: current.routePoints,
      totalDistance: current.totalDistance,
      activeAlarms: updatedAlarms,
      currentLocation: current.currentLocation,
    ));
  }
  void _onRemoveAlarm(RemoveAlarmEvent event, Emitter<MapTrackingState> emit) {
    final current = _currentLoaded;
    final updatedAlarms = List<AlarmModel>.from(current.activeAlarms)..removeWhere((alarm) => alarm.id == event.alarmId);
    emit(MapTrackingLoaded(
      routePoints: current.routePoints,
      totalDistance: current.totalDistance,
      activeAlarms: updatedAlarms,
      currentLocation: current.currentLocation,
    ));
  }
  void _onAlarmFired(AlarmFiredEvent event, Emitter<MapTrackingState> emit) {
    final current = _currentLoaded;
    final updatedAlarms = current.activeAlarms
        .map((a) => a.id == event.alarm.id ? a.copyWith(isActive: false) : a)
        .toList();
    emit(MapTrackingLoaded(
      routePoints: current.routePoints,
      totalDistance: current.totalDistance,
      activeAlarms: updatedAlarms,
      currentLocation: current.currentLocation,
      firedAlarm: event.alarm,
    ));
  }

  void _onLocationUpdate(UserLocation location) {
    add(LocationUpdateEvent(location));
    if (location.isAlarmFiring) {
      final current = _currentLoaded;
      final alarmFired = current.activeAlarms
          .where((a) => a.isActive)
          .firstWhere(
            (a) => a.shouldTrigger(location),
            orElse: () => AlarmModel(id: '', title: ''),
          );
      if (alarmFired.id.isNotEmpty) {
        add(AlarmFiredEvent(alarmFired));
      }
    }
  }

  void _onStatsUpdate(Map<String, dynamic> stats) {
    add(TrackingStatsUpdateEvent(
      totalDistance: (stats['totalDistance'] as num).toDouble(),
      routePointsCount: stats['routePointsCount'] as int,
      alarms: (stats['alarms'] as List)
          .map((e) => AlarmModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    ));
  }

  @override
  Future<void> close() {
    _service.removeLocationCallback(_onLocationUpdate);
    _service.removeStatsCallback(_onStatsUpdate);
    return super.close();
  }
}
