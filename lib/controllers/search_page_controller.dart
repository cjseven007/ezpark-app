import 'dart:async';
import 'package:ezpark/models/location_search_result.dart';
import 'package:ezpark/models/parking_area.dart';
import 'package:ezpark/services/location_search_service.dart';
import 'package:ezpark/services/parking_area_service.dart';
import 'package:get/get.dart';

class SearchPageController extends GetxController {
  final _locationSearchService = LocationSearchService();
  final _parkingAreaService = ParkingAreaService();

  final query = ''.obs;
  final isSearching = false.obs;
  final hasSearched = false.obs;
  final results = <LocationSearchResult>[].obs;

  final selectedLocation = Rxn<LocationSearchResult>();
  final nearbyAreas = <ParkingArea>[].obs;
  final isLoadingNearbyAreas = false.obs;

  StreamSubscription? _sub;
  Timer? _debounce;

  void onQueryChanged(String text) {
    query.value = text;

    _debounce?.cancel();

    if (text.trim().isEmpty) {
      hasSearched.value = false;
      isSearching.value = false;
      results.clear();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () async {
      await searchLocations(text);
    });
  }

  Future<void> searchLocations(String text) async {
    if (text.trim().isEmpty) {
      hasSearched.value = false;
      results.clear();
      return;
    }

    try {
      isSearching.value = true;
      hasSearched.value = true;
      final found = await _locationSearchService.searchLocations(text);
      results.assignAll(found);
    } catch (_) {
      results.clear();
    } finally {
      isSearching.value = false;
    }
  }

  void selectLocation(LocationSearchResult location) {
    selectedLocation.value = location;
    results.clear();
    _loadNearbyAreas(location);
  }

  void _loadNearbyAreas(LocationSearchResult location) {
    isLoadingNearbyAreas.value = true;
    nearbyAreas.clear();

    _sub?.cancel();
    _sub = _parkingAreaService
        .subscribeAreasWithinRadiusInKm(
          lat: location.latLng.latitude,
          lng: location.latLng.longitude,
          radiusInKm: 1.0,
        )
        .listen((docs) {
          nearbyAreas.assignAll(
            docs.map((d) => ParkingArea.fromDoc(d)).toList(),
          );
          isLoadingNearbyAreas.value = false;
        });
  }

  void clearSelectedLocation() {
    selectedLocation.value = null;
    nearbyAreas.clear();
    isLoadingNearbyAreas.value = false;
  }

  @override
  void onClose() {
    _debounce?.cancel();
    _sub?.cancel();
    super.onClose();
  }

  void resetSearch() {
    query.value = '';
    hasSearched.value = false;
    isSearching.value = false;
    results.clear();
  }
}
