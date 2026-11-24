import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/form_validation/form_validation.dart';
import 'package:pawlli/core/storage_manager/LocalStorageConstants.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/updateprofilemodel.dart';

class UpdateProfileController extends GetxController {
  RxBool isLoading = false.obs;
  Rxn<UpdateProfileModel> updatedProfile = Rxn<UpdateProfileModel>();

  late String userId;

  @override
  void onInit() {
    super.onInit();

    userId = LocalStorage.getUserId()?.toString() ?? '';

    print("USER ID FROM STORAGE: $userId");
  }

  Future<void> updateUserProfile(UpdateProfileModel model) async {
    try {
      isLoading.value = true;

      final result = await ApiService.updateUserProfile(model, userId);

      if (result != null) {
        updatedProfile.value = result;

        // Get latest values from API response.
        // If a field is absent, retain the submitted or stored value.
        final updatedId =
            result.id ??
            model.id ??
            LocalStorage.getUserId();

        final updatedName =
            result.name ?? model.name ?? LocalStorage.getName() ?? '';

        final updatedUsername =
            result.username ??
            model.username ??
            LocalStorage.getUserName() ??
            '';

        final updatedMobile =
            result.mobile ??
            model.mobile ??
            LocalStorage.getMobile() ??
            '';

        // Save updated profile into LocalStorage.
        if (updatedId != null) {
          await LocalStorage.saveProfileDetails(
            userId: updatedId,
            name: updatedName,
            username: updatedUsername,
            mobile: updatedMobile,
          );
        }

        // Debug verification
        print("======= PROFILE UPDATE SUCCESS =======");
        print("User ID: ${LocalStorage.getUserId()}");
        print("Name: ${LocalStorage.getName()}");
        print("Username: ${LocalStorage.getUserName()}");
        print("Mobile: ${LocalStorage.getMobile()}");

        final isComplete = FormValidation.isProfileComplete(
          userId: LocalStorage.getUserId(),
          name: LocalStorage.getName(),
          username: LocalStorage.getUserName(),
          mobile: LocalStorage.getMobile(),
        );

        print("PROFILE COMPLETE: $isComplete");
        print("======================================");

        Get.snackbar(
          "Success",
          "Profile updated successfully",
          backgroundColor: Colors.transparent,
          colorText: Colours.black,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
        );
      } else {
        Get.snackbar(
          "Error",
          "Something went wrong while updating profile",
          backgroundColor: Colors.transparent,
          colorText: Colours.black,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      print("PROFILE UPDATE ERROR: $e");
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
