class ConsultationDetailsModel {

  bool? status;

  String? message;

  ConsultationDetailsData? data;
  

  ConsultationDetailsModel({

    this.status,

    this.message,

    this.data,
  });

  ConsultationDetailsModel.fromJson(
      Map<String, dynamic> json) {

    status = json['status'];

    message = json['message'];

    data = json['data'] != null

        ? ConsultationDetailsData.fromJson(
        json['data'])

        : null;
  }
}

  class ConsultationDetailsData {

    int? consultationRequestId;

    String? consultationStatus;

    String? paymentStatus;

    String? consultationRoomId;

    AssignedDoctor? assignedDoctor;

    String? websocketUrl;

    String? petName;
    String? petAge;
    String? petGender;
    String? petBreed;
    String? petType;
    String? consultationFee;
    String? problemDescription;
    String? otherSymptom;

    List<dynamic>? symptoms;
    List<dynamic>? issueImages;

    ConsultationDetailsData.fromJson(
        Map<String, dynamic> json) {

      consultationRequestId =
          json['consultation_request_id'];

      consultationStatus =
          json['consultation_status'];

      paymentStatus =
          json['payment_status'];

      consultationRoomId =
          json['consultation_room_id'];

      assignedDoctor =
          json['assigned_doctor'] != null
              ? AssignedDoctor.fromJson(
                  json['assigned_doctor'])
              : null;

      websocketUrl =
          json['websocket_url'];

      petName =
          json['pet_name'];

      petAge =
          json['pet_age'];

      petGender =
          json['pet_gender'];

      petBreed =
          json['pet_breed'];

      petType =
          json['pet_type'];

      consultationFee =
          json['consultation_fee'];

      problemDescription =
          json['problem_description'];

      otherSymptom =
          json['other_symptom'];

      symptoms =
          json['symptoms'];

      issueImages =
          json['issue_images'];
    }
  }

  class AssignedDoctor {

  int? doctorId;

  String? doctorCode;

  String? doctorName;

  AssignedDoctor.fromJson(
      Map<String, dynamic> json) {

    doctorId = json["doctor_id"];

    doctorCode = json["doctor_code"];

    doctorName = json["doctor_name"];
  }
}