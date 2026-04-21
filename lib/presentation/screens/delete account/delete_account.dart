import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/presentation/screens/loginpage/loginpage.dart';

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

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool otpSent = false;

  void _sendOtp() {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      Get.snackbar("Error", "Please enter a valid email".tr,
          backgroundColor: Colours.primarycolour);
      return;
    }

    setState(() {
      otpSent = true;
    });

    Get.snackbar("OTP Sent", "An OTP has been sent to your email".tr,
        backgroundColor: Colours.primarycolour);
  }

  void _confirmDelete(BuildContext context) {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      Get.snackbar("Error", "Please enter a valid email".tr,
          backgroundColor: Colours.primarycolour);
      return;
    }

    if (otp.isEmpty) {
      Get.snackbar("Error", "Please enter OTP".tr,
          backgroundColor: Colours.primarycolour);
      return;
    }

    if (email == "reviewer@example.com" && otp == "1234") {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title:  Text(
            "Confirm Deletion".tr,
            style: TextStyle(
              fontSize: getResponsiveFont(context, 16),
              fontWeight: FontWeight.bold,
            ),
          ),
          content:  Text(
              "Are you sure you want to delete your account? This action is irreversible.".tr, 
              style: TextStyle(
                fontSize: getResponsiveFont(context, 14),
              ),
            ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:  Text(
                "Cancel".tr,
                style: TextStyle(
                  fontSize: getResponsiveFont(context, 14),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colours.primarycolour),
              onPressed: () {
                Navigator.pop(context);
                _deleteAccount();
              },
              child: Text(
                "Delete".tr,
                style: TextStyle(
                  fontSize: getResponsiveFont(context, 14),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      Get.snackbar("Invalid", "Invalid email or OTP".tr,
          backgroundColor: Colours.primarycolour);
    }
  }

  void _deleteAccount() {
    final box = GetStorage();
    const deletedEmail = 'reviewer@example.com';

    // Save that the reviewer account is deleted
    box.write('deleted_user_email', deletedEmail);

    Get.snackbar(
      "Deleted".tr,
      "Your account has been deleted.".tr,
      backgroundColor: Colours.primarycolour,
    );

    // Redirect to login page
    Get.offAll(() => const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colours.secondarycolour,
      body: Stack(
        children: [
          // Top image banner
          Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: screenWidth * 0.55,
                height: screenHeight * 0.10,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://pawlli-podcasts.s3.ap-south-1.amazonaws.com/static_images/topimage.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              )),

          // Main content
          Column(
            children: [
              AppBar(
                title: Text(
                  'Delete Account'.tr,
                  style: TextStyle(
                    fontSize: getResponsiveFont(context, 18),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                    color: Colors.brown,
                  ),
                ),
                foregroundColor: Colors.brown,
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Icon(Icons.delete_forever,
                            size: 80, color: Colors.red),
                        const SizedBox(height: 16),
                         Text(
                          "Delete Your Account".tr,
                          style: TextStyle(
                              fontSize: getResponsiveFont(context, 18), fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                         Text(
                          "Enter your email and OTP to confirm deletion.".tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: getResponsiveFont(context, 14),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Email Field
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                            fontSize: getResponsiveFont(context, 14),
                          ),
                          decoration: InputDecoration(
                            labelText: "Email".tr,
                            labelStyle: TextStyle(
                              fontSize: getResponsiveFont(context, 13),
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // OTP Field
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            fontSize: getResponsiveFont(context, 14),
                          ),
                          decoration: InputDecoration(
                            labelText: "Enter OTP".tr,
                            labelStyle: TextStyle(
                              fontSize: getResponsiveFont(context, 13),
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Send OTP Button
                        ElevatedButton(
                          onPressed: _sendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colours.primarycolour,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text(
                            "Send OTP".tr,
                            style: TextStyle(
                                color: Colours.brownColour, fontSize: getResponsiveFont(context, 15)),

                          ),
                        ),
                        const SizedBox(height: 30),

                        // Delete Button
                        ElevatedButton(
                          onPressed: () => _confirmDelete(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colours.primarycolour,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text(
                            "Delete Account".tr,
                            style: TextStyle(
                                color: Colours.brownColour, fontSize: getResponsiveFont(context, 15),),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
