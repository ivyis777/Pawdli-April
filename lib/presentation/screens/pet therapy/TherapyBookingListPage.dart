import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/controller/TherapyBookingController.dart';
import 'package:pawlli/presentation/screens/pet%20therapy/TherapyBookingDetailsPage.dart';
import 'package:pawlli/presentation/screens/pet%20therapy/superuserdetailspage.dart';


class TherapyBookingListPage
    extends StatelessWidget {

  TherapyBookingListPage({super.key});

  final controller = Get.put(TherapyBookingController(), permanent: true);

  @override
  Widget build(BuildContext context) {

      return Column(
        children: [

          Expanded(

            child: Obx(() {

        if (controller.isLoading.value) {

          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        if (controller
            .bookingList.isEmpty) {

          return RefreshIndicator(
            color: Colours.primarycolour,
            onRefresh: () async {
              await controller.fetchBookings();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 250),
                Center(
                  child: Text("No Therapy Sessions"),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: Colours.primarycolour,
          onRefresh: () async {
            await controller.fetchBookings();
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: controller.bookingList.length,
            itemBuilder: (context, index) {
              final booking = controller.bookingList[index];

              return GestureDetector(
                onTap: () async {
                  final isSuperUser =
                      GetStorage().read(LocalStorageConstants.isSuperUser) ?? false;

                  if (isSuperUser) {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SuperTherapyBookingDetailsPage(
                          booking: controller.superBookingList[index],
                        ),
                      ),
                    );

                    if (result == true) {
                      controller.fetchBookings();
                    }
                  } else {
                    final result = await Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) => TherapyBookingDetailsPage(
                          booking: booking,
                        ),

                      ),

                    );

                    if (result == true) {
                      controller.fetchBookings();
                    }
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colours.primarycolour,
                      width: 0.5,
                    ),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colours.primarycolour,
                    //     blurRadius: 4,
                    //   ),
                    // ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: booking.therapyImage != null &&
                              booking.therapyImage!.isNotEmpty
                          ? Image.network(
                              booking.therapyImage!,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 80,
                                  width: 80,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.pets),
                                );
                              },
                            )
                          : Container(
                              height: 80,
                              width: 80,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.pets),
                            ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.therapyName ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text("Date : ${booking.bookingDate}"),
                            const SizedBox(height: 4),
                            Text("Status : ${booking.bookingStatus}"),
                            const SizedBox(height: 4),
                            if (booking.slot != null)
                              Text(
                                "${booking.slot!.startTime} - ${booking.slot!.endTime}",
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
            }),
    ),
  ],
);
}
}