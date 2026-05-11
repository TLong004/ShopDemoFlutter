part of 'map_tracking_bloc.dart';

sealed class MapTrackingEvent extends Equatable {
  const MapTrackingEvent();

  @override
  List<Object> get props => [];
}

class StopTrackingEvent extends MapTrackingEvent {}
class StartTrackingEvent extends MapTrackingEvent {}
class ResetRouteEvent extends MapTrackingEvent {}

class LocationUpdateEvent extends MapTrackingEvent {
  final UserLocation location;

  const LocationUpdateEvent(this.location);

  @override
  List<Object> get props => [location];
}

class TrackingStatsUpdateEvent extends MapTrackingEvent {
  final double totalDistance;
  final int routePointsCount;
  final List<AlarmModel> alarms;

  const TrackingStatsUpdateEvent({
    required this.totalDistance,
    required this.routePointsCount,
    required this.alarms,
  });

  @override
  List<Object> get props => [totalDistance, routePointsCount, alarms];
}

class AddAlarmEvent extends MapTrackingEvent {
  final AlarmModel alarm;

  const AddAlarmEvent(this.alarm);

  @override
  List<Object> get props => [alarm];
}

class RemoveAlarmEvent extends MapTrackingEvent {
  final String alarmId;

  const RemoveAlarmEvent(this.alarmId);

  @override
  List<Object> get props => [alarmId];
}

class AlarmFiredEvent extends MapTrackingEvent {
  final AlarmModel alarm;

  const AlarmFiredEvent(this.alarm);

  @override
  List<Object> get props => [alarm];
}
