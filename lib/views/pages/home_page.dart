import 'package:ezpark/controllers/landing_page_controller.dart';
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
  final searchController = TextEditingController();

  static const double headerHeight = 380.0;

  void _recenterVisually(LatLng center, double zoom) {
    final offset = Offset(
      0,
      (MediaQuery.of(context).size.height * 0.8 - headerHeight) / 2,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      mapController.move(center, zoom, offset: offset);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MappingController());

    return Obx(() {
      if (c.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final center =
          c.currentCenter.value ??
          c.userLocation.value ??
          const LatLng(4.2105, 101.9758);

      _recenterVisually(center, 16);

      final markers = <Marker>[
        if (c.searchLocation.value != null)
          Marker(
            point: c.searchLocation.value!,
            width: 44,
            height: 44,
            child: const Icon(Icons.location_pin, color: Colors.blue, size: 40),
          ),
        ...c.areas.map((area) {
          final color = area.hasAvailability ? Colors.green : Colors.red;
          return Marker(
            point: area.latLng,
            width: 52,
            height: 52,
            child: ParkingMarker(
              color: color,
              onTap: () => Get.bottomSheet(
                SlotLayoutSheet(area: area),
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
              if (c.userLocation.value != null)
                buildCircleLayer(c.userLocation.value!, 1000),
              if (c.searchLocation.value != null)
                buildCircleLayer(c.searchLocation.value!, 1000),
              MarkerLayer(markers: markers),
            ],
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: headerHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.6, 1.0],
                  colors: [
                    Colors.grey[200]!,
                    Colors.grey[100]!,
                    Colors.white10,
                  ],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Find Your Best Parking Spot Near You",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    readOnly: true,
                    onTap: () {
                      final landingController =
                          Get.find<LandingPageController>();
                      landingController.changeTabIndex(1);
                    },
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
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          c.resetToUserLocation();
                          if (c.userLocation.value != null) {
                            _recenterVisually(c.userLocation.value!, 16);
                          }
                        },
                        icon: const Icon(Icons.my_location),
                        label: const Text("My Location"),
                      ),
                    ],
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
