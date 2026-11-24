import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/ConsultationModel.dart';

class ConsultationController
    extends GetxController {

  RxBool isLoading = false.obs;

  RxList<ConsultationModel>
      consultations =
      <ConsultationModel>[].obs;

  @override
  void onInit() {
    super.onInit();

    fetchConsultations();
  }

  Future<void>fetchConsultations() async {

    try {

      isLoading.value = true;

      consultations.value =
          await ApiService()
              .getConsultations();

    } finally {

      isLoading.value = false;
    }
  }

}