import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class FavouriteParkingArea {
  final String parkingAreaId;
  final String name;
  final int availableCount;
  final int capacity;
  final double parkingFee;
  final LatLng latLng;
  final Timestamp? savedAt;

  FavouriteParkingArea({
    required this.parkingAreaId,
    required this.name,
    required this.availableCount,
    required this.capacity,
    required this.parkingFee,
    required this.latLng,
    required this.savedAt,
  });

  bool get isFree => parkingFee <= 0;

  String get parkingFeeLabel {
    if (isFree) return 'Free';
    return 'RM${parkingFee.toStringAsFixed(2)}';
  }

  factory FavouriteParkingArea.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return FavouriteParkingArea(
      parkingAreaId: (data['parkingAreaId'] ?? doc.id).toString(),
      name: (data['name'] ?? '').toString(),
      availableCount: (data['availableCount'] ?? 0) as int,
      capacity: (data['capacity'] ?? 0) as int,
      parkingFee: ((data['parkingFee'] ?? 0) as num).toDouble(),
      latLng: LatLng(
        ((data['lat'] ?? 0) as num).toDouble(),
        ((data['lng'] ?? 0) as num).toDouble(),
      ),
      savedAt: data['savedAt'] as Timestamp?,
    );
  }
}
