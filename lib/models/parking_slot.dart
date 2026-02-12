import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingSlot {
  final String id;
  final String label;
  final bool isAvailable;
  final double x, y, w, h;

  ParkingSlot({
    required this.id,
    required this.label,
    required this.isAvailable,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });

  factory ParkingSlot.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final bbox = data['bbox'] as Map<String, dynamic>;

    return ParkingSlot(
      id: doc.id,
      label: (data['label'] ?? doc.id).toString(),
      isAvailable: (data['isAvailable'] ?? false) as bool,
      x: (bbox['x'] as num).toDouble(),
      y: (bbox['y'] as num).toDouble(),
      w: (bbox['w'] as num).toDouble(),
      h: (bbox['h'] as num).toDouble(),
    );
  }
}
