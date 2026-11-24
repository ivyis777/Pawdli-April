
import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/petslistmodel.dart';

class Petslistcontroller extends GetxController {
  final RxList<Data> userPets = <Data>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserPets(null);
  }

  Future<void> loadUserPets(int? userId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await ApiService.fetchUserPets(userId);

      if (response != null && response.data != null) {
        userPets.assignAll(response.data!);
      } else {
        userPets.clear();
        errorMessage.value = 'Unable to load your pets.';
      }
    } catch (e) {
      errorMessage.value = 'Unable to load pets. Please try again.';
      print('Error loading user pets: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
