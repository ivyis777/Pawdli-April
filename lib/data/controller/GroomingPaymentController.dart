
import 'package:flutter/material.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/GroomingPaymentModel.dart';

class GroomingPaymentController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  GroomingCouponResponse? couponResponse;
  GroomingReviewPaymentResponse? reviewResponse;
  GroomingVerifyPaymentResponse? verifyResponse;

  Future<GroomingCouponResponse?> applyCoupon({
    required List<int> cartItems,
    required String couponCode,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      couponResponse =
          await ApiService.applyGroomingCoupon(
        cartItems: cartItems,
        couponCode: couponCode,
      );

      if (couponResponse?.success != true) {
        errorMessage =
            couponResponse?.message ?? 'Invalid coupon';
      }

      return couponResponse;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<GroomingReviewPaymentResponse?> reviewAndPay({
    required List<int> cartItems,
    required String paymentType,
    String? couponCode,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      reviewResponse =
          await ApiService.groomingReviewAndPay(
        cartItems: cartItems,
        paymentType: paymentType,
        couponCode: couponCode,
      );

      return reviewResponse;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<GroomingVerifyPaymentResponse?> verifyPayment({
    required int paymentTransactionId,
    String? razorpayOrderId,
    String? razorpayPaymentId,
    String? razorpaySignature,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      verifyResponse =
          await ApiService.verifyGroomingPayment(
        paymentTransactionId: paymentTransactionId,
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );

      return verifyResponse;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
