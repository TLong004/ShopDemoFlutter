import 'package:flutter/material.dart';
import 'package:shopdemo/models/alarm_model.dart';

class AlarmListPanel extends StatelessWidget {
  final List<AlarmModel> alarms;
  final void Function(String id) onRemove;

  const AlarmListPanel({
    required this.alarms,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (alarms.isEmpty) {
      return Container(
        width: 220,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: const Text(
          'Chưa có alarm\nNhấn giữ bản đồ để thêm',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      );
    }

    return Container(
      width: 240,
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: alarms.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, index) {
          final alarm = alarms[index];
          return ListTile(
            dense: true,
            leading: Icon(
              alarm.isActive ? Icons.notifications_active : Icons.notifications_off,
              color: alarm.isActive ? Colors.orange : Colors.grey,
              size: 20,
            ),
            title: Text(
              alarm.title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${alarm.radius.toInt()}m',
              style: const TextStyle(fontSize: 11),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 16, color: Colors.red),
              onPressed: () => onRemove(alarm.id),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          );
        },
      ),
    );
  }
}