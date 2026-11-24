class ConsultationModel {

  int? consultationRequestId;
  String? petName;
  String? petBreed;
  String? petType;
  String? consultationStatus;
  int? consultationType;
  String? createdAt;

  String? doctorName;
  String? doctorSpeciality;

  bool? prescriptionAvailable;
  String? prescriptionDownloadUrl;
  String? consultationFee;
  String? problemDescription;
  String? receiptDownloadUrl;
  String? petAge;
  String? petGender;

  List<dynamic>? symptoms;

  String? otherSymptom;

  String? sessionStartTime;
  String? sessionEndTime;
  bool? canRejoin;

  String? consultationRoomId;

  String? websocketUrl;

  String? doctorId;

  Map<String, dynamic>? paymentDetails;

  List<dynamic>? issueImages;

  ConsultationModel({
    this.consultationRequestId,
    this.petName,
    this.petBreed,
    this.petType,
    this.consultationStatus,
    this.consultationType,
    this.createdAt,
    this.doctorName,
    this.doctorSpeciality,
    this.prescriptionAvailable,
    this.prescriptionDownloadUrl,
    this.consultationFee,
    this.problemDescription,
    this.receiptDownloadUrl,
    this.petAge,
    this.petGender,
    this.symptoms,
    this.otherSymptom,
    this.sessionStartTime,
    this.sessionEndTime,
    this.canRejoin,
    this.consultationRoomId,
    this.websocketUrl,
    this.doctorId,
    this.paymentDetails,
    this.issueImages,
  });

  factory ConsultationModel.fromJson(
      Map<String, dynamic> json) {

        print(
          "PRESCRIPTION API URL => ${json["prescription_download_url"]}",
        );


    return ConsultationModel(

      consultationRequestId:
          json["consultation_request_id"],

      petName:
          json["pet_name"],

      petBreed:
          json["pet_breed"],

      petType:
          json["pet_type"],

      consultationStatus:
          json["consultation_status"],

      consultationType:
          json["consultation_type"],

      createdAt:
          json["created_at"],

      doctorName:
          json["doctor_name"],

      doctorSpeciality:
          json["doctor_speciality"],

      prescriptionAvailable:
          json["prescription_available"],

      prescriptionDownloadUrl:
          json["prescription_download_url"],
      consultationFee:
          json["consultation_fee"],
      problemDescription:
          json["problem_description"],
      receiptDownloadUrl:
          json["receipt_download_url"],
      petAge:
          json["pet_age"],
      petGender:
          json["pet_gender"],
      symptoms:
          json["symptoms"],
      otherSymptom:
          json["other_symptom"],
      sessionStartTime:
          json["session_start_time"],
      sessionEndTime:
          json["session_end_time"],
      canRejoin:
          json["can_rejoin"],
      consultationRoomId:
          json["consultation_room_id"],
      websocketUrl:
          json["websocket_url"],
      doctorId:
          json["doctor_id"],
      paymentDetails:
          json["payment_details"],
      issueImages:
          json["issue_images"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "consultation_request_id":
          consultationRequestId,
      "pet_name":
          petName,
      "pet_breed":
          petBreed,
      "pet_type":
          petType,
      "consultation_status":
          consultationStatus,
      "consultation_type":
          consultationType,
      "created_at":
          createdAt,
      "doctor_name":
          doctorName,
      "doctor_speciality":
          doctorSpeciality,
      "prescription_available":
          prescriptionAvailable,
      "prescription_download_url":
          prescriptionDownloadUrl,
      "consultation_fee":
          consultationFee,
      "problem_description":
          problemDescription,
      "receipt_download_url":
          receiptDownloadUrl,
      "pet_age":
          petAge,
      "pet_gender":
          petGender,
      "symptoms":
          symptoms,
      "other_symptom":
          otherSymptom,
      "session_start_time":
          sessionStartTime,
      "session_end_time":
          sessionEndTime,
      "can_rejoin":
          canRejoin,
      "consultation_room_id":
          consultationRoomId,
      "websocket_url":
          websocketUrl,
      "doctor_id":
          doctorId,
      "payment_details":
          paymentDetails,
      "issue_images":
          issueImages,
    };
  }
}