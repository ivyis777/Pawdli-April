import 'package:get/get.dart';
import 'package:pawlli/data/api service.dart';
import 'package:pawlli/data/model/SymptomModel.dart';

class SymptomController extends GetxController {

  RxBool isLoading = false.obs;

  RxList<SymptomData> symptomsList =
      <SymptomData>[].obs;

  @override
  void onInit() {
    super.onInit();

    print("SymptomController HashCode => $hashCode");

    fetchSymptoms();
  }

  /// FETCH SYMPTOMS
  Future<void> fetchSymptoms() async {

    try {

      isLoading.value = true;

      final response =
          await ApiService.fetchSymptoms();

      if (response != null &&
          response.status == true &&
          response.data != null) {

        symptomsList.assignAll(
          response.data!,
        );

        print(
          "SYMPTOMS COUNT : ${symptomsList.length}",
        );

      } else {

        print("NO SYMPTOMS FOUND");
      }

    } catch (e) {

      print(
        "FETCH SYMPTOMS ERROR : $e",
      );

    } finally {

      isLoading.value = false;
    }
  }
}