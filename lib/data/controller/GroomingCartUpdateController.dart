
import 'package:flutter/material.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/GroomingCartUpdateModel.dart';

class GroomingCartUpdateController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  GroomingCartUpdateResponse? result;

  Future<bool> updateCart({
    required GroomingCartUpdateRequest request,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.updateGroomingCart(request);

      if (response == null || !response.status) {
        errorMessage = response?.message ?? 'Unable to update grooming cart.';
        return false;
      }

      result = response;
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
