import 'package:ezpark/controllers/mapping_controller.dart';
import 'package:ezpark/utils/constants.dart';
import 'package:ezpark/views/widgets/parking_marker.dart';
import 'package:ezpark/views/widgets/slot_layout_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final mapController = MapController();

  static const double headerHeight = 380.0;

  void _recenterVisually(LatLng center, double zoom) {
    // shift center UP by half the overlay height (so it appears centered in the visible area)
    final offset = Offset(
      0,
      (MediaQuery.of(context).size.height * 0.8 - headerHeight) / 2,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      mapController.move(center, zoom, offset: offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MappingController());

    return Obx(() {
      if (c.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final user = c.userLocation.value;
      final center = user ?? const LatLng(4.2105, 101.9758);

      _recenterVisually(center, 16);

      final markers = <Marker>[
        // if (user != null)
        //   Marker(
        //     point: user,
        //     width: 40,
        //     height: 40,
        //     child: const Icon(
        //       Icons.location_on_rounded,
        //       size: 40,
        //       color: Colors.blue,
        //     ),
        //   ),
        ...c.areas.map((area) {
          final color = area.hasAvailability ? Colors.green : Colors.red;
          return Marker(
            point: area.latLng,
            width: 52,
            height: 52,
            child: ParkingMarker(
              color: color,
              onTap: () => Get.bottomSheet(
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: SlotLayoutSheet(area: area),
                ),
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
              ),
            ),
          );
        }),
      ];

      return Stack(
        children: [
          // 1. The Map (Bottom Layer)
          FlutterMap(
            mapController: mapController,
            options: MapOptions(initialCenter: center, initialZoom: 16),
            children: [
              TileLayer(
                urlTemplate: AppConstants().openstreetmapUrlTemplate,
                userAgentPackageName: 'com.example.ezpark',
                maxZoom: 19,
              ),
              buildCurrentLocationMarker(),
              buildCircleLayer(user!, 1000),
              MarkerLayer(markers: markers),
            ],
          ),

          // 2. The Gradient & Search Container (Top Layer)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              // Adjust height to control how far the "fade" goes
              height: headerHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.6, 1.0],
                  colors: [
                    Colors.grey[200]!, // Solid-ish top
                    Colors.grey[100]!, // Fading
                    Colors.white10, // Fully transparent to show map
                  ],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(
                20,
                60,
                20,
                20,
              ), // Top padding for status bar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Find Your Best Parking Spot Near You",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  // Your Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search parking location...",
                      suffixIcon: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.search,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

Widget buildCurrentLocationMarker() {
  return CurrentLocationLayer(
    alignPositionOnUpdate: AlignOnUpdate.never,
    alignDirectionOnUpdate: AlignOnUpdate.never,
    style: LocationMarkerStyle(
      marker: const DefaultLocationMarker(
        child: Icon(Icons.navigation, color: Colors.white),
      ),
      markerSize: const Size(40, 40),
      markerDirection: MarkerDirection.heading,
    ),
  );
}

Widget buildCircleLayer(LatLng point, double radius) {
  return CircleLayer(
    circles: [
      CircleMarker(
        point: point,
        radius: radius,
        useRadiusInMeter: true,
        color: Colors.blue.withValues(alpha: 0.1),
        borderColor: Colors.blue.withValues(alpha: 0.15),
        borderStrokeWidth: 2,
      ),
    ],
  );
}
