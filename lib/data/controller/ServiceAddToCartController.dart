
import 'package:flutter/material.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/ServiceCartModel.dart';

class GroomingAddToCartController extends ChangeNotifier {
  bool isLoading = false;
  bool isCartLoading = false;

  String? errorMessage;
  String? cartErrorMessage;

  // POST response
  GroomingAddToCartResponse? result;

  // GET response
  GroomingAddToCartResponse? cartResult;

  /// POST: Add build-plan grooming booking
  Future<bool> addToCart(
    GroomingAddToCartRequest request,
  ) async {
    if (isLoading) return false;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      result = await ApiService.addGroomingToCart(
        request: request,
      );

      if (result?.status != true) {
        errorMessage =
            result?.message ?? 'Unable to add grooming service.';
        return false;
      }

      await fetchCart();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// POST: Add one-time grooming services
  Future<bool> addOneTimeToCart(
    OneTimeGroomingAddToCartRequest request,
  ) async {
    if (isLoading) return false;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      result = await ApiService.addOneTimeGroomingToCart(
        request: request,
      );

      if (result?.status != true) {
        errorMessage =
            result?.message ?? 'Unable to add One-Time service.';
        return false;
      }

      await fetchCart();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// GET: Fetch all grooming carts
  Future<bool> fetchCart() async {
    if (isCartLoading) return false;

    isCartLoading = true;
    cartErrorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.fetchGroomingCart();

      if (!response.status) {
        cartErrorMessage =
            response.message.isNotEmpty
                ? response.message
                : 'Unable to fetch grooming cart.';
        return false;
      }

      cartResult = response;
      return true;
    } catch (e) {
      cartErrorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isCartLoading = false;
      notifyListeners();
    }
  }

  /// All top-level carts, preserving each cart group.
  List<GroomingMainCartModel> get carts =>
      cartResult?.carts ?? [];

  /// All items across every top-level cart.
  /// Useful for a cart page displaying all services together.
  List<GroomingCartItemModel> get cartItems =>
      cartResult?.items ?? [];

  /// Number of top-level carts.
  int get totalCarts =>
      cartResult?.totalCarts ?? 0;

  /// Total number of items reported by the API.
  int get totalItems =>
      cartResult?.totalItems ?? cartItems.length;

  /// Sum of the prices of every item across all carts.
  double get totalPrice => cartItems.fold<double>(
        0.0,
        (total, item) => total + item.price,
      );
}
