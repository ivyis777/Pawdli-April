class VetPaymentModel {

  bool? status;

  String? paymentFlow;

  String? message;

  int? paymentTransactionId;

  int? consultationRequestId;

  String? razorpayOrderId;

  String? razorpayKey;

  String? currency;

  int? amount;
  double? consultationAmount;
  double? walletAmountUsed;
  double? gatewayAmountUsed;

  VetPaymentModel.fromJson(
      Map<String, dynamic> json) {

    status = json['status'];

    paymentFlow =
    json['payment_flow'];

    message = json['message'];

    paymentTransactionId =
    json['payment_transaction_id'];

    consultationRequestId =
    json['consultation_request_id'];

    razorpayOrderId =
    json['razorpay_order_id'];

    razorpayKey =
    json['razorpay_key'];

    currency =
    json['currency'];

    amount =
    json['amount'];
    
    consultationAmount =
        (json['consultation_amount'] ?? 0)
          .toDouble();

    walletAmountUsed =
        (json['wallet_amount_used'] ?? 0)
            .toDouble();

    gatewayAmountUsed =
        (json['gateway_amount_used'] ?? 0)
            .toDouble();
  }
}