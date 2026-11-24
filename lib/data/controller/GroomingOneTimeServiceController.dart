
import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/GroomingOneTimeServiceModel.dart';


class OneTimeGroomingServiceController extends GetxController {
  final RxList<OneTimeGroomingServiceModel> services =
      <OneTimeGroomingServiceModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  Future<void> fetchServices() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result =
          await ApiService.fetchOneTimeGroomingServices();

      services.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
      print('Error fetching one-time grooming services: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
