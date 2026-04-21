import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/meet%20a%20vet/meetvetdoctor.dart';
import 'package:pawlli/presentation/screens/meet%20a%20vet/quick_appointment.dart/petdetailspage.dart';

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

class AppointmentPage extends StatelessWidget {
  const AppointmentPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colours.secondarycolour,
      body: Stack(
        children: [
          Container(
            width: screenWidth * 0.55,
            height: screenHeight * 0.10,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    'https://pawlli-podcasts.s3.ap-south-1.amazonaws.com/static_images/topimage.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              // AppBar
              AppBar(
                title: Text(
                  'Appointment Mode'.tr,
                  style: TextStyle(
                    fontSize: getResponsiveFont(context, 18),
                    fontWeight: FontWeight.w600,
                    fontFamily: FontFamily.Cairo,
                    color: Colours.brownColour,
                  ),
                ),
                foregroundColor: Colours.brownColour,
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),

              const SizedBox(height: 100),

              // Buttons in column
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colours.primarycolour,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PetDetailsPage(),
                            ),
                          );
                        },
                        child: Text(
                          "Quick Appointment".tr,
                          style: TextStyle(
                            fontSize: getResponsiveFont(context, 16),
                            fontWeight: FontWeight.bold,
                            fontFamily: FontFamily.Cairo,
                            color: Colours.secondarycolour,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colours.brownColour,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MeetVetDoctorList(),
                            ),
                          );
                        },
                        child: Text(
                          "Schedule Appointment".tr,
                          style: TextStyle(
                            fontSize: screenHeight * 0.022,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontFamily.Cairo,
                            color: Colours.secondarycolour,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
