import 'package:pawlli/data/model/MedicineModel.dart';

class PrescriptionModel {

  int consultationRequestId;

  String diagnosis;

  String doctorNotes;

  String precautions;

  String followUpAdvice;

  String nextVisitDate;

  List<MedicineModel> medicines;

  PrescriptionModel({
    required this.consultationRequestId,
    required this.diagnosis,
    required this.doctorNotes,
    required this.precautions,
    required this.followUpAdvice,
    required this.nextVisitDate,
    required this.medicines,
  });

  Map<String,dynamic> toJson() {

    return {

      "consultation_request_id":
          consultationRequestId,

      "diagnosis":
          diagnosis,

      "doctor_notes":
          doctorNotes,

      "precautions":
          precautions,

      "follow_up_advice":
          followUpAdvice,

      "next_visit_date":
          nextVisitDate,

      "medicines":
          medicines
              .map((e) => e.toJson())
              .toList(),
    };
  }
}