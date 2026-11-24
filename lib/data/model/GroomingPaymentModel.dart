
class GroomingCouponResponse {
  final bool success;
  final String message;
  final String couponCode;
  final String discountType;
  final double discount;
  final double totalAmount;
  final double finalAmount;
  final List<int> cartItems;

  GroomingCouponResponse({
    required this.success,
    required this.message,
    required this.couponCode,
    required this.discountType,
    required this.discount,
    required this.totalAmount,
    required this.finalAmount,
    required this.cartItems,
  });

  factory GroomingCouponResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return GroomingCouponResponse(
      success: json['success'] == true,
      message: json['message'] ?? '',
      couponCode: json['coupon_code'] ?? '',
      discountType: json['discount_type'] ?? '',
      discount: _parseDouble(json['discount']),
      totalAmount: _parseDouble(json['total_amount']),
      finalAmount: _parseDouble(json['final_amount']),
      cartItems: (json['cart_items'] as List? ?? [])
          .map((e) => (e as num).toInt())
          .toList(),
    );
  }
}
  class GroomingReviewPaymentResponse {
    final bool status;
    final String paymentFlow;
    final String message;
    final int paymentTransactionId;
    final List<int> cartItems;

    final double subtotalAmount;
    final double discountAmount;
    final double finalAmount;
    final double walletAmountUsed;
    final double gatewayAmountUsed;

    // Razorpay details from backend
    final String razorpayOrderId;
    final String currency;
    final int amount;
    final String razorpayKey;

    GroomingReviewPaymentResponse({
      required this.status,
      required this.paymentFlow,
      required this.message,
      required this.paymentTransactionId,
      required this.cartItems,
      required this.subtotalAmount,
      required this.discountAmount,
      required this.finalAmount,
      required this.walletAmountUsed,
      required this.gatewayAmountUsed,
      required this.razorpayOrderId,
      required this.currency,
      required this.amount,
      required this.razorpayKey,
    });

    factory GroomingReviewPaymentResponse.fromJson(
      Map<String, dynamic> json,
    ) {
      return GroomingReviewPaymentResponse(
        status: json['status'] == true,
        paymentFlow: json['payment_flow']?.toString() ?? '',
        message: json['message']?.toString() ?? '',

        paymentTransactionId:
            _parseInt(json['payment_transaction_id']),

        cartItems: (json['cart_items'] as List? ?? [])
            .map((e) => _parseInt(e))
            .toList(),

        subtotalAmount:
            _parseDouble(json['subtotal_amount']),

        discountAmount:
            _parseDouble(json['discount_amount']),

        finalAmount:
            _parseDouble(json['final_amount']),

        walletAmountUsed:
            _parseDouble(json['wallet_amount_used']),

        gatewayAmountUsed:
            _parseDouble(json['gateway_amount_used']),

        // Razorpay response
        razorpayOrderId:
            json['razorpay_order_id']?.toString() ?? '',

        currency:
            json['currency']?.toString() ?? 'INR',

        amount:
            _parseInt(json['amount']),

        razorpayKey:
            json['razorpay_key']?.toString() ?? '',
      );
    }
  }


class GroomingVerifyPaymentResponse {
  final bool status;
  final String message;
  final int paymentTransactionId;
  final String paymentType;
  final String paymentStatus;
  final double subtotalAmount;
  final double discountAmount;
  final double finalAmount;
  final double walletAmountUsed;
  final double gatewayAmountUsed;
  final List<int> bookingIds;

  GroomingVerifyPaymentResponse({
    required this.status,
    required this.message,
    required this.paymentTransactionId,
    required this.paymentType,
    required this.paymentStatus,
    required this.subtotalAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.walletAmountUsed,
    required this.gatewayAmountUsed,
    required this.bookingIds,
  });

  factory GroomingVerifyPaymentResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return GroomingVerifyPaymentResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',

      paymentTransactionId:
          _parseInt(json['payment_transaction_id']),

      paymentType:
          json['payment_type']?.toString() ?? '',

      paymentStatus:
          json['payment_status']?.toString() ?? '',

      subtotalAmount:
          _parseDouble(json['subtotal_amount']),

      discountAmount:
          _parseDouble(json['discount_amount']),

      finalAmount:
          _parseDouble(json['final_amount']),

      walletAmountUsed:
          _parseDouble(json['wallet_amount_used']),

      gatewayAmountUsed:
          _parseDouble(json['gateway_amount_used']),

      bookingIds: (json['booking_ids'] as List? ?? [])
          .map((e) => _parseInt(e))
          .toList(),
    );
  }
}

    double _parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();

      return double.tryParse(value.toString()) ?? 0.0;
    }

    int _parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();

      return int.tryParse(value.toString()) ?? 0;
    }