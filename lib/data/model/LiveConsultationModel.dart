class LiveConsultationModel {

  bool? status;

  int? count;

  List<LiveConsultationData>? data;

  LiveConsultationModel.fromJson(
      Map<String, dynamic> json) {

    status = json['status'];

    count = json['count'];

    if (json['data'] != null) {

      data = <LiveConsultationData>[];

      json['data'].forEach((v) {

        data!.add(
          LiveConsultationData.fromJson(v),
        );
      });
    }
  }
}

class LiveConsultationData {

  int? consultationRequestId;

  String? petName;

  String? petAge;

  String? petGender;

  String? petType;

  String? petBreed;

  List<String>? symptoms;

  String? otherSymptom;

  String? problemDescription;

  String? consultationFee;

  String? consultationStatus;

  int? remainingSearchSeconds;

  String? createdAt;

  List<ConsultationImage>? issueImages;

  LiveConsultationData.fromJson(
      Map<String, dynamic> json) {

    consultationRequestId =
    json['consultation_request_id'];

    petName =
    json['pet_name'];

    petAge =
    json['pet_age'];

    petGender =
    json['pet_gender'];

    petType =
    json['pet_type'];

    petBreed =
    json['pet_breed'];

    symptoms =
    json['symptoms']
        .cast<String>();

    otherSymptom =
    json['other_symptom'];

    problemDescription =
    json['problem_description'];

    consultationFee =
    json['consultation_fee'];

    consultationStatus =
    json['consultation_status'];

    remainingSearchSeconds =
    json['remaining_search_seconds'];

    createdAt =
    json['created_at'];

    if (json['issue_images'] != null) {

      issueImages = <ConsultationImage>[];

      json['issue_images'].forEach((v) {

        issueImages!.add(
          ConsultationImage.fromJson(v),
        );
      });
    }
  }
}

class ConsultationImage {

  int? id;

  String? image;

  String? createdAt;

  ConsultationImage.fromJson(
      Map<String, dynamic> json) {

    id = json['id'];

    image = json['image'];

    createdAt = json['created_at'];
  }
}