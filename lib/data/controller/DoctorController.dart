import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/DoctorProfileModel.dart';

class DoctorController extends GetxController {

  // ✅ CREATE OBJECT
  final ApiService apiService = ApiService();

  RxBool isLoading = false.obs;

  RxBool isOnline = false.obs;

  Rx<DoctorData?> doctorData =
      Rx<DoctorData?>(null);

  // =====================================================
  // GET PROFILE
  // =====================================================

  Future<void> getDoctorProfile(
      int userId) async {

    try {

      isLoading.value = true;

      final response =
          await apiService.getDoctorProfile(
              userId);

      if (response != null &&
          response.status == true) {

        doctorData.value = response.data;

        isOnline.value =
            response.data?.activeStatus ?? false;
      }

    } catch (e) {

      print("CONTROLLER ERROR : $e");

    } finally {

      isLoading.value = false;
    }
  }

  // =====================================================
  // TOGGLE STATUS
  // =====================================================

  Future<void> toggleStatus(
      int userId) async {

    final response =
        await apiService.toggleDoctorStatus(
            userId);

    if (response != null &&
        response.status == true) {

      isOnline.value =
          response.data?.activeStatus ?? false;
    }
  }
}