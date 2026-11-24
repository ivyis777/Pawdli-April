import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/PetWalker/WalkerBookingPage.dart';

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

class WalkerDetailsPage extends StatelessWidget {
  const WalkerDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colours.secondarycolour,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
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
            "Walker Details",
            style: TextStyle(
              fontFamily: FontFamily.Cairo,
              fontSize: getResponsiveFont(context, 18),
              fontWeight: FontWeight.w600,
              color: Colours.brownColour,
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            CircleAvatar(
              radius: screenWidth * 0.18,
              backgroundImage: const NetworkImage(
                "https://images.unsplash.com/photo-1500648767791-00dcc994a43",
              ),
            ),

            const SizedBox(height: 15),

            Text(
              "Kumar",
              style: TextStyle(
                fontFamily: FontFamily.Cairo,
                fontWeight: FontWeight.bold,
                color: Colours.brownColour,
                fontSize: getResponsiveFont(context, 22),
              ),
            ),

            const SizedBox(height: 5),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.star,
                    color: Colors.amber, size: 20),
                SizedBox(width: 4),
                Text("4.8"),
              ],
            ),

            const SizedBox(height: 20),

            buildInfoCard(
              context,
              icon: Icons.work_outline,
              title: "Experience",
              value: "5 Years",
            ),

            buildInfoCard(
              context,
              icon: Icons.location_on_outlined,
              title: "Location",
              value: "Bangalore",
            ),

            buildInfoCard(
              context,
              icon: Icons.currency_rupee,
              title: "Price",
              value: "₹299 Per Walk",
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Services Offered",
                style: TextStyle(
                  fontFamily: FontFamily.Cairo,
                  fontWeight: FontWeight.bold,
                  color: Colours.brownColour,
                  fontSize: getResponsiveFont(context, 17),
                ),
              ),
            ),

            const SizedBox(height: 12),

            serviceTile("Daily Walk"),
            serviceTile("Exercise Walk"),
            serviceTile("Training Walk"),
            serviceTile("Senior Pet Walk"),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Available Timings",
                style: TextStyle(
                  fontFamily: FontFamily.Cairo,
                  fontWeight: FontWeight.bold,
                  color: Colours.brownColour,
                  fontSize: getResponsiveFont(context, 17),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                timeChip("09:00 AM"),
                timeChip("11:00 AM"),
                timeChip("04:00 PM"),
                timeChip("06:00 PM"),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colours.primarycolour,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  Get.to(() => WalkerBookingPage());
                },
                child: Text(
                  "Book Now",
                  style: TextStyle(
                    fontFamily: FontFamily.Cairo,
                    fontWeight: FontWeight.bold,
                    fontSize:
                        getResponsiveFont(context, 16),
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colours.primarycolour,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: FontFamily.Cairo,
                fontWeight: FontWeight.w600,
                color: Colours.brownColour,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: FontFamily.Cairo,
              fontWeight: FontWeight.bold,
              color: Colours.brownColour,
            ),
          ),
        ],
      ),
    );
  }

  Widget serviceTile(String service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colours.primarycolour,
          ),
          const SizedBox(width: 10),
          Text(
            service,
            style: const TextStyle(
              fontFamily: FontFamily.Cairo,
            ),
          ),
        ],
      ),
    );
  }

  Widget timeChip(String time) {
    return Chip(
      backgroundColor: Colours.primarycolour,
      label: Text(
        time,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: FontFamily.Cairo,
        ),
      ),
    );
  }
}