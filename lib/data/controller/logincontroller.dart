import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/controller/DoctorconsultationController.dart';
import 'package:pawlli/data/controller/reelitemcontroller.dart';
import 'package:pawlli/data/model/AppleLoginModel.dart';
import 'package:pawlli/data/model/loginmodel.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:pawlli/presentation/screens/loginpage/AppleLoginPopUp.dart';
class LoginController extends GetxController {
  final box = GetStorage();
  var isLoading = false.obs;
  var isNavigating = false.obs;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final appleAvailable = SignInWithApple.isAvailable();

  Future<({bool success, String message})> loginWithOtp({
    required String email,
    required String otp,
  }) async {
    if (isLoading.value) {
      return (success: false, message: "Login already in progress".tr);
    }

    try {
      isLoading.value = true;
      final fcmToken = box.read('fcm_token') ?? "";
      final apnsToken = box.read('apns_token') ?? "";

      print("📤 Sending FCM Token: $fcmToken");
      print("📤 Sending APNs Token: $apnsToken");
            
      final response = await ApiService.loginAPI(
        email: email,
        otp: otp,
        through_google: false,
        fcm_token: fcmToken, 
        apns_token: apnsToken, 
      );
      print("LOGIN API RESPONSE: ${response.data}");

      if (response.status == true && response.data != null) {

        final user = response.data!;

        print("USER ID: ${user.userId}");
        print("EMAIL: ${user.email}");
        print("IS SUPER USER: ${user.isSuperuser}");
        print("IS STAFF: ${user.isStaff}");
        print("IS DOCTOR: ${user.isDoctor}");

        print("API isSuperuser: ${user.isSuperuser}");

        bool isSuper = user.isSuperuser == true;
        bool isDoctor = user.isDoctor == true;

        // ✅ DEBUG
        print("SAVED isSuperUser: $isSuper");
        print("SAVED isDoctor: $isDoctor");
        

        // ✅ SAVE SESSION
        box.remove(LocalStorageConstants.isSuperUser);
        box.write(LocalStorageConstants.sessionManager, true);
        box.write(LocalStorageConstants.userId, user.userId);
        box.write(LocalStorageConstants.userEmail, user.email);
        box.write(LocalStorageConstants.username, user.username ?? '');
        box.write(LocalStorageConstants.access, user.tokens?.access ?? '');
        box.write(LocalStorageConstants.refresh, user.tokens?.refresh ?? '');
        box.write(LocalStorageConstants.name, user.name ?? '');
        box.write(LocalStorageConstants.mobile, user.mobile ?? '');
        // box.write(LocalStorageConstants.isSuperUser, user.isSuperuser);
        box.write(LocalStorageConstants.isSuperUser, isSuper);
        box.write(LocalStorageConstants.isDoctor, isDoctor);
        box.write(LocalStorageConstants.isGuest, false);
        await restoreGuestCart();

        if (isDoctor) {
          Get.find<DoctorConsultationController>().startPolling();
        }

        // 🔔 ✅ SUBSCRIBE TO ALL USERS TOPIC
        try {
          await FirebaseMessaging.instance.subscribeToTopic("all_users");
          print("✅ Subscribed to topic: all_users");
        } catch (e) {
          print("❌ Topic subscription failed: $e");
        }

        // ✅ LOAD DATA AFTER LOGIN
        if (Get.isRegistered<ReelsController>()) {
          Get.find<ReelsController>().fetchReels();
        }

        return (
          success: true,
          message: response.message ?? 'Login successful'.tr,
        );
      }

      // ❌ API FAILED
      return (
        success: false,
        message: _handleLoginError(
          response.code ?? 'LOGIN_FAILED',
          serverMessage: response.message,
        ),
      );
    } catch (e) {
      return (
        success: false,
        message: _handleLoginError(
          'NETWORK_ERROR'.tr,
          serverMessage: e.toString(),
        ),
      );
    } finally {
      isLoading.value = false;
      isNavigating.value = false;
    }
  }

