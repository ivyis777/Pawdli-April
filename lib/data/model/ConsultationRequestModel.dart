class ConsultationRequestModel {

  bool? status;

  String? message;

  ConsultationRequestData? data;

  ConsultationRequestModel({

    this.status,

    this.message,

    this.data,
  });

  ConsultationRequestModel.fromJson(
      Map<String, dynamic> json) {

    status = json['status'];

    message = json['message'];

    data = json['data'] != null

        ? ConsultationRequestData.fromJson(
        json['data'])

        : null;
  }
}

class ConsultationRequestData {

  int? consultationRequestId;

  String? paymentStatus;

  String? consultationStatus;

  String? consultationRoomId;

  String? assignedDoctor;

  ConsultationRequestData.fromJson(
      Map<String, dynamic> json) {

    consultationRequestId =
    json['consultation_request_id'];

    paymentStatus =
    json['payment_status'];

    consultationStatus =
    json['consultation_status'];

    consultationRoomId =
      json['consultation_room_id'];

    assignedDoctor =
    json['assigned_doctor'];
  }
}