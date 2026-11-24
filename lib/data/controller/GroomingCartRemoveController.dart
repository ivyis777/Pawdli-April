
import 'package:flutter/material.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/GroomingCartRemoveModel.dart';

class GroomingCartRemoveController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  GroomingCartRemoveModel? result;

  Future<bool> removeCartItem({
    required int cartId,
  }) async {
    if (isLoading) return false;

    isLoading = true;
    errorMessage = null;
    result = null;
    notifyListeners();

    try {
      final response = await ApiService.removeGroomingCartItem(
        cartId: cartId,
      );

      result = response;

      if (response.status) {
        return true;
      }

      errorMessage = response.message;
      return false;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
