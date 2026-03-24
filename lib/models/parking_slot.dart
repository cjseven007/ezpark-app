import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpark/models/slot_point.dart';

class ParkingSlot {
  final String id;
  final String label;
  final bool isAvailable;
  final double x, y, w, h;
  final List<SlotPoint> points;

  ParkingSlot({
    required this.id,
    required this.label,
    required this.isAvailable,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    required this.points,
  });

  factory ParkingSlot.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final bbox = (data['bbox'] as Map<String, dynamic>?) ?? {};
    final rawPoints = (data['points'] as List?) ?? [];

    return ParkingSlot(
      id: doc.id,
      label: (data['label'] ?? doc.id).toString(),
      isAvailable: (data['isAvailable'] ?? false) as bool,
      x: ((bbox['x'] ?? 0) as num).toDouble(),
      y: ((bbox['y'] ?? 0) as num).toDouble(),
      w: ((bbox['w'] ?? 0) as num).toDouble(),
      h: ((bbox['h'] ?? 0) as num).toDouble(),
      points: rawPoints
          .map((p) => SlotPoint.fromMap(Map<String, dynamic>.from(p)))
          .toList(),
    );
  }
}
