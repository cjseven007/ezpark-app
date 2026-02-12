import 'package:cloud_firestore/cloud_firestore.dart';

class SlotService {
  final _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> streamSlots(String areaId) {
    return _db.collection('parking_areas').doc(areaId).collection('slots').snapshots();
  }
}