class MedicineModel {

  String medicineName;
  String medicineType;
  String quantity;

  bool morning;
  bool afternoon;
  bool night;

  int durationDays;

  String directionOfUse;

  MedicineModel({
    required this.medicineName,
    required this.medicineType,
    required this.quantity,
    required this.morning,
    required this.afternoon,
    required this.night,
    required this.durationDays,
    required this.directionOfUse,
  });

  Map<String,dynamic> toJson() {
    return {
      "medicine_name": medicineName,
      "medicine_type": medicineType,
      "quantity": quantity,
      "morning": morning,
      "afternoon": afternoon,
      "night": night,
      "duration_days": durationDays,
      "direction_of_use": directionOfUse,
    };
  }
}