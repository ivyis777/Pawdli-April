import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/presentation/widgets/bottom%20bar/bottombar.dart';

class GoodByeBuddyController extends GetxController {
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  Future<void> uploadGoodByeBuddyData({
    required String location,
    double? latitude,   
    double? longitude,   
    required String landmark,
    required String description,
    required List<File> imageFiles,
  }) async {
    // ================= DEBUG START =================
    print("========== GOODBYE BUDDY UPLOAD ==========");
    print("📍 Location        : $location");
    print("📍 Latitude        : $latitude");
    print("📍 Longitude       : $longitude");
    print("🏷️ Landmark        : $landmark");
    print("📝 Description     : $description");
    print("🖼️ Images count    : ${imageFiles.length}");
    for (int i = 0; i < imageFiles.length; i++) {
      print("   Image[$i] path : ${imageFiles[i].path}");
    }
    print("==========================================");
    // ================= DEBUG END ===================

    isLoading.value = true;
    errorMessage.value = '';

    try {
      bool success = await ApiService.uploadGoodByeBuddy(
        location: location,
        latitude: latitude,      // ✅ ADD
        longitude: longitude,    
        landmark: landmark,
        description: description,
        imageFiles: imageFiles,
      );

      print("✅ API RESPONSE SUCCESS: $success");

     if (success) {
  // 🔹 Stop loader
  isLoading.value = false;

  // 🔹 Show success popup
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colours.primarycolour,
              width: 1.5,
            ),
          ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/images/ThankYou.png",
                height: 150,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 10),

              // const Text(
              //   "Thank You 🙏",
              //   style: TextStyle(
              //     fontSize: 22,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),

              // const SizedBox(height: 10),

              const Text(
                "Thanks for your concern.\nOur team will reach out soon.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colours.primarycolour,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Get.back();
                    Get.offAll(() => MainLayout());
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  });
} else {
  errorMessage.value = "Failed to upload data.";
}

    } catch (e, st) {
      errorMessage.value = e.toString();
      print("❌ EXCEPTION OCCURRED:");
      print(e);
      print(st);
    } finally {
      isLoading.value = false;
      print("🔁 Loading stopped");
    }
  }
}

