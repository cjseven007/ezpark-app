import 'dart:async';
import 'package:ezpark/models/parking_area.dart';
import 'package:ezpark/services/location_service.dart';
import 'package:ezpark/services/parking_area_service.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class MappingController extends GetxController {
  final _locationService = LocationService();
  final _areaService = ParkingAreaService();

  final userLocation = Rxn<LatLng>();
  final isLoading = true.obs;
  final areas = <ParkingArea>[].obs;

  StreamSubscription? _sub;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    try {
      isLoading.value = true;

      final pos = await _locationService.getCurrentPosition();
      userLocation.value = LatLng(pos.latitude, pos.longitude);

      _sub?.cancel();
      _sub = _areaService
          .subscribeAreasWithinRadiusInKm(
            lat: pos.latitude,
            lng: pos.longitude,
            radiusInKm: 1.0,
          )
          .listen((docs) {
            areas.value = docs.map((d) => ParkingArea.fromDoc(d)).toList();
          });
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
