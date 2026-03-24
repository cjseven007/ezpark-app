import 'package:ezpark/controllers/landing_page_controller.dart';
import 'package:ezpark/controllers/mapping_controller.dart';
import 'package:ezpark/utils/constants.dart';
import 'package:ezpark/utils/my_colours.dart';
import 'package:ezpark/views/widgets/parking_marker.dart';
import 'package:ezpark/views/widgets/slot_layout_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

final GlobalKey<HomePageState> homePageKey = GlobalKey<HomePageState>();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final mapController = MapController();
  final MappingController c = Get.put(MappingController());

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

  void moveToUserLocation() {
    final user = c.userLocation.value;
    if (user != null) {
      _recenterVisually(user, 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final user = c.userLocation.value;
      final center = user ?? const LatLng(4.2105, 101.9758);

      _recenterVisually(center, 16);

      final markers = <Marker>[
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
              if (user != null) buildCircleLayer(user, 1000),
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
                        decoration: const BoxDecoration(
                          color: MyColours.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.search_rounded,
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
