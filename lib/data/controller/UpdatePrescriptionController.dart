import 'package:get/get.dart';

import '../api service.dart';

class UpdatePrescriptionController
    extends GetxController {

  final isLoading =
      false.obs;

  Future<bool> updatePrescription({

    required int prescriptionId,

    required Map<String, dynamic>
        requestBody,

  }) async {

    try {

      isLoading.value = true;

      return await ApiService()
          .updatePrescription(

        prescriptionId:
            prescriptionId,

        requestBody:
            requestBody,
      );

    } finally {

      isLoading.value = false;
    }
  }
}