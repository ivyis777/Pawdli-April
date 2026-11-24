class GuestLoginModel {
  final bool status;
  final String message;
  final String code;
  final GuestData data;

  GuestLoginModel({
    required this.status,
    required this.message,
    required this.code,
    required this.data,
  });

  factory GuestLoginModel.fromJson(Map<String, dynamic> json) {
    return GuestLoginModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      code: json['code'] ?? '',
      data: GuestData.fromJson(json['data']),
    );
  }
}

class GuestData {
  final GuestTokens tokens;
  final int userId;
  final bool isGuest;

  GuestData({
    required this.tokens,
    required this.userId,
    required this.isGuest,
  });

  factory GuestData.fromJson(Map<String, dynamic> json) {
    return GuestData(
      tokens: GuestTokens.fromJson(json['tokens']),
      userId: json['user_id'] ?? 0,
      isGuest: json['is_guest'] ?? false,
    );
  }
}

class GuestTokens {
  final String refresh;
  final String access;

  GuestTokens({
    required this.refresh,
    required this.access,
  });

  factory GuestTokens.fromJson(Map<String, dynamic> json) {
    return GuestTokens(
      refresh: json['refresh'] ?? '',
      access: json['access'] ?? '',
    );
  }
}