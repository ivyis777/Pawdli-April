import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:pawlli/data/model/MedicineModel.dart';

class PrescriptionController
    extends GetxController {

  RxList<MedicineModel>
      medicines =
      <MedicineModel>[].obs;

  Rx<DateTime?> nextConsultationDate =
    Rx<DateTime?>(null);

  RxBool loading = false.obs;

  void addMedicine() {

    medicines.add(
      MedicineModel(
        medicineName: "",
        medicineType: "tablet",
        quantity: "",
        morning: true,
        afternoon: true,
        night: true,
        durationDays: 5,
        directionOfUse:
            "After food",
      ),
    );
  }

  void removeMedicine(int index) {
    medicines.removeAt(index);
  }

  Future<void> pickNextConsultationDate(
      BuildContext context) async {

    final selectedDate =
        await showDatePicker(

      context: context,

      initialDate:
          DateTime.now().add(
        const Duration(days: 7),
      ),

      firstDate: DateTime.now(),

      lastDate: DateTime(2035),
    );

    if (selectedDate != null) {

      nextConsultationDate.value =
          selectedDate;
    }
  }
}