class CouponModel {
  final bool success;
  final String message;

  final String couponCode;
  final String discountType;

  final double discount;
  final double totalAmount;
  final double finalAmount;

  CouponModel({
    required this.success,
    required this.message,
    required this.couponCode,
    required this.discountType,
    required this.discount,
    required this.totalAmount,
    required this.finalAmount,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",

      couponCode: json["coupon_code"] ?? "",
      discountType: json["discount_type"] ?? "",

      discount: (json["discount"] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json["total_amount"] as num?)?.toDouble() ?? 0.0,
      finalAmount: (json["final_amount"] as num?)?.toDouble() ?? 0.0,
    );
  }
}