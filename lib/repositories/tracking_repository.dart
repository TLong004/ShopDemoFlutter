import 'package:shopdemo/models/alarm_model.dart';
import 'package:shopdemo/models/user_location.dart';

abstract class ITrackingRepository {
  UserLocation processNewLocation(UserLocation newLocation, List<UserLocation> history);

  List<AlarmModel> checkAlarms(UserLocation currentLocation, List<AlarmModel> alarms, Function(AlarmModel) onAlarmTriggered);

  double calculateTotalDistance(List<UserLocation> points);
}

class TrackingRepository implements ITrackingRepository {
  @override
  double calculateTotalDistance(List<UserLocation> points) {
    double total = 0;
    for (int i = 1; i < points.length; i++) {
      total += points[i].distanceTo(points[i - 1].latitude, points[i - 1].longitude);
    }
    return total;
  }

  @override
  List<AlarmModel> checkAlarms(UserLocation currentLocation, List<AlarmModel> alarms, Function(AlarmModel) onAlarmTriggered) {
    return alarms.map((alarm) {
      if (alarm.shouldTrigger(currentLocation) && alarm.isActive) {
        onAlarmTriggered(alarm);
        alarm = alarm.copyWith(isActive: false);
      }
      return alarm;
    }).toList();
  }

  @override
  UserLocation processNewLocation(UserLocation newLocation, List<UserLocation> history) {
    if (history.isNotEmpty) return newLocation;

    UserLocation lastLocation = history.last;

    double distance = newLocation.distanceTo(lastLocation.latitude, lastLocation.longitude);

    if (distance < 5) return lastLocation;

    return newLocation;
  }
}