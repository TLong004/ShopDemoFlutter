import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  TimeOfDay selectTime = TimeOfDay.now();

  Future<void> _pickTimeAndSetAlarm() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: selectTime,
    );

    if (selectedTime != null) {
      final now = DateTime.now();
      var alarmDatetime = DateTime (
        now.year,
        now.month,
        now.day,
        selectedTime.hour,
        selectedTime.minute
      );
      if (alarmDatetime.isBefore(now)) {
        alarmDatetime = alarmDatetime.add(const Duration(days: 1));
      }
      final alarmSettings = AlarmSettings( 
        id: 42,
        dateTime: alarmDatetime,
        assetAudioPath: 'lib/assets/alarm.mp3',
        loopAudio: true,
        vibrate: true,
        androidFullScreenIntent: true,
        volumeSettings: VolumeSettings.fade(
          fadeDuration: Duration(seconds: 5),
          volume: 0.8,
          volumeEnforced: true,
        ),
        notificationSettings: const NotificationSettings(
          title: 'This is the title',
          body: 'This is the body',
          stopButton: 'Stop the alarm',
          icon: 'notification_icon',
          iconColor: Color(0xff862778),
        ),
      );
      await Alarm.set(alarmSettings: alarmSettings);
      setState(() {
        selectTime = selectedTime;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Báo thức đã đặt lúc: ${selectedTime.format(context)}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thiết lập báo thức")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Giờ đã chọn: ${selectTime.format(context)}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _pickTimeAndSetAlarm,
              icon: const Icon(Icons.access_time),
              label: const Text("Chọn giờ báo thức"),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Alarm.stop(100),
              child: const Text("Hủy báo thức", style: TextStyle(color: Colors.red)),
            )
          ],
        ),
      ),
    );
  }
}