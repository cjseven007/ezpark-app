import 'package:ezpark/models/parking_area.dart';
import 'package:ezpark/models/parking_slot.dart';
import 'package:ezpark/services/favourite_service.dart';
import 'package:ezpark/services/slot_service.dart';
import 'package:ezpark/utils/map_launcher.dart';
import 'package:ezpark/utils/my_colours.dart';
import 'package:ezpark/views/widgets/slot_layout_painter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SlotLayoutSheet extends StatelessWidget {
  final ParkingArea area;
  SlotLayoutSheet({super.key, required this.area});

  final _slotService = SlotService();
  final _favouriteService = FavouriteService();

  String _buildLastUpdatedText() {
    if (area.updatedAt == null) return 'Last updated: Unknown';
    final dt = area.updatedAt!.toDate();
    return 'Updated: ${DateFormat('dd/MMM/yy, h:mm a').format(dt)}';
  }

  Future<bool?> _showRemoveConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Remove favourite'),
          content: Text('Remove "${area.name}" from favourites?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      top: false,
      child: StreamBuilder(
        stream: _slotService.streamSlots(area.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 14,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          final docs = snapshot.data!.docs;
          final slots = docs.map((d) => ParkingSlot.fromDoc(d)).toList();

          final bounds = SlotLayoutPainter.computeContentBounds(slots);
          final contentAspectRatio = bounds.width / bounds.height;

          final horizontalPadding = 32.0;
          final availableCanvasWidth = screenWidth - horizontalPadding;
          final canvasHeight = availableCanvasWidth / contentAspectRatio;

          final totalHeight =
              26 +
              20 +
              24 +
              108 +
              8 +
              canvasHeight +
              12 +
              56 +
              MediaQuery.of(context).padding.bottom +
              16;

          final finalHeight = totalHeight.clamp(320.0, screenHeight * 0.88);

          return SizedBox(
            height: finalHeight,
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 14,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      area.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: area.hasAvailability
                                    ? Colors.green[100]
                                    : Colors.red[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  width: 1,
                                  color: area.hasAvailability
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              child: Text(
                                '${area.availableCount}/${area.capacity} available',
                              ),
                            ),
                            Text('Parking Fee: ${area.parkingFeeLabel}'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            _buildLastUpdatedText(),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: Colors.white,
                      child: CustomPaint(
                        painter: SlotLayoutPainter(
                          slots: slots,
                          imageWidth: area.imageWidth.toDouble(),
                          imageHeight: area.imageHeight.toDouble(),
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      StreamBuilder<bool>(
                        stream: _favouriteService.isFavourite(area.id),
                        builder: (context, favSnapshot) {
                          final isFavourite = favSnapshot.data ?? false;

                          return IconButton(
                            onPressed: () async {
                              if (isFavourite) {
                                final confirmed = await _showRemoveConfirmation(
                                  context,
                                );
                                if (confirmed == true) {
                                  await _favouriteService.removeFavourite(
                                    area.id,
                                  );
                                }
                              } else {
                                await _favouriteService.addFavourite(
                                  parkingAreaId: area.id,
                                  name: area.name,
                                  availableCount: area.availableCount,
                                  capacity: area.capacity,
                                  parkingFee: area.parkingFee,
                                  lat: area.latLng.latitude,
                                  lng: area.latLng.longitude,
                                );
                              }
                            },
                            icon: Icon(
                              isFavourite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: MyColours.primary,
                            ),
                            tooltip: isFavourite
                                ? 'Remove favourite'
                                : 'Add favourite',
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              await MapLauncher.openGoogleMapsNavigation(
                                destination: area.latLng,
                                label: area.name,
                              );
                            } catch (_) {
                              Get.snackbar(
                                'Navigation failed',
                                'Unable to open Google Maps',
                              );
                            }
                          },
                          icon: const Icon(Icons.navigation),
                          label: const Text('Navigate'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
