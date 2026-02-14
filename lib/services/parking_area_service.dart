import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class ParkingAreaService {
  final _db = FirebaseFirestore.instance;

  Stream<List<DocumentSnapshot>> subscribeAreasWithinRadiusInKm({
    required double lat,
    required double lng,
    required double radiusInKm,
  }) {
    final center = GeoFirePoint(GeoPoint(lat, lng));
    final ref = GeoCollectionReference(_db.collection('parking_areas'));

    return ref.subscribeWithin(
      center: center,
      radiusInKm: radiusInKm,
      field: 'geo',
      geopointFrom: (data) =>
          (data['geo'] as Map<String, dynamic>)['geopoint'] as GeoPoint,
    );
  }
}
