class AdminOrdermodel {
  final int orderId;
  final int user;
  final String totalAmount;
  final String finalAmount;
  final String status;
  final String? shippingAddress;
  final String createdAt;

  AdminOrdermodel({
    required this.orderId,
    required this.user,
    required this.totalAmount,
    required this.finalAmount,
    required this.status,
    this.shippingAddress,
    required this.createdAt,
  });

  factory AdminOrdermodel.fromJson(Map<String, dynamic> json) {
    return AdminOrdermodel(
      orderId: json['order_id'],
      user: json['user'],
      totalAmount: json['total_amount'],
      finalAmount: json['final_amount'],
      status: json['order_status'],
      shippingAddress: json['shipping_address'],
      createdAt: json['created_at'],
    );
  }
}