  /// ❌ ERROR HANDLING (LOGIC KEPT)
  String _handleLoginError(String code, {String? serverMessage}) {
    final msg = (serverMessage ?? '').toLowerCase();

    // ✅ PRIORITY: CHECK SERVER MESSAGE FIRST
    if (msg.contains('otp')) {
      return 'Entered wrong OTP.'.tr;
    }

    if (msg.contains('not registered') || msg.contains('not found')) {
      return 'This email is not registered. Please sign up first.'.tr;
    }

    if (msg.contains('invalid')) {
      return 'Invalid details.'.tr;
    }

    // ✅ FALLBACK USING CODE
    switch (code) {
      case "EMAIL_NOT_FOUND":
      case "404":
        return 'This email is not registered. Please sign up first.'.tr;

      case "402":
      case "INVALID_OTP":
      case "OTP_INVALID":
        return 'Entered wrong OTP.'.tr;

      case "403":
        return 'Invalid details.'.tr;

      case "500":
        return 'Server error. Please try again later.'.tr;

      case "NETWORK_ERROR":
        return 'Network error. Please check your connection.'.tr;

      default:
        return serverMessage ?? 'Login failed. Please try again.'.tr;
    }
  }
  // Google Login
    Future<({bool success, String message, bool isNewUser})> loginWithGoogle() async {

      try {

        isLoading.value = true;

        await _googleSignIn.signOut();

        final GoogleSignInAccount? googleUser =
            await _googleSignIn.signIn();

        if (googleUser == null) {
          return (
            success: false,
            message: "Google sign in cancelled",
            isNewUser: false,
          );
        }

        final response = await ApiService.googleLoginAPI(
          email: googleUser.email,
        );

        if (response.status == true && response.data != null) {

          final user = response.data!;
          final bool isNewUser = user.isNewUser ?? false;

          bool isSuper = user.isSuperuser == true;
          bool isDoctor = user.isDoctor == true;

          box.write(LocalStorageConstants.sessionManager, true);
          box.write(LocalStorageConstants.userId, user.userId);
          box.write(LocalStorageConstants.userEmail, user.email);
          box.write(LocalStorageConstants.username, user.username ?? "");
          box.write(LocalStorageConstants.name, user.name ?? "");
          box.write(LocalStorageConstants.mobile, user.mobile ?? '');
          box.write(LocalStorageConstants.access,user.tokens?.access ?? "");
          box.write(LocalStorageConstants.refresh,user.tokens?.refresh ?? "");
          box.write(LocalStorageConstants.isSuperUser,isSuper);
          box.write(LocalStorageConstants.isDoctor,isDoctor);
          box.write(LocalStorageConstants.isGuest, false);
          await restoreGuestCart();

          if (isDoctor) {
            Get.find<DoctorConsultationController>()
                .startPolling();
          }

          try {
            await FirebaseMessaging.instance.subscribeToTopic("all_users");
          } catch (_) {}

          if (Get.isRegistered<ReelsController>()) {
            Get.find<ReelsController>().fetchReels();
          }

          return (
            success: true,
            message:
                response.message ?? "Login Successful",
                isNewUser: isNewUser,

          );
        }

        return (
          success: false,
          message:
              response.message ?? "Google Login Failed",
              isNewUser: false,
        );

      } catch (e) {

        return (
          success: false,
          message: e.toString(),
          isNewUser: false,
        );

      } finally {
        isLoading.value = false;
      }
    }

    // Apple Login
    Future<({
      bool success,
      bool emailRequired,
      bool isNewUser,
      String message,
      String? identityToken,
    })> loginWithApple() async {

  try {

    final credential =
        await SignInWithApple
            .getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes
            .email,
        AppleIDAuthorizationScopes
            .fullName,
      ],
    );

    final identityToken =
        credential.identityToken;

    if (identityToken == null) {
      return (
        success: false,
        emailRequired: false,
        isNewUser: false,
        identityToken: null,
        message: "Apple token missing",
      );
    }

    dynamic response =
        await ApiService.appleLoginAPI(
      identityToken: identityToken,
    );

    if (response is AppleEmailRequiredModel) {

      return (
        success: false,
        emailRequired: true,
        isNewUser: false,
        identityToken: null,
        message: "Pawdli requires an email address to access our service, but the identity provider you signed in with did not provide one.",
      );
    }

    
      if (response is! LoginModel) {
        return (
          success: false,
          emailRequired: false,
          isNewUser: false,
          identityToken: identityToken,
          message: "Invalid response",
        );
      }

    /// LOGIN SUCCESS

    final LoginModel loginResponse =
        response;

    if (loginResponse.status ==
            true &&
        loginResponse.data != null) {

      final user =
          loginResponse.data!;

      box.write(
          LocalStorageConstants
              .sessionManager,
          true);

      box.write(
          LocalStorageConstants
              .userId,
          user.userId);

      box.write(
          LocalStorageConstants
              .userEmail,
          user.email);

      box.write(
          LocalStorageConstants
              .access,
          user.tokens
                  ?.access ??
              "");

      box.write(
          LocalStorageConstants
              .refresh,
          user.tokens
                  ?.refresh ??
              "");

      box.write(
        LocalStorageConstants.username,
        user.username ?? '',
      );

      box.write(
        LocalStorageConstants.name,
        user.name ?? '',
      );

      box.write(
        LocalStorageConstants.mobile,
        user.mobile ?? '',
      );
      
      box.write(LocalStorageConstants.isGuest, false);
      await restoreGuestCart();

      return (
        success: true,
        emailRequired: false,
        isNewUser: false,
        identityToken: null,
        message: loginResponse.message ?? "",
      );
    }

    return (
      success: false,
      emailRequired: false,
      isNewUser: false,
      identityToken: identityToken,
      message: loginResponse.message ?? "",
    );

  } catch (e) {

    return (
      success: false,
      emailRequired: false,
      isNewUser: false,
      identityToken: null,
      message: e.toString(),
    );
  }
}
  Future<void> restoreGuestCart() async {
    final backup = box.read(
      LocalStorageConstants.guestCartBackup,
    );

    if (backup == null) return;

    for (final item in backup) {
      await ApiService.addToCart(
        productId: item["productId"],
        variantId: item["variantId"],
        quantity: item["quantity"],
        price: double.parse(
          item["price"].toString(),
        ),
      );
    }

    box.remove(
      LocalStorageConstants.guestCartBackup,
    );
  }
}
