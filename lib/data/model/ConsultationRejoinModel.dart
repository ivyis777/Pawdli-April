class RejoinConsultationModel {
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

  RejoinConsultationModel({
    this.status,
    this.message,
    this.consultationRequestId,
    this.consultationRoomId,
    this.websocketUrl,
    this.consultationStatus,
    this.sessionStartTime,
    this.sessionEndTime,
    this.remainingSeconds,
    this.canRejoin,
  });

  factory RejoinConsultationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RejoinConsultationModel(
      status: json["status"],
      message: json["message"],
      consultationRequestId:
          json["consultation_request_id"],
      consultationRoomId:
          json["consultation_room_id"],
      websocketUrl:
          json["websocket_url"],
      consultationStatus:
          json["consultation_status"],
      sessionStartTime:
          json["session_start_time"],
      sessionEndTime:
          json["session_end_time"],
      remainingSeconds:
          json["remaining_seconds"],
      canRejoin:
          json["can_rejoin"],
    );
  }
}