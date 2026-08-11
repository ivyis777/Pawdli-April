import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pawlli/data/api service.dart';
import 'package:pawlli/data/app url.dart';
import 'package:pawlli/data/model/couponmodel.dart';

class CouponService {
  static Future<CouponModel?> applyCoupon({
    required List<int> cartItems,
    required String couponCode,
  }) async {
    final token = await ApiService.getAccessToken();

    if (token == null) return null;

    final response = await http.post(
      Uri.parse(AppUrl.VerifyStoreCoupon),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "cart_items": cartItems,
        "coupon_code": couponCode,
      }),
    );

    print("========== APPLY COUPON ==========");
    print("STATUS : ${response.statusCode}");
    print("BODY   : ${response.body}");
    print("==================================");

    if (response.statusCode == 200) {
      return CouponModel.fromJson(jsonDecode(response.body));
    }

    return null;
  }
}