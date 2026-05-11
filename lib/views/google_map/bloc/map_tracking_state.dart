part of 'map_tracking_bloc.dart';

sealed class MapTrackingState extends Equatable {
  const MapTrackingState();

  @override
  List<Object?> get props => [];
}

final class MapTrackingInitial extends MapTrackingState {}

final class MapTrackingLoading extends MapTrackingState {}

final class MapTrackingLoaded extends MapTrackingState {
  final List<UserLocation> routePoints;
  final UserLocation? currentLocation;
  final double totalDistance;
  final List<AlarmModel> activeAlarms;
  final AlarmModel? firedAlarm;

  const MapTrackingLoaded({
    required this.routePoints,
    this.currentLocation,
    required this.totalDistance,
    this.activeAlarms = const [],
    this.firedAlarm,
  });

  @override
  List<Object?> get props => [routePoints, currentLocation, totalDistance, activeAlarms, firedAlarm];
}

final class MapTrackingStopped extends MapTrackingState {
  final List<UserLocation> routePoints;
  final double totalDistance;
  final List<AlarmModel> activeAlarms;
  final UserLocation? currentLocation;

  const MapTrackingStopped({
    required this.routePoints,
    required this.totalDistance,
    this.activeAlarms = const [],
    this.currentLocation,
  });

  @override
  List<Object?> get props => [routePoints, totalDistance, activeAlarms, currentLocation];
}

final class MapTrackingError extends MapTrackingState {
  final String message;

  const MapTrackingError(this.message);

  @override
  List<Object?> get props => [message];
}
