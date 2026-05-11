import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shopdemo/models/alarm_model.dart';
import 'package:shopdemo/models/user_location.dart';
import 'package:shopdemo/services/bloc/map_tracking_bloc.dart';
import 'package:shopdemo/views/google_map/alarm_list_panel.dart';
import 'package:shopdemo/views/google_map/stats_panel.dart';
import 'package:shopdemo/views/google_map/tracking_button.dart';

class MapTrackingScreen extends StatelessWidget {
  const MapTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapTrackingBloc(),
      child: const _MapTrackingView(),
    );
  }
}

class _MapTrackingView extends StatefulWidget {
  const _MapTrackingView();

  @override
  State<_MapTrackingView> createState() => __MapTrackingViewState();
}

class __MapTrackingViewState extends State<_MapTrackingView> {
  GoogleMapController? _mapController;
  bool _showAlarmList = false;
  bool _hasInitialZoom = false; 

  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(21.0278, 105.8342),
    zoom: 15,
  );

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _animateCamera(UserLocation location) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location.toLatLng(),
          zoom: 17,
        ),
      ),
    );
  }

  Future<void> _vibrate() async {
    await HapticFeedback.vibrate();
    await Future.delayed(const Duration(milliseconds: 300));
    await HapticFeedback.vibrate();
  }

  void _showAlarmDialog(BuildContext context, AlarmModel alarm) {
    _vibrate();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.notifications_active, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Đã đến nơi!'),
          ],
        ),
        content: Text(
          alarm.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showAddAlarmSheet(BuildContext context, LatLng position) {
    final titleController = TextEditingController(text: 'Điểm đến');
    final radiusController = TextEditingController(text: '200');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thêm Alarm',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Tên điểm đến',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: radiusController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Bán kính (mét)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.radar),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${position.latitude.toStringAsFixed(5)}, '
              '${position.longitude.toStringAsFixed(5)}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final alarm = AlarmModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text.trim().isEmpty
                        ? 'Điểm đến'
                        : titleController.text.trim(),
                    targetLocation: UserLocation(
                      latitude: position.latitude,
                      longitude: position.longitude,
                      timestamp: DateTime.now(),
                    ),
                    radius: double.tryParse(radiusController.text) ?? 200,
                  );
                  context.read<MapTrackingBloc>().add(AddAlarmEvent(alarm));
                  Navigator.pop(sheetContext);
                },
                icon: const Icon(Icons.add_location),
                label: const Text('Thêm Alarm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapTrackingBloc, MapTrackingState>(
      listener: (context, state) {
        debugPrint('=== STATE: $state ===');
        if (!_hasInitialZoom &&
            state is MapTrackingLoaded &&
            state.currentLocation != null) {
          _hasInitialZoom = true;
          _animateCamera(state.currentLocation!);
        }

        if (state is MapTrackingLoaded && state.firedAlarm != null) {
          _showAlarmDialog(context, state.firedAlarm!);
        }

        // Lỗi
        if (state is MapTrackingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final routePoints = switch (state) {
          MapTrackingLoaded s => s.routePoints,
          MapTrackingStopped s => s.routePoints,
          _ => <UserLocation>[],
        };
        final totalDistance = switch (state) {
          MapTrackingLoaded s => s.totalDistance,
          MapTrackingStopped s => s.totalDistance,
          _ => 0.0,
        };
        final activeAlarms = switch (state) {
          MapTrackingLoaded s => s.activeAlarms,
          MapTrackingStopped s => s.activeAlarms,
          _ => <AlarmModel>[],
        };
        final isTracking = state is MapTrackingLoaded;
        final isLoading = state is MapTrackingLoading;

        return Scaffold(
          body: Stack( 
            children: [

              GoogleMap(
                initialCameraPosition: _initialCamera,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                onMapCreated: (controller) => _mapController = controller,
                polylines: routePoints.length >= 2
                    ? {
                        Polyline(
                          polylineId: const PolylineId('route'),
                          points: routePoints.map((l) => l.toLatLng()).toList(),
                          color: Colors.blue,
                          width: 5,
                        ),
                      }
                    : {},
                markers: {
                  ...activeAlarms
                      .where((a) => a.targetLocation != null)
                      .map((alarm) => Marker(
                            markerId: MarkerId(alarm.id),
                            position: alarm.targetLocation!.toLatLng(),
                            infoWindow: InfoWindow(
                              title: alarm.title,
                              snippet: 'Bán kính: ${alarm.radius.toInt()}m',
                            ),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              alarm.isActive
                                  ? BitmapDescriptor.hueRed
                                  : BitmapDescriptor.hueGreen,
                            ),
                          )),
                },
                circles: {
                  ...activeAlarms
                      .where((a) => a.targetLocation != null && a.isActive)
                      .map((alarm) => Circle(
                            circleId: CircleId('circle_${alarm.id}'),
                            center: alarm.targetLocation!.toLatLng(),
                            radius: alarm.radius,
                            fillColor: Colors.blue.withOpacity(0.15),
                            strokeColor: Colors.blue,
                            strokeWidth: 2,
                          )),
                },
                onLongPress: (latLng) => _showAddAlarmSheet(context, latLng),
              ),

              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 16,
                right: 16,
                child: StatsPanel(
                  totalDistance: totalDistance,
                  routePointsCount: routePoints.length,
                  isTracking: isTracking,
                ),
              ),

              Positioned(
                right: 16,
                bottom: 180,
                child: FloatingActionButton.small(
                  heroTag: 'location',
                  backgroundColor: Colors.white,
                  onPressed: () {
                    final s = context.read<MapTrackingBloc>().state;
                    if (s is MapTrackingLoaded && s.currentLocation != null) {
                      _animateCamera(s.currentLocation!);
                    }
                  },
                  child: const Icon(Icons.my_location, color: Colors.blue),
                ),
              ),

              Positioned(
                right: 16,
                bottom: 240,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'alarms',
                      backgroundColor: Colors.white,
                      onPressed: () =>
                          setState(() => _showAlarmList = !_showAlarmList),
                      child: Icon(
                        Icons.notifications,
                        color: activeAlarms.any((a) => a.isActive)
                            ? Colors.orange
                            : Colors.grey,
                      ),
                    ),
                    if (activeAlarms.where((a) => a.isActive).isNotEmpty)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${activeAlarms.where((a) => a.isActive).length}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              if (_showAlarmList)
                Positioned(
                  right: 16,
                  bottom: 300,
                  child: AlarmListPanel(
                    alarms: activeAlarms,
                    onRemove: (id) => context
                        .read<MapTrackingBloc>()
                        .add(RemoveAlarmEvent(id)),
                  ),
                ),

              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 10,
                left: 24,
                right: 24,
                child: TrackingButton(
                  isTracking: isTracking,
                  isLoading: isLoading,
                  onStart: () => context
                      .read<MapTrackingBloc>()
                      .add(StartTrackingEvent()),
                  onStop: () => context
                      .read<MapTrackingBloc>()
                      .add(StopTrackingEvent()),
                  onReset: () => context
                      .read<MapTrackingBloc>()
                      .add(ResetRouteEvent()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}