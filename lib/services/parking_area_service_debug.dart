import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingAreaServiceDebug {
  final _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> streamAllAreas() {
    return _db.collection('parking_areas').snapshots();
  }
}