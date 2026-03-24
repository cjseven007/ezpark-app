import 'package:latlong2/latlong.dart';

class LocationSearchResult {
  final String name;
  final String address;
  final LatLng latLng;

  LocationSearchResult({
    required this.name,
    required this.address,
    required this.latLng,
  });
}
