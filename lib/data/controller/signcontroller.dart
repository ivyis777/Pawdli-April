import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/presentation/widgets/bottom%20bar/bottombar.dart';

class SignupController extends GetxController {
  final box = GetStorage();
  var isLoading = false.obs;

  Future<void> getSignupUser({
    required String username,
    required String mobile,
    required String email,
    required String otp,
  }) async {
    try {
      isLoading.value = true;

      // 🔥 STEP 1: GET FCM TOKEN
      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
        print("🔥 FCM TOKEN: $fcmToken");
      } catch (e) {
        print("❌ FCM error: $e");
      }

      // 🔥 STEP 2: GET APNS TOKEN (RETRY)
      String? apnsToken;
      try {
        for (int i = 0; i < 5; i++) {
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken != null) break;
          await Future.delayed(const Duration(seconds: 1));
        }
        print("🍎 APNS TOKEN: $apnsToken");
      } catch (e) {
        print("❌ APNS error: $e");
      }

      // 🔥 STEP 3: CALL API
      final response = await ApiService.signupApi(
        username: username,
        mobile: mobile,
        email: email,
        otp: otp,
        fcm_token: fcmToken,
        apns_token: apnsToken,
      );

      print("📥 FINAL STATUS: ${response.status}");
      print("📥 FINAL MESSAGE: ${response.message}");

      // ✅ SUCCESS FLOW
      if (response.status == true &&
          response.data != null &&
          response.data!.tokens?.access != null) {

        box.write(LocalStorageConstants.sessionManager, true);
        box.write(LocalStorageConstants.access, response.data!.tokens!.access);
        box.write(LocalStorageConstants.refresh, response.data!.tokens!.refresh);
        box.write(LocalStorageConstants.userId, response.data!.userId);
        box.write(LocalStorageConstants.userEmail, response.data!.email);
        box.write(LocalStorageConstants.username, response.data!.username);
        box.write(LocalStorageConstants.name, response.data!.name ?? '');

        print("✅ Tokens saved");

        // 🔔 Subscribe topic
        Future.delayed(const Duration(seconds: 3), () async {
          try {
            String? apns = await FirebaseMessaging.instance.getAPNSToken();

            if (apns != null) {
              await FirebaseMessaging.instance.subscribeToTopic("all_users");
              print("✅ Topic subscribed AFTER APNS ready");
            } else {
              print("⚠️ APNS not ready → skipping topic subscription");
            }
          } catch (e) {
            print("❌ Topic error after delay: $e");
          }
        });

        await Future.delayed(const Duration(milliseconds: 300));
        Get.offAll(() => MainLayout());

      } else {
        print("❌ Signup failed: ${response.message}");
        Get.snackbar("Signup Failed", response.message ?? "Invalid OTP");
      }

    } catch (e) {
      print("❌ Signup error: $e");
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
