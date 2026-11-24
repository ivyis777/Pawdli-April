
import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/GroomingPlansListModel.dart';


class GroomingServiceListController extends GetxController {
  // Loading indicator
  final RxBool isLoading = false.obs;

  // Combined PLAN and COMBO services
  final RxList<GroomingMainServiceModel> services =
      <GroomingMainServiceModel>[].obs;

  // API error message
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  /// Fetch and display both PLAN and COMBO services.
  Future<void> fetchServices() async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await ApiService.fetchAllGroomingServices();

      services.assignAll(result);

      if (services.isEmpty) {
        errorMessage.value = 'No grooming services available.';
      }
    } catch (e) {
      errorMessage.value =
          e.toString().replaceFirst('Exception: ', '');

      print('Grooming Services Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Retry after an API error.
  Future<void> retryFetch() async {
    await fetchServices();
  }

  /// Clear existing service data.
  void clearServices() {
    services.clear();
    errorMessage.value = '';
  }
}
