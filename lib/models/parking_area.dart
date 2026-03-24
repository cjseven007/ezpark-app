import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class ParkingArea {
  final String id;
  final String name;
  final LatLng latLng;
  final int capacity;
  final int availableCount;
  final int imageWidth;
  final int imageHeight;
  final double parkingFee;
  final Timestamp? updatedAt;

  ParkingArea({
    required this.id,
    required this.name,
    required this.latLng,
    required this.capacity,
    required this.availableCount,
    required this.imageWidth,
    required this.imageHeight,
    required this.parkingFee,
    required this.updatedAt,
  });

  bool get hasAvailability => availableCount > 0;
  bool get isFree => parkingFee <= 0;

  String get parkingFeeLabel {
    if (isFree) return 'Free';
    return 'RM${parkingFee.toStringAsFixed(2)}';
  }

  factory ParkingArea.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final geo = data['geo'] as Map<String, dynamic>;
    final gp = geo['geopoint'] as GeoPoint;
    final layout = (data['layout'] as Map?) ?? {};

    return ParkingArea(
      id: doc.id,
      name: (data['name'] ?? doc.id).toString(),
      latLng: LatLng(gp.latitude, gp.longitude),
      capacity: (data['capacity'] ?? 0) as int,
      availableCount: (data['availableCount'] ?? 0) as int,
      imageWidth: (layout['imageWidth'] ?? 1920) as int,
      imageHeight: (layout['imageHeight'] ?? 1080) as int,
      parkingFee: ((data['parkingFee'] ?? 0) as num).toDouble(),
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }
}
