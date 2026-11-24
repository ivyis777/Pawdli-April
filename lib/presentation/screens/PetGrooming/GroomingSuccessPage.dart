import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/gen/fonts.gen.dart';

class GroomingBookingSuccessPage extends StatelessWidget {
  const GroomingBookingSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colours.secondarycolour,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colours.brownColour,

          flexibleSpace: Stack(
            children: [
              SizedBox(
                width: 250,
                height: 100,
                child: Image.network(
                  "https://app.pawdli.com/media/static/topimage.png",
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),

          title: const Text(
            "Appointment Confirmed",
            style: TextStyle(
              fontFamily: FontFamily.Cairo,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              const Spacer(),

              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 90,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Text(
                "Appointment Booked Successfully!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: FontFamily.Cairo,
                  color: Colours.brownColour,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Your grooming appointment has been confirmed.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: FontFamily.Cairo,
                  color: Colours.brownColour,
                ),
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Column(
                  children: [

                    buildRow(
                      "Booking ID",
                      "#GR2026",
                    ),

                    buildRow(
                      "Salon",
                      "Paw Spa",
                    ),

                    buildRow(
                      "Pet",
                      "Bruno",
                    ),

                    buildRow(
                      "Service",
                      "Full Grooming",
                    ),

                    buildRow(
                      "Date",
                      "06 Oct 2026",
                    ),

                    buildRow(
                      "Time",
                      "10:00 AM",
                    ),

                    const Divider(height: 30),

                    buildRow(
                      "Amount Paid",
                      "₹799",
                      isAmount: true,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colours.primarycolour,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {

                    /// Example
                    /// Get.offAll(() => MainLayout());

                    Get.back();
                  },
                  child: const Text(
                    "Go To Home",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: FontFamily.Cairo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextButton(
                onPressed: () {

                  /// Future:
                  /// Navigate to Grooming Booking Details Page

                },
                child: Text(
                  "View Appointment Details",
                  style: TextStyle(
                    fontFamily: FontFamily.Cairo,
                    color:
                        Colours.primarycolour,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRow(
    String title,
    String value, {
    bool isAmount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: FontFamily.Cairo,
              ),
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontFamily: FontFamily.Cairo,
              fontWeight: FontWeight.bold,
              color: isAmount
                  ? Colors.green
                  : Colours.brownColour,
            ),
          ),
        ],
      ),
    );
  }
}