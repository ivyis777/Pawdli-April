class PaymentModel {
  final String id;
  final String razorpayTransactionId;
  final String? razorpayPaymentId;
  final String? razorpayOrderId;
  final String? razorpaySignature;
  final String amount;
  final String programName;
  final String purpose;
  final String? paymentMethod;
  final DateTime transactionDate;
  final String status;
  final DateTime createdAt;
  final int user;
  final String paymentGateway;
  final String paymentType;
  final String paymentTransactionId;

  PaymentModel({
    required this.id,
    required this.razorpayTransactionId,
    this.razorpayPaymentId,
    this.razorpayOrderId,
    this.razorpaySignature,
    required this.amount,
    required this.programName,
    required this.purpose,
    this.paymentMethod,
    required this.transactionDate,
    required this.status,
    required this.createdAt,
    required this.user,
    required this.paymentGateway,
    required this.paymentType,
    required this.paymentTransactionId,
  });

  // 👇 ADD THIS HERE
    String get invoiceId {
      if (paymentTransactionId.isNotEmpty) {
        return paymentTransactionId;
      }

      if (razorpayTransactionId.isNotEmpty) {
        return razorpayTransactionId;
      }

      return id;
    }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    // Old payment API
    final bool isOldPayment = json.containsKey('transaction_date');

    return PaymentModel(
      // Supports int and UUID
      id: json['id'].toString(),

      razorpayTransactionId:
          json['razorpay_transaction_id']?.toString() ?? "",

      paymentTransactionId:
        json['payment_transaction_id']?.toString() ?? "",

      paymentGateway:
          json['payment_gateway']?.toString() ?? "",

      paymentType:
          json['payment_type']?.toString() ?? "",

      razorpayPaymentId:
          json['razorpay_payment_id']?.toString(),

      razorpayOrderId:
          json['razorpay_order_id']?.toString(),

      razorpaySignature:
          json['razorpay_signature']?.toString(),

      // Amount
      amount: isOldPayment
          ? (json['amount']?.toString() ?? "0.00")
          : ((json['wallet_amount_used'] != null &&
                  json['wallet_amount_used'] != "0.00")
              ? json['wallet_amount_used'].toString()
              : json['razorpay_amount']?.toString() ?? "0.00"),

      // Program Name
      programName: json['program_name']?.toString() ?? "",

      // Purpose
      purpose: json['purpose']?.toString() ?? "Wallet",

      // Payment Method
      paymentMethod: json['payment_method']?.toString(),

      // Date
      transactionDate: DateTime.parse(
        isOldPayment
            ? json['transaction_date']
            : json['created_at'],
      ),

      // Status
      status: isOldPayment
          ? json['status']?.toString() ?? ""
          : json['payment_status']?.toString() ?? "",

      createdAt: DateTime.parse(json['created_at']),

      user: json['user'] ?? 0,
    );
  }
}