
class GroomingCartRemoveModel {
  final bool status;
  final String message;
  final GroomingCartRemoveData? data;

  GroomingCartRemoveModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory GroomingCartRemoveModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return GroomingCartRemoveModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? GroomingCartRemoveData.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class GroomingCartRemoveData {
  final int cartItemId;
  final int bookingId;
  final String cartStatus;
  final String bookingStatus;

  GroomingCartRemoveData({
    required this.cartItemId,
    required this.bookingId,
    required this.cartStatus,
    required this.bookingStatus,
  });

  factory GroomingCartRemoveData.fromJson(
    Map<String, dynamic> json,
  ) {
    return GroomingCartRemoveData(
      cartItemId: json['cart_item_id'] ?? 0,
      bookingId: json['booking_id'] ?? 0,
      cartStatus: json['cart_status']?.toString() ?? '',
      bookingStatus: json['booking_status']?.toString() ?? '',
    );
  }
}
