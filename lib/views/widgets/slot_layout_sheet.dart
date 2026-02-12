import 'package:ezpark/models/parking_area.dart';
import 'package:ezpark/models/parking_slot.dart';
import 'package:ezpark/services/slot_service.dart';
import 'package:ezpark/views/widgets/slot_layout_painter.dart';
import 'package:flutter/material.dart';

class SlotLayoutSheet extends StatelessWidget {
  final ParkingArea area;
  SlotLayoutSheet({super.key, required this.area});

  final _slotService = SlotService();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(width: 44, height: 5, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(999))),
          const SizedBox(height: 12),
          ListTile(
            title: Text(area.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${area.availableCount}/${area.capacity} available'),
          ),
          const SizedBox(height: 8),

          // White canvas with painter
          AspectRatio(
            aspectRatio: area.imageWidth / area.imageHeight,
            child: StreamBuilder(
              stream: _slotService.streamSlots(area.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                final slots = docs.map((d) => ParkingSlot.fromDoc(d)).toList();

                return Container(
                  color: Colors.white,
                  child: SizedBox.expand(
                    child: CustomPaint(
                      painter: SlotLayoutPainter(
                        slots: slots,
                        imageWidth: area.imageWidth.toDouble(),
                        imageHeight: area.imageHeight.toDouble(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
