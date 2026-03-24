import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavouriteService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _favouritesRef {
    return _db.collection('users').doc(_uid).collection('favourites');
  }

  Stream<bool> isFavourite(String parkingAreaId) {
    return _favouritesRef
        .doc(parkingAreaId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  Future<void> addFavourite({
    required String parkingAreaId,
    required String name,
    required int availableCount,
    required int capacity,
    required double parkingFee,
    required double lat,
    required double lng,
  }) async {
    await _favouritesRef.doc(parkingAreaId).set({
      'parkingAreaId': parkingAreaId,
      'name': name,
      'availableCount': availableCount,
      'capacity': capacity,
      'parkingFee': parkingFee,
      'lat': lat,
      'lng': lng,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavourite(String parkingAreaId) async {
    await _favouritesRef.doc(parkingAreaId).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamFavourites() {
    return _favouritesRef.orderBy('savedAt', descending: true).snapshots();
  }
}
