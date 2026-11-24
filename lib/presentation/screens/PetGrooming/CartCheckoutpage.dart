
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/GroomingPaymentController.dart';
import 'package:pawlli/data/controller/ServiceCheckoutController.dart';
import 'package:pawlli/data/controller/walletbalancecontroller.dart';
import 'package:pawlli/data/model/GroomingPaymentModel.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

typedef ApplyGroomingCoupon = Future<double?> Function(
  String coupon,
  List<int> cartIds,
);

typedef ProceedGroomingPayment = Future<void> Function(
  List<int> cartIds,
  double totalAmount,
  double discountAmount,
  double walletAmountUsed,
  double payableAmount,
);

class GroomingCheckoutPage extends StatefulWidget {
  final List<int> cartIds;

  final Map<int, String> petNames;

  final double walletBalance;

  final ApplyGroomingCoupon? onApplyCoupon;
  final ProceedGroomingPayment? onProceedToPay;

  const GroomingCheckoutPage({
    super.key,
    required this.cartIds,
    required this.petNames,
    this.walletBalance = 0,
    this.onApplyCoupon,
    this.onProceedToPay,
  });

  @override
  State<GroomingCheckoutPage> createState() =>
      _GroomingCheckoutPageState();
}

class _GroomingCheckoutPageState
    extends State<GroomingCheckoutPage> {
  final GroomingCheckoutController controller =
      GroomingCheckoutController();

  final TextEditingController couponController =
      TextEditingController();

  final GroomingPaymentController paymentController =
    GroomingPaymentController();

  bool useWallet = false;
  bool isApplyingCoupon = false;

  double discountAmount = 0;
  String appliedCoupon = '';
  final WalletBalanceController walletBalanceController =
      Get.find<WalletBalanceController>();

  final storage = GetStorage();

  String? userId;

  // double get walletBalance {
  //   return double.tryParse(
  //         walletBalanceController.walletBalanceAmount.value.toString(),
  //       ) ??
  //       0.0;
  // }

  late Razorpay _razorpay;

  int? currentPaymentTransactionId;
  String? razorpayOrderId;

  bool isPaymentProcessing = false;

  @override
  void initState() {
    super.initState();

    userId = storage.read('user_id')?.toString() ??
        storage.read('userid')?.toString();

    if (userId != null) {
      walletBalanceController.fetchWalletBalance(
        int.parse(userId!),
      );
    }
    _razorpay = Razorpay();

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      _onPaymentSuccess,
    );

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      _onPaymentError,
    );

    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      _onExternalWallet,
    );

    _loadCheckout();
  } 

  void _onExternalWallet(ExternalWalletResponse response) {
    debugPrint('========== EXTERNAL WALLET ==========');
    debugPrint('Wallet Name: ${response.walletName}');

    _showMessage(
      'External wallet selected: ${response.walletName ?? ''}',
    );
  }

    void openGroomingCheckout(
      GroomingReviewPaymentResponse paymentResponse,
    ) {
      currentPaymentTransactionId =
          paymentResponse.paymentTransactionId;

      razorpayOrderId =
          paymentResponse.razorpayOrderId;

      // Validate backend Razorpay details
      if (paymentResponse.razorpayOrderId.isEmpty ||
          paymentResponse.razorpayKey.isEmpty ||
          paymentResponse.amount <= 0) {

        setState(() {
          isPaymentProcessing = false;
        });

        _showMessage('Invalid Razorpay payment details.');
        return;
      }

      final options = {
        'key': paymentResponse.razorpayKey,
        'amount': paymentResponse.amount,
        'currency': paymentResponse.currency,
        'order_id': paymentResponse.razorpayOrderId,
        'name': 'Pawlli',
        'description': 'Grooming Service Payment',
        'prefill': {
          'contact': '',
          'email': '',
        },
        'retry': {
          'enabled': true,
          'max_count': 2,
        },
      };

      try {
        debugPrint('========== RAZORPAY CHECKOUT ==========');

        debugPrint(
          'Transaction ID: ${paymentResponse.paymentTransactionId}',
        );

        debugPrint(
          'Razorpay Order ID: ${paymentResponse.razorpayOrderId}',
        );

        debugPrint(
          'Razorpay Amount: ${paymentResponse.amount}',
        );

        debugPrint(
          'Currency: ${paymentResponse.currency}',
        );

        // Open Razorpay directly using backend response
        _razorpay.open(options);

        debugPrint('RAZORPAY OPEN REQUEST SENT');

      } catch (e, stackTrace) {
        debugPrint('RAZORPAY OPEN ERROR: $e');
        debugPrint('STACK TRACE: $stackTrace');

        if (!mounted) return;

        setState(() {
          isPaymentProcessing = false;
        });

        _showMessage('Unable to open Razorpay: $e');
      }
    }


  Future<void> _onPaymentSuccess(
    PaymentSuccessResponse response,
  ) async {

    debugPrint('========== RAZORPAY SUCCESS ==========');
    debugPrint('Payment ID: ${response.paymentId}');
    debugPrint('Order ID: ${response.orderId}');
    debugPrint('Signature: ${response.signature}');

    final transactionId = currentPaymentTransactionId;

    if (transactionId == null ||
        response.orderId == null ||
        response.paymentId == null ||
        response.signature == null) {
      if (mounted) {
        setState(() => isPaymentProcessing = false);
        _showMessage('Payment details are incomplete.');
      }
      return;
    }

    try {
      final result = await paymentController.verifyPayment(
        paymentTransactionId: transactionId,
        razorpayOrderId: response.orderId!,
        razorpayPaymentId: response.paymentId!,
        razorpaySignature: response.signature!,
      );

      if (!mounted) return;

      if (result != null &&
          result.status &&
          result.paymentStatus.toLowerCase() == 'success') {
        await _completeGroomingPayment(result.message);
      } else {
        _showMessage(
          result?.message ?? 'Payment verification failed.',
        );
      }
    } catch (e) {
      _showMessage('Payment verification error: $e');
    } finally {
      if (mounted) {
        setState(() => isPaymentProcessing = false);
      }
    }
  }


  void _onPaymentError(PaymentFailureResponse response) {

    debugPrint('========== RAZORPAY FAILURE ==========');
    debugPrint('Error Code: ${response.code}');
    debugPrint('Error Message: ${response.message}');
    debugPrint('Error Details: ${response.error}');

    if (!mounted) return;

    setState(() => isPaymentProcessing = false);

    _showMessage(
      response.message ?? 'Razorpay payment failed.',
    );

    // Do not mark the booking as paid.
    // Do not call verify-payment with empty Razorpay details.
  }

  Future<void> _completeGroomingPayment(String message) async {
    if (!mounted) return;

    _showMessage(message);

    if (userId != null) {
      await walletBalanceController.fetchWalletBalance(
        int.parse(userId!),
      );
    }

    if (!mounted) return;

    // Return true so GroomingCartPage refreshes its cart.
    Navigator.pop(context, true);
  }

  Future<void> _loadCheckout() async {
    await controller.fetchCheckoutDetails(
      cartIds: widget.cartIds,
    );

    if (mounted) setState(() {});
  }

  double get totalAmount => controller.totalAmount;

  double get amountAfterDiscount =>
      math.max(0.0, totalAmount - discountAmount);

  double get walletBalance {
    return double.tryParse(
          walletBalanceController.walletBalanceAmount.value.toString(),
        ) ??
        0.0;
  }

  double get walletAmountUsed {
    if (!useWallet) return 0;

    final balance = double.tryParse(
          walletBalanceController.walletBalanceAmount.value.toString(),
        ) ??
        0.0;

    return math.min(balance, amountAfterDiscount);
  }

  double get remainingAmount =>
      math.max(0.0, amountAfterDiscount - walletAmountUsed);

  String _currency(double amount) =>
      '₹${amount.toStringAsFixed(2)}';

  
  Future<void> _applyCoupon() async {
    final code = couponController.text.trim();

    if (code.isEmpty) {
      _showMessage('Please enter coupon code.');
      return;
    }

    if (appliedCoupon.isNotEmpty) return;

    setState(() => isApplyingCoupon = true);

    try {
      final result = await paymentController.applyCoupon(
        cartItems: widget.cartIds,
        couponCode: code,
      );

      if (!mounted) return;

      if (result == null || !result.success) {
        _showMessage(
          result?.message ?? 'Unable to apply coupon.',
        );
        return;
      }

      setState(() {
        appliedCoupon = result.couponCode;
        discountAmount = result.discount;
      });

      _showMessage(result.message);
    } catch (e) {
      _showMessage('Coupon application failed.');
    } finally {
      if (mounted) {
        setState(() => isApplyingCoupon = false);
      }
    }
  }


  void _removeCoupon() {
    setState(() {
      discountAmount = 0;
      appliedCoupon = '';
      couponController.clear();
    });
  }

  Future<void> _proceedToPay() async {
    if (controller.items.isEmpty || isPaymentProcessing) {
      return;
    }

    try {
      setState(() {
        isPaymentProcessing = true;
      });

      // STEP 1: Determine payment type
      String paymentType;

      if (useWallet && remainingAmount <= 0) {
        paymentType = 'wallet';
      } else if (useWallet && walletAmountUsed > 0) {
        paymentType = 'wallet_razorpay';
      } else {
        paymentType = 'razorpay';
      }

      debugPrint('========== GROOMING PAYMENT ==========');
      debugPrint('Cart IDs: ${widget.cartIds}');
      debugPrint('Total: $totalAmount');
      debugPrint('Discount: $discountAmount');
      debugPrint('Wallet Balance: $walletBalance');
      debugPrint('Wallet Selected: $useWallet');
      debugPrint('Wallet Used: $walletAmountUsed');
      debugPrint('Remaining: $remainingAmount');
      debugPrint('Payment Type: $paymentType');

      // STEP 2: Call Review and Pay API
      debugPrint('========== STEP 1: REVIEW AND PAY ==========');

      final response = await paymentController.reviewAndPay(
        cartItems: widget.cartIds,
        paymentType: paymentType,
        couponCode: appliedCoupon.isEmpty
            ? null
            : appliedCoupon,
      );

      if (!mounted) return;

      if (response == null || !response.status) {
        setState(() {
          isPaymentProcessing = false;
        });

        _showMessage(
          response?.message ??
              'Unable to create payment transaction.',
        );

        return;
      }

      // Save transaction ID
      currentPaymentTransactionId =
          response.paymentTransactionId;

      debugPrint('========== PAYMENT RESPONSE ==========');
      debugPrint('Status: ${response.status}');
      debugPrint('Message: ${response.message}');
      debugPrint('Transaction ID: ${response.paymentTransactionId}');
      debugPrint('Payment Flow: ${response.paymentFlow}');
      debugPrint('Wallet Used: ${response.walletAmountUsed}');
      debugPrint('Gateway Amount: ${response.gatewayAmountUsed}');
      debugPrint('Razorpay Order: ${response.razorpayOrderId}');
      debugPrint('Razorpay Amount: ${response.amount}');

      // STEP 3: WALLET-ONLY PAYMENT
      if (response.paymentFlow.toLowerCase() == 'wallet') {

        debugPrint('========== WALLET PAYMENT ==========');

        final verified =
            await paymentController.verifyPayment(
          paymentTransactionId:
              response.paymentTransactionId,
        );

        if (!mounted) return;

        if (verified != null &&
            verified.status &&
            verified.paymentStatus.toLowerCase() == 'success') {

          await _completeGroomingPayment(verified.message);

        } else {
          setState(() {
            isPaymentProcessing = false;
          });

          _showMessage(
            verified?.message ??
                'Wallet payment verification failed.',
          );
        }

        return;
      }

      // STEP 4: RAZORPAY PAYMENT
      debugPrint('========== STEP 2: RAZORPAY ==========');

      openGroomingCheckout(response);

    } catch (e, stackTrace) {
      debugPrint('GROOMING PAYMENT ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');

      if (!mounted) return;

      setState(() {
        isPaymentProcessing = false;
      });

      _showMessage('Payment failed: $e');
    }
  }



  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    couponController.dispose();
    controller.dispose();
    paymentController.dispose();
    _razorpay.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Checkout',
          style: TextStyle(
            color: Colours.brownColour,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(controller.errorMessage!),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadCheckout,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.items.isEmpty) {
            return const Center(
              child: Text('No checkout items found.'),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            children: [
              _selectedItemsCard(),
              const SizedBox(height: 22),
              _couponSection(),
              const SizedBox(height: 22),
              _walletSection(),
              const SizedBox(height: 22),
              _paymentSummary(),
            ],
          );
        },
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
          child: SizedBox(
            height: 54,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.isLoading ||
                      paymentController.isLoading ||
                      isPaymentProcessing ||
                      controller.items.isEmpty
                  ? null
                  : _proceedToPay,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colours.primarycolour,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isPaymentProcessing ||
                      paymentController.isLoading
                  ? const SizedBox(
                      height: 23,
                      width: 23,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      remainingAmount <= 0
                          ? 'PAY USING WALLET'
                          : 'Proceed to Pay ${_currency(remainingAmount)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // SELECTED ITEMS

  Widget _selectedItemsCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colours.brownColour.withValues(alpha: 0.65),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Items',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Colours.brownColour,
            ),
          ),

          const SizedBox(height: 13),

          Divider(color: Colours.brownColour),

          const SizedBox(height: 10),

          Row(
            children: const [
              Expanded(
                flex: 3,
                child: Text(
                  'Pet Name',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'Service Name',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Price',
                  textAlign: TextAlign.end,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ...controller.items.map((item) {
            final petName =
                widget.petNames[item.cartItemId]?.trim();

            final displayPetName =
                petName != null && petName.isNotEmpty
                    ? petName
                    : 'Pet #${item.petId}';

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      displayPetName,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),

                  Expanded(
                    flex: 4,
                    child: Text(
                      item.serviceName,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Text(
                      _currency(item.price),
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 15),

          Divider(color: Colors.grey.shade300),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Total Amount: ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                _currency(totalAmount),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colours.brownColour,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // COUPON SECTION

  Widget _couponSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Apply Coupon',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colours.brownColour,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: couponController,
                enabled: appliedCoupon.isEmpty,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Enter coupon code',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colours.brownColour,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            SizedBox(
              height: 53,
              child: ElevatedButton(
                onPressed: isApplyingCoupon
                    ? null
                    : appliedCoupon.isNotEmpty
                        ? _removeCoupon
                        : _applyCoupon,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colours.primarycolour,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isApplyingCoupon
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        appliedCoupon.isNotEmpty ? 'Remove' : 'Apply',
                      ),
              ),
            ),
          ],
        ),

        if (appliedCoupon.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Coupon $appliedCoupon applied successfully',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  // WALLET SECTION
  Widget _walletSection() {
    return Obx(() {
      final balance = double.tryParse(
            walletBalanceController.walletBalanceAmount.value.toString(),
          ) ??
          0.0;

      debugPrint('WALLET BALANCE IN UI: $balance');

      return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wallet Use',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colours.brownColour,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: useWallet,
                  activeColor: Colours.primarycolour,
                  onChanged: balance <= 0
                      ? null
                      : (value) {
                          setState(() {
                            useWallet = value ?? false;
                          });
                        },
                ),
                const Expanded(
                  child: Text('Use Wallet Balance'),
                ),
                Text(
                  _currency(balance),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (useWallet)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  'Wallet used: ${_currency(math.min(balance, amountAfterDiscount))}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }


  // PAYMENT SUMMARY
  Widget _paymentSummary() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colours.brownColour.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          _summaryRow(
            'Total Amount',
            totalAmount,
          ),

          const SizedBox(height: 13),

          _summaryRow(
            'Discount Applied',
            -discountAmount,
            valueColor: Colors.green,
          ),

          const SizedBox(height: 13),

          _summaryRow(
            'Wallet Used',
            -walletAmountUsed,
            valueColor: Colors.green,
          ),

          const SizedBox(height: 13),

          Divider(color: Colors.grey.shade300),

          const SizedBox(height: 13),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Remaining Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colours.brownColour,
                ),
              ),

              Text(
                _currency(remainingAmount),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colours.brownColour,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String title,
    double amount, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),

        Text(
          _currency(amount.abs()),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }
}
