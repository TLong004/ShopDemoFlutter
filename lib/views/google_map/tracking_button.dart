import 'dart:ui';

import 'package:flutter/material.dart';

class TrackingButton extends StatelessWidget {
  final bool isTracking;
  final bool isLoading;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onReset;

  const TrackingButton({
    required this.isTracking,
    required this.isLoading,
    required this.onStart,
    required this.onStop,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              print('TrackingButton pressed. isTracking: $isTracking');
              if (isTracking) {
                onStop();
              } else {
                onStart();
              }
            },
            icon: Icon(isTracking ? Icons.stop : Icons.play_arrow),
            label: Text(
              isTracking ? 'Dừng' : 'Bắt Đầu',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isTracking ? Colors.red : Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
          ),
        ),

        if (!isTracking) ...[
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.grey.shade700,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Icon(Icons.refresh),
          ),
        ],
      ],
    );
  }
}