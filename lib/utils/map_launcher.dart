import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class MapLauncher {
  static Future<void> openGoogleMapsNavigation({
    required LatLng destination,
    required String label,
  }) async {
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${destination.latitude},${destination.longitude}',
    );

    if (!await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch Google Maps');
    }
  }
}
