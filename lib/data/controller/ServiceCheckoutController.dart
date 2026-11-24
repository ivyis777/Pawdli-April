
import 'package:flutter/material.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/ServiceCheckoutModel.dart';

class GroomingCheckoutController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  GroomingCheckoutResponse? checkoutResponse;

  List<GroomingCheckoutItem> get items =>
      checkoutResponse?.items ?? [];

  double get totalAmount =>
      checkoutResponse?.totalAmount ?? 0;

  int get totalItems =>
      checkoutResponse?.totalItems ?? 0;

  Future<bool> fetchCheckoutDetails({
    required List<int> cartIds,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result =
          await ApiService.fetchGroomingCheckoutDetails(
        cartIds: cartIds,
      );

      if (result == null || !result.status) {
        errorMessage = 'Unable to load checkout details.';
        return false;
      }

      checkoutResponse = result;
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
