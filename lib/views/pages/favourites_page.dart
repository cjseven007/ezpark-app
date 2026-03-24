import 'package:ezpark/models/favourite_parking_area.dart';
import 'package:ezpark/models/parking_area.dart';
import 'package:ezpark/services/favourite_service.dart';
import 'package:ezpark/services/parking_area_service.dart';
import 'package:ezpark/utils/my_colours.dart';
import 'package:ezpark/views/widgets/slot_layout_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavouritesPage extends StatelessWidget {
  const FavouritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favouriteService = FavouriteService();
    final parkingAreaService = ParkingAreaService();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              'Favourite Parkings',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: favouriteService.streamFavourites(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                final favourites = docs
                    .map((doc) => FavouriteParkingArea.fromDoc(doc))
                    .toList();

                if (favourites.isEmpty) {
                  return const Center(
                    child: Text(
                      'No favourite parking areas yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  itemCount: favourites.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final fav = favourites[index];

                    return StreamBuilder(
                      stream: parkingAreaService.streamAreaById(
                        fav.parkingAreaId,
                      ),
                      builder: (context, areaSnapshot) {
                        ParkingArea? area;

                        if (areaSnapshot.hasData && areaSnapshot.data!.exists) {
                          area = ParkingArea.fromDoc(areaSnapshot.data!);
                        }

                        final displayName = area?.name ?? fav.name;
                        final availableCount =
                            area?.availableCount ?? fav.availableCount;
                        final capacity = area?.capacity ?? fav.capacity;
                        final parkingFeeLabel =
                            area?.parkingFeeLabel ?? fav.parkingFeeLabel;

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: MyColours.primary,
                              child: Icon(
                                availableCount > 0
                                    ? Icons.local_parking_rounded
                                    : Icons.local_parking_outlined,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$availableCount/$capacity available'),
                                  const SizedBox(height: 2),
                                  Text('Parking Fee: $parkingFeeLabel'),
                                ],
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: area == null
                                ? null
                                : () {
                                    Get.bottomSheet(
                                      SlotLayoutSheet(area: area!),
                                      isScrollControlled: true,
                                      backgroundColor: Colors.white,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(18),
                                        ),
                                      ),
                                    );
                                  },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
