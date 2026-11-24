class DoctorAcceptModel {

  bool? status;

  String? message;

  int? consultationRequestId;

  String? consultationRoomId;

  String? websocketUrl;

  String? consultationStatus;

  String? sessionStartTime;

  String? sessionEndTime;

  int? remainingSeconds;
  
  bool? canRejoin; 

  DoctorData? doctor;
  PatientData? patient;

  DoctorAcceptModel.fromJson(
      Map<String, dynamic> json) {

    status = json['status'];

    message = json['message'];

    consultationRequestId =
    json['consultation_request_id'];

    consultationRoomId =
    json['consultation_room_id'];

    websocketUrl =
    json['websocket_url'];

    consultationStatus =
    json['consultation_status'];

    sessionStartTime =
    json['session_start_time'];

    sessionEndTime =
    json['session_end_time'];

    remainingSeconds =
    json['remaining_seconds'];

    canRejoin =
    json['can_rejoin']; 

    doctor = json['doctor'] != null

        ? DoctorData.fromJson(
        json['doctor'])

        : null;
    patient = json['patient'] != null

        ? PatientData.fromJson(
        json['patient'])

        : null;
  }
}

class DoctorData {

  String? doctorId;

  String? doctorName;

  String? speciality;

  DoctorData.fromJson(
      Map<String, dynamic> json) {

    doctorId =
    json['doctor_id'];

    doctorName =
    json['doctor_name'];

    speciality =
    json['speciality'];
  }
}
class PatientData {

  String? patientId;
  String? patientName;

  PatientData.fromJson(Map<String, dynamic> json) {

    patientId = json['patient_id'];
    patientName = json['patient_name'];

  }
}