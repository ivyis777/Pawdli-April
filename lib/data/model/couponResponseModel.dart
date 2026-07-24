class ApplyCouponModel {
  bool? status;
  String? message;

  double? totalAmount;
  double? discountAmount;
  double? taxAmount;
  double? consultationFee;

  String? couponCode;

  ApplyCouponModel({
    this.status,
    this.message,
    this.totalAmount,
    this.discountAmount,
    this.taxAmount,
    this.consultationFee,
    this.couponCode,
  });

  factory ApplyCouponModel.fromJson(
      Map<String, dynamic> json) {
    return ApplyCouponModel(
      status: json["status"],
      message: json["message"],
      totalAmount:
          (json["total_amount"] ?? 0).toDouble(),
      discountAmount:
          (json["discount_amount"] ?? 0).toDouble(),
      taxAmount:
          (json["tax_amount"] ?? 0).toDouble(),
      consultationFee:
          (json["consultation_fee"] ?? 0).toDouble(),
      couponCode: json["coupon_code"],
    );
  }
}