class DoctorProfileModel {
  bool? status;
  String? message;
  DoctorData? data;

  DoctorProfileModel({
    this.status,
    this.message,
    this.data,
  });

  DoctorProfileModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];

    data = json['data'] != null
        ? DoctorData.fromJson(json['data'])
        : null;
  }
}

class DoctorData {
  String? doctorUniqueId;
  String? fullName;
  String? profileImage;
  String? designation;
  String? speciality;
  String? clinicAddress;
  String? consultationFee;
  bool? activeStatus;
  bool? currentlyBusy;

  DoctorData({
    this.doctorUniqueId,
    this.fullName,
    this.profileImage,
    this.designation,
    this.speciality,
    this.clinicAddress,
    this.consultationFee,
    this.activeStatus,
    this.currentlyBusy,
  });

  DoctorData.fromJson(Map<String, dynamic> json) {
    doctorUniqueId = json['doctor_unique_id'];
    fullName = json['full_name'];
    profileImage = json['profile_image'];
    designation = json['designation'];
    speciality = json['speciality'];
    clinicAddress = json['clinic_address'];
    consultationFee = json['consultation_fee'].toString();
    activeStatus = json['active_status'];
    currentlyBusy = json['currently_busy'];
  }
}