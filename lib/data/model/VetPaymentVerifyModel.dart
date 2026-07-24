class PaymentVerifyModel {

  bool? status;

  String? message;

  String? consultationStatus;

  int? consultationRequestId;

  PaymentVerifyModel.fromJson(
      Map<String, dynamic> json) {

    status = json['status'];

    message = json['message'];

    consultationStatus =
    json['consultation_status'];

    consultationRequestId =
    json['consultation_request_id'];
  }
}