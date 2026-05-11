import 'package:flutter/material.dart';

class StatsPanel extends StatelessWidget {
  final double totalDistance;
  final int routePointsCount;
  final bool isTracking;

  const StatsPanel({
    required this.totalDistance,
    required this.routePointsCount,
    required this.isTracking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            icon: Icons.route,
            value: '${(totalDistance / 1000).toStringAsFixed(2)}',
            unit: 'km',
            color: Colors.blue,
          ),
          Container(width: 1, height: 32, color: Colors.grey.shade200),
          _StatItem(
            icon: Icons.location_on,
            value: '$routePointsCount',
            unit: 'điểm',
            color: Colors.green,
          ),
          Container(width: 1, height: 32, color: Colors.grey.shade200),
          _StatItem(
            icon: Icons.circle,
            value: isTracking ? 'Đang chạy' : 'Dừng',
            unit: '',
            color: isTracking ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black),
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
              if (unit.isNotEmpty)
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
            ],
          ),
        ),
      ],
    );
  }
}