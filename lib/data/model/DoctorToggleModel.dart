class DoctorToggleModel {
  bool? status;
  String? message;
  ToggleData? data;

  DoctorToggleModel({
    this.status,
    this.message,
    this.data,
  });

  DoctorToggleModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];

    data = json['data'] != null
        ? ToggleData.fromJson(json['data'])
        : null;
  }
}

class ToggleData {
  bool? activeStatus;
  bool? currentlyBusy;

  ToggleData({
    this.activeStatus,
    this.currentlyBusy,
  });

  ToggleData.fromJson(Map<String, dynamic> json) {
    activeStatus = json['active_status'];
    currentlyBusy = json['currently_busy'];
  }
}