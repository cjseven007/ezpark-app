import 'package:ezpark/controllers/search_page_controller.dart';
import 'package:ezpark/views/widgets/parking_marker.dart';
import 'package:ezpark/views/widgets/slot_layout_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final controller = Get.put(SearchPageController());
  final mapController = MapController();
  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void _moveMap(LatLng center) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mapController.move(center, 16);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        final selected = controller.selectedLocation.value;

        if (selected == null) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: textController,
                  onChanged: controller.onQueryChanged,
                  decoration: InputDecoration(
                    hintText: 'Search location name...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: controller.isSearching.value
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : (textController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    textController.clear();
                                    controller.onQueryChanged('');
                                  },
                                  icon: const Icon(Icons.close),
                                )
                              : null),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (controller.isSearching.value &&
                        controller.results.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!controller.isSearching.value &&
                        controller.hasSearched.value &&
                        controller.results.isEmpty) {
                      return const Center(
                        child: Text(
                          'No locations found',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    if (controller.results.isEmpty) {
                      return const Center(
                        child: Text(
                          'Search for a place to view nearby parking',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: controller.results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = controller.results[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          leading: const Icon(Icons.location_on_outlined),
                          title: Text(item.name),
                          subtitle: Text(
                            item.address,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            controller.selectLocation(item);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }

        _moveMap(selected.latLng);

        final markers = <Marker>[
          Marker(
            point: selected.latLng,
            width: 44,
            height: 44,
            child: const Icon(Icons.location_pin, color: Colors.blue, size: 40),
          ),
          ...controller.nearbyAreas.map((area) {
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
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                ),
              ),
            );
          }),
        ];

        return Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          controller.clearSelectedLocation();
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Expanded(
                        child: Text(
                          selected.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: selected.latLng,
                      initialZoom: 16,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.ezpark',
                        maxZoom: 19,
                      ),
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: selected.latLng,
                            radius: 1000,
                            useRadiusInMeter: true,
                            color: Colors.blue.withValues(alpha: 0.10),
                            borderColor: Colors.blue.withValues(alpha: 0.22),
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),
                      MarkerLayer(markers: markers),
                    ],
                  ),
                ),
              ],
            ),

            if (controller.isLoadingNearbyAreas.value)
              const Center(child: CircularProgressIndicator()),

            if (!controller.isLoadingNearbyAreas.value &&
                controller.nearbyAreas.isEmpty)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      'No parking areas found within 1000m',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
