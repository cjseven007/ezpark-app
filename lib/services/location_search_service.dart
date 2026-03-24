import 'dart:convert';
import 'package:ezpark/models/location_search_result.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LocationSearchService {
  static const _baseUrl = 'photon.komoot.io';

  Future<List<LocationSearchResult>> searchLocations(String query) async {
    if (query.trim().isEmpty) return [];

    // Bias results around Malaysia / Perak area
    final uri = Uri.https(_baseUrl, '/api', {
      'q': query.trim(),
      'limit': '8',
      'lat': '4.3850',
      'lon': '100.9790',
      'lang': 'en',
    });

    final response = await http.get(
      uri,
      headers: {'User-Agent': 'ezpark-app/1.0', 'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      return [];
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final features = (body['features'] as List?) ?? [];

    return features.map((feature) {
      final props = Map<String, dynamic>.from(feature['properties'] ?? {});
      final geometry = Map<String, dynamic>.from(feature['geometry'] ?? {});
      final coordinates = (geometry['coordinates'] as List?) ?? [0, 0];

      final lon = (coordinates[0] as num).toDouble();
      final lat = (coordinates[1] as num).toDouble();

      final name =
          (props['name'] ??
                  props['street'] ??
                  props['city'] ??
                  props['state'] ??
                  'Unknown place')
              .toString();

      final addressParts = <String>[
        if (props['street'] != null) props['street'].toString(),
        if (props['district'] != null) props['district'].toString(),
        if (props['city'] != null) props['city'].toString(),
        if (props['state'] != null) props['state'].toString(),
        if (props['country'] != null) props['country'].toString(),
      ];

      return LocationSearchResult(
        name: name,
        address: addressParts.isEmpty ? name : addressParts.join(', '),
        latLng: LatLng(lat, lon),
      );
    }).toList();
  }
}
