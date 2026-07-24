import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:intl/intl.dart';

import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/TherapyBookingController.dart';

import 'package:pawlli/data/model/TherapyBookingModel.dart';

class TherapyBookingDetailsPage extends StatefulWidget {

  final TherapyBookingData booking;

  const TherapyBookingDetailsPage({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  State<TherapyBookingDetailsPage> createState() =>
      _TherapyBookingDetailsPageState();
}

class _TherapyBookingDetailsPageState
    extends State<TherapyBookingDetailsPage> {

  final controller = Get.find<TherapyBookingController>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      // appBar: AppBar(

      //   backgroundColor: Colors.white,
      //   foregroundColor: Colours.brownColour,

      //   elevation: 0,

      //   iconTheme: IconThemeData(
      //     color: Colours.brownColour,
      //   ),

      //   title: Text(

      //     "Booked Details",

      //     style: TextStyle(
      //       color: Colours.brownColour,
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      //   actions: [

      //     PopupMenuButton<String>(

      //       onSelected: (value) async {

      //         if (value == "cancel") {

      //           final result = await showDialog<bool>(

      //             context: context,

      //             builder: (dialogContext) => AlertDialog(

      //               title: const Text("Cancel Booking"),

      //               content: const Text(
      //                 "Are you sure you want to cancel this booking?",
      //               ),

      //               actions: [

      //                 TextButton(

      //                   onPressed: () {
      //                     Navigator.pop(dialogContext, false);
      //                   },

      //                   child: const Text("No"),
      //                 ),

      //                 ElevatedButton(

      //                   onPressed: () {
      //                     print("STEP 1 : YES BUTTON CLICKED");
      //                     Navigator.pop(dialogContext, true);
      //                     print("STEP 2 : DIALOG CLOSED");

      //                   },

      //                   child: const Text("Yes"),
      //                 ),

      //               ],

      //             ),
      //           );
      //             print("STEP 3 : Dialog Result = $result");

      //           if (result == true) {
      //             print("STEP 4 : Calling Cancel API");
      //             final success =
      //                 await controller.updateBookingStatus(

      //               bookingId: widget.booking.bookingId!,

      //               status: "Cancelled",

      //             );
      //             print("STEP 5 : API Returned = $success");

      //             if (success) {
      //               print("STEP 6 : SUCCESS");

      //               await controller.fetchBookings();

      //               Get.snackbar(
      //                 "Success",
      //                 "Booking cancelled successfully.",
      //               );

      //               if (mounted) {
      //                 Navigator.pop(context, true);
      //               }
      //             } else {

      //               print("STEP 8 : FAILED");

      //               Get.snackbar(
      //                 "Error",
      //                 "Unable to cancel booking.",
      //               );

      //             }

      //           }

      //         }

      //       },

      //       itemBuilder: (context) {

      //         if (widget.booking.bookingStatus == "Cancelled") {
      //           return [];
      //         }

      //         return [

      //           const PopupMenuItem(
      //             value: "cancel",
      //             child: Text("Cancel Booking"),
      //           ),

      //         ];
      //       },
      //     ),
      //   ],
      // ),

      body: Column(
        children: [

          Stack(
            children: [

              Container(
                width: MediaQuery.of(context).size.width * 0.55,
                height: MediaQuery.of(context).size.height * 0.10,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      "https://app.pawdli.com/media/static/topimage.png",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                foregroundColor: Colours.brownColour,

                title: Text(
                  "Booked Details",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colours.brownColour,
                  ),
                ),

                actions: [

                  PopupMenuButton<String>(

                    onSelected: (value) async {

                      if (value == "cancel") {

                        final result = await showDialog<bool>(

                          context: context,

                          builder: (dialogContext) => AlertDialog(

                            title: const Text("Cancel Booking"),

                            content: const Text(
                              "Are you sure you want to cancel this booking?",
                            ),

                            actions: [

                              TextButton(

                                onPressed: () {
                                  Navigator.pop(dialogContext, false);
                                },

                                child: const Text("No"),
                              ),

                              ElevatedButton(

                                onPressed: () {
                                  print("STEP 1 : YES BUTTON CLICKED");
                                  Navigator.pop(dialogContext, true);
                                  print("STEP 2 : DIALOG CLOSED");

                                },

                                child: const Text("Yes"),
                              ),

                            ],

                          ),
                        );
                          print("STEP 3 : Dialog Result = $result");

                        if (result == true) {
                          print("STEP 4 : Calling Cancel API");
                          final success =
                              await controller.updateBookingStatus(

                            bookingId: widget.booking.bookingId!,

                            status: "Cancelled",

                          );
                          print("STEP 5 : API Returned = $success");

                          if (success) {
                            print("STEP 6 : SUCCESS");

                            await controller.fetchBookings();

                            Get.snackbar(
                              "Success",
                              "Booking cancelled successfully.",
                            );

                            if (mounted) {
                              Navigator.pop(context, true);
                            }
                          } else {

                            print("STEP 8 : FAILED");

                            Get.snackbar(
                              "Error",
                              "Unable to cancel booking.",
                            );

                          }

                        }

                      }

                    },

                    itemBuilder: (context) {

                      if (widget.booking.bookingStatus == "Cancelled") {
                        return [];
                      }

                      return const [

                        PopupMenuItem(
                          value: "cancel",
                          child: Text("Cancel Booking"),
                        ),

                      ];

                    },

                  ),

                ],
              ),

            ],
          ),

          Expanded(
            child: SingleChildScrollView(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            /// IMAGE
            Center(

              child: ClipRRect(

                borderRadius:
                    BorderRadius.circular(
                        16),

                child: widget.booking.therapyImage != null &&
                      widget.booking.therapyImage!.isNotEmpty
                  ? Image.network(
                      widget.booking.therapyImage!,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          height: 220,
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.pets,
                            size: 80,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )

                    : Container(

                        height: 220,

                        width: double.infinity,

                        decoration: BoxDecoration(

                          color: Colors.grey
                              .shade300,

                          borderRadius:
                              BorderRadius
                                  .circular(16),
                        ),

                        child: const Icon(
                          Icons.pets,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            /// THERAPY NAME
            Text(

              widget.booking.therapyName ?? "",

              style: const TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            buildDetailCard(
              "Booking ID",
              "${widget.booking.bookingId}",
            ),

            // buildDetailCard(
            //   "User ID",
            //   "${booking.userId}",
            // ),

            buildDetailCard(
              "User Name",
              widget.booking.userName ?? "",
            ),

            // buildDetailCard(
            //   "Pet Therapy ID",
            //   "${booking.pettherapyId}",
            // ),

            buildDetailCard(
              "Booking Date",

              widget.booking.bookingDate != null
                  ? DateFormat(
                      'dd-MM-yyyy',
                    ).format(
                      DateTime.parse(
                        widget.booking.bookingDate!,
                      ),
                    )
                  : "",
            ),

            buildDetailCard(
              "Booking Status",
              widget.booking.bookingStatus ?? "",
            ),

            buildDetailCard(
              "Location",
              widget.booking.location ?? "",
            ),

            buildDetailCard(
              "Landmark",
              widget.booking.landmark ?? "-",
            ),

            buildDetailCard(
              "Description",
              widget.booking.description ?? "",
            ),

            buildDetailCard(
              "Pet Age",
              widget.booking.petAge ?? "",
            ),

            buildDetailCard(
              "Pet Gender",
              widget.booking.petGender ?? "",
            ),

            buildDetailCard(
              "Vaccination",
              widget.booking.vaccinationStatus ?? "",
            ),

            buildDetailCard(
              "Specialization",
              widget.booking.petSpecialization ?? "",
            ),

            buildDetailCard(
              "Amount",
              widget.booking.amount ?? "",
            ),

            buildDetailCard(
              "Payment",
              widget.booking.isPaid == true ? "Paid" : "Pending",
            ),

            buildDetailCard(
              "Payment ID",
              widget.booking.paymentId ?? "",
            ),

            buildDetailCard(
              "Therapy Mode",
              widget.booking.mode ?? "-",
            ),

            buildDetailCard(
              "Therapy Type",
              widget.booking.therapyType ?? "-",
            ),

            buildDetailCard(
              "Created At",
              widget.booking.createdAt ?? "",
            ),
            

            const SizedBox(height: 25),

            const Text(

              "Booked Slots",

              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            if (widget.booking.slot != null)

            Container(

              margin: const EdgeInsets.only(bottom: 12),

              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius: BorderRadius.circular(14),

                boxShadow: const [

                  BoxShadow(

                    color: Colors.black12,

                    blurRadius: 4,

                  ),

                ],

              ),

              child: Row(

                children: [

                  CircleAvatar(

                    backgroundColor: Colours.primarycolour,

                    child: const Icon(

                      Icons.access_time,

                      color: Colors.white,

                    ),

                  ),

                  const SizedBox(width: 14),

                  Expanded(

                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        Text(

                          "Slot ID : ${widget.booking.slot!.slotId}",

                          style: const TextStyle(

                            fontWeight: FontWeight.bold,

                          ),

                        ),

                        const SizedBox(height: 4),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              "Date : ${widget.booking.slot!.date}",
                            ),

                            const SizedBox(height: 4),

                            Text(
                              "${widget.booking.slot!.startTime} - ${widget.booking.slot!.endTime}",
                            ),

                            if (widget.booking.slot!.amount != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  "Amount : ₹${widget.booking.slot!.amount}",
                                ),
                              ),

                            if (widget.booking.slot!.isBooked != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  "Booked : ${widget.booking.slot!.isBooked! ? "Yes" : "No"}",
                                ),
                              ),
                          ],
                        ),

                      ],

                    ),

                  ),

                ],

              ),

            )

          else

            const Text(

              "No Slots Available",

            ),
          ],
        ),
      ),
    ),

  ],
),

    );
  }

  Widget buildDetailCard(
    String title,
    String value,
  ) {

    return Container(

      margin:
          const EdgeInsets.only(
              bottom: 12),

      padding:
          const EdgeInsets.all(14),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(14),

        boxShadow: [

          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
          ),
        ],
      ),

      child: Row(

        children: [

          Expanded(

            flex: 2,

            child: Text(

              title,

              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          Expanded(

            flex: 3,

            child: Text(value),
          ),
        ],
    ),
  );
}
}