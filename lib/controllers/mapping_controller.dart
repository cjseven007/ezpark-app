import 'dart:async';
import 'package:ezpark/models/parking_area.dart';
// import 'package:ezpark/services/location_search_service.dart';
import 'package:ezpark/services/location_service.dart';
import 'package:ezpark/services/parking_area_service.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class MappingController extends GetxController {
  final _locationService = LocationService();
  final _areaService = ParkingAreaService();
  // final _locationSearchService = LocationSearchService();

  final userLocation = Rxn<LatLng>();
  final searchLocation = Rxn<LatLng>();
  final currentCenter = Rxn<LatLng>();

  final isLoading = true.obs;
  final isSearching = false.obs;
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
      final current = LatLng(pos.latitude, pos.longitude);

      userLocation.value = current;
      currentCenter.value = current;

      _subscribeAreasAround(current);
    } finally {
      isLoading.value = false;
    }
  }

  void _subscribeAreasAround(LatLng center) {
    _sub?.cancel();
    _sub = _areaService
        .subscribeAreasWithinRadiusInKm(
          lat: center.latitude,
          lng: center.longitude,
          radiusInKm: 1.0,
        )
        .listen((docs) {
          areas.value = docs.map((d) => ParkingArea.fromDoc(d)).toList();
        });
  }

  void resetToUserLocation() {
    if (userLocation.value != null) {
      searchLocation.value = null;
      currentCenter.value = userLocation.value;
      _subscribeAreasAround(userLocation.value!);
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
