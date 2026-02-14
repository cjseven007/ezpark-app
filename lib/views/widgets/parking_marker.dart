import 'package:flutter/material.dart';

class ParkingMarker extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;
  const ParkingMarker({super.key, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.6),
        ),
        child: Icon(Icons.local_parking_rounded, size: 25, color: Colors.white),
      ),
    );
  }
}
