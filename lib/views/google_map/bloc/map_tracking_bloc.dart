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
        super(MapTrackingInitial()) {
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
    if (state is MapTrackingStopped) {
      return MapTrackingLoaded(
        routePoints: state.routePoints,
        totalDistance: state.totalDistance,
        activeAlarms: state.activeAlarms,
        currentLocation: state.currentLocation,
      );
    }
    return const MapTrackingLoaded(
      routePoints: [],
      totalDistance: 0.0,
    );
  }

  Future<void> _onStartTracking(
    StartTrackingEvent event,
    Emitter<MapTrackingState> emit,
  ) async {
    final current = _currentLoaded;
    emit(MapTrackingLoading());
    try {
      await _service.start(alarms: current.activeAlarms);
      emit(MapTrackingLoaded(
        routePoints: current.routePoints,
        totalDistance: current.totalDistance,
        activeAlarms: current.activeAlarms,
        currentLocation: current.currentLocation,
      ));
    } catch (e) {
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
      final currentState = state;
      if (currentState is MapTrackingLoaded) {
        emit(MapTrackingLoaded(
          routePoints: [],
          totalDistance: 0.0,
          activeAlarms: currentState.activeAlarms,
          currentLocation: currentState.currentLocation,
        ));
      } else if (currentState is MapTrackingStopped) {
        emit(MapTrackingStopped(
          routePoints: [],
          totalDistance: 0.0,
          activeAlarms: currentState.activeAlarms,
          currentLocation: currentState.currentLocation,
        ));
      }
    } catch (e) {
      emit(MapTrackingError(e.toString()));
    }
  }

  void _onLocationUpdated(LocationUpdateEvent event, Emitter<MapTrackingState> emit) {
    if (state is! MapTrackingLoaded) return;
    final current = state as MapTrackingLoaded;
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
    if (state is! MapTrackingLoaded) return;
    final current = state as MapTrackingLoaded;
    try {
      emit(MapTrackingLoaded(
        routePoints: current.routePoints,
        totalDistance: event.totalDistance,
        activeAlarms: event.alarms.isNotEmpty ? event.alarms : current.activeAlarms,
        currentLocation: current.currentLocation,
        firedAlarm: null,
      ));
    } catch (e) {
      emit(MapTrackingError(e.toString()));
    }
  }

  void _onAddAlarm(AddAlarmEvent event, Emitter<MapTrackingState> emit) {
    final currentState = state;
    if (currentState is MapTrackingLoaded) {
      final updatedAlarms = [...currentState.activeAlarms, event.alarm];
      emit(MapTrackingLoaded(
        routePoints: currentState.routePoints,
        totalDistance: currentState.totalDistance,
        activeAlarms: updatedAlarms,
        currentLocation: currentState.currentLocation,
      ));
      _service.sendAlarms(updatedAlarms);
      final loc = currentState.currentLocation;
      if (loc != null && event.alarm.shouldTrigger(loc)) {
        add(AlarmFiredEvent(event.alarm));
      }
    } else if (currentState is MapTrackingStopped) {
      emit(MapTrackingStopped(
        routePoints: currentState.routePoints,
        totalDistance: currentState.totalDistance,
        activeAlarms: [...currentState.activeAlarms, event.alarm],
        currentLocation: currentState.currentLocation,
      ));
    } else {
      emit(MapTrackingStopped(
        routePoints: const [],
        totalDistance: 0,
        activeAlarms: [event.alarm],
      ));
    }
  }

  void _onRemoveAlarm(RemoveAlarmEvent event, Emitter<MapTrackingState> emit) {
    final currentState = state;
    if (currentState is MapTrackingLoaded) {
      final updatedAlarms = currentState.activeAlarms.where((a) => a.id != event.alarmId).toList();
      emit(MapTrackingLoaded(
        routePoints: currentState.routePoints,
        totalDistance: currentState.totalDistance,
        activeAlarms: updatedAlarms,
        currentLocation: currentState.currentLocation,
      ));
      _service.sendAlarms(updatedAlarms);
    } else if (currentState is MapTrackingStopped) {
      emit(MapTrackingStopped(
        routePoints: currentState.routePoints,
        totalDistance: currentState.totalDistance,
        activeAlarms: currentState.activeAlarms.where((a) => a.id != event.alarmId).toList(),
        currentLocation: currentState.currentLocation,
      ));
    }
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
