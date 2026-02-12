import 'package:ezpark/controllers/mapping_controller.dart';
import 'package:ezpark/utils/constants.dart';
import 'package:ezpark/views/widgets/slot_layout_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MappingController());

    return Obx(() {
      if (c.isLoading.value) return const Center(child: CircularProgressIndicator());

      final user = c.userLocation.value;
      final center = user ?? const LatLng(4.2105, 101.9758);

      final markers = <Marker>[
        if (user != null)
          Marker(
            point: user,
            width: 40,
            height: 40,
            child: const Icon(Icons.location_on_rounded, size: 40, color: Colors.blue),
          ),
        ...c.areas.map((area) {
          final color = area.hasAvailability ? Colors.green : Colors.red;
          return Marker(
            point: area.latLng,
            width: 52,
            height: 52,
            child: GestureDetector(
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
              child: Icon(Icons.local_parking_rounded, size: 40, color: color),
            ),
          );
        }),
      ];

      return FlutterMap(
        options: MapOptions(initialCenter: center, initialZoom: 16),
        children: [
          TileLayer(
            urlTemplate: AppConstants().openstreetmapUrlTemplate,
            userAgentPackageName: 'com.example.ezpark',
          ),
          MarkerLayer(markers: markers),
        ],
      );
    });
  }
}
