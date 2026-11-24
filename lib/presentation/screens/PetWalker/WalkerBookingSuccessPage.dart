import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/gen/fonts.gen.dart';

double getResponsiveFont(BuildContext context, double size) {
  double screenWidth = MediaQuery.of(context).size.width;

  if (screenWidth < 360) {
    return size * 0.85;
  } else if (screenWidth < 400) {
    return size;
  } else if (screenWidth < 600) {
    return size * 1.1;
  } else {
    return size * 1.3;
  }
}

class WalkerBookingSuccessPage extends StatelessWidget {
  const WalkerBookingSuccessPage({super.key});

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

          title: Text(
            "Booking Success",
            style: TextStyle(
              fontFamily: FontFamily.Cairo,
              fontWeight: FontWeight.w600,
              color: Colours.brownColour,
              fontSize: getResponsiveFont(context, 18),
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
                  color: Colors.green.withOpacity(.1),
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
                "Booking Confirmed",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: FontFamily.Cairo,
                  fontWeight: FontWeight.bold,
                  color: Colours.brownColour,
                  fontSize:
                      getResponsiveFont(context, 24),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Your pet walk has been successfully booked.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: FontFamily.Cairo,
                  color: Colours.brownColour,
                  fontSize:
                      getResponsiveFont(context, 14),
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
                      "#PW1024",
                    ),

                    buildRow(
                      "Walker",
                      "John Walker",
                    ),

                    buildRow(
                      "Pet",
                      "Bruno",
                    ),

                    buildRow(
                      "Date",
                      "05 Oct 2026",
                    ),

                    buildRow(
                      "Time",
                      "09:00 AM",
                    ),

                    buildRow(
                      "Duration",
                      "60 Minutes",
                    ),

                    const Divider(height: 30),

                    buildRow(
                      "Amount Paid",
                      "₹299",
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
                  child: Text(
                    "Go To Home",
                    style: TextStyle(
                      fontFamily: FontFamily.Cairo,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize:
                          getResponsiveFont(
                              context, 16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextButton(
                onPressed: () {

                  /// Future:
                  /// Booking Details Page

                },
                child: Text(
                  "View Booking Details",
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