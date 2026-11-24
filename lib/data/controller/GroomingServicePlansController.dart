
import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/GroomingServicePlansModel.dart';


class GroomingServiceController extends GetxController {
  // Loading state
  final RxBool isLoading = false.obs;

  // Grooming service details
  final Rxn<GroomingServiceModel> service =
      Rxn<GroomingServiceModel>();

  // Error message
  final RxString errorMessage = ''.obs;

  /// Fetch grooming service details using service ID.
  Future<void> fetchServiceDetails(int serviceId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      service.value =
          await ApiService.fetchGroomingServiceDetails(serviceId);
    } catch (e) {
      service.value = null;

      errorMessage.value = e.toString().replaceFirst(
            'Exception: ',
            '',
          );

      print('Grooming Service Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Retry fetching the service details.
  Future<void> retryFetch(int serviceId) async {
    await fetchServiceDetails(serviceId);
  }

  /// Clear the current service data.
  void clearServiceData() {
    service.value = null;
    errorMessage.value = '';
  }
}
