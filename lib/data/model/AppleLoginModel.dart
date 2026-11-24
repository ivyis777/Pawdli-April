class AppleEmailRequiredModel {
  final bool status;
  final String? message;
  final String? code;
  final int? userId;
  final String? appleUserId;

  AppleEmailRequiredModel({
    required this.status,
    this.message,
    this.code,
    this.userId,
    this.appleUserId,
  });

  factory AppleEmailRequiredModel.fromJson(
      Map<String, dynamic> json) {
    return AppleEmailRequiredModel(
      status: json["status"] ?? false,
      message: json["message"],
      code: json["code"],
      userId: json["data"]?["user_id"],
      appleUserId: json["data"]?["apple_user_id"],
    );
  }
}