import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class FirestoreSeeder {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static Future<void> seedDemoParkingArea() async {
    print("Seeding demo parking area...");

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Create geo data using geoflutterfire_plus
    final geo = GeoFirePoint(
      GeoPoint(pos.latitude, pos.longitude),
    );

    final areaRef =
        await _firestore.collection('parking_areas').add({
      "name": "EZPark Demo Lot",
      "geo": geo.data, // contains {geopoint, geohash}
      "capacity": 20,
      "availableCount": 0,
      "layout": {
        "imageWidth": 1920,
        "imageHeight": 1080,
      }
    });

    await _generateSlots(areaRef.id);

    print("Demo data seeded.");
  }

  static Future<void> _generateSlots(String areaId) async {
    final slotsRef = _firestore
        .collection('parking_areas')
        .doc(areaId)
        .collection('slots');

    const rows = 4;
    const cols = 5;

    const startX = 200.0;
    const startY = 150.0;
    const slotWidth = 200.0;
    const slotHeight = 350.0;
    const spacingX = 250.0;
    const spacingY = 400.0;

    final rand = Random();
    int counter = 1;
    int availableCount = 0;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final x = startX + (c * spacingX);
        final y = startY + (r * spacingY);

        final isAvailable = rand.nextBool();
        if (isAvailable) availableCount++;

        await slotsRef.add({
          "label": "A$counter",
          "bbox": {
            "x": x,
            "y": y,
            "w": slotWidth,
            "h": slotHeight,
          },
          "isAvailable": isAvailable,
          "confidence": rand.nextDouble(),
        });

        counter++;
      }
    }

    await _firestore
        .collection('parking_areas')
        .doc(areaId)
        .update({
      "availableCount": availableCount,
    });
  }
}
