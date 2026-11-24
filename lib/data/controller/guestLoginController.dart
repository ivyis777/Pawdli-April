import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/LocalStorageConstants.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/presentation/widgets/bottom%20bar/bottombar.dart';

class GuestLoginController extends GetxController {
  RxBool isLoading = false.obs;

  Future<void> loginAsGuest() async {
    try {
      isLoading.value = true;

      final response =
          await ApiService.guestLogin();

      if (response == null) {
        Get.snackbar(
          "Error",
          "Guest login failed",
        );
        return;
      }

      LocalStorage.saveTokens(
        response.data.tokens.access,
        response.data.tokens.refresh,
      );

      LocalStorage.saveUserId(
        response.data.userId,
      );

      LocalStorage.saveGuestStatus(
        response.data.isGuest,
      );

      Get.offAll(() => MainLayout());

    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }
}