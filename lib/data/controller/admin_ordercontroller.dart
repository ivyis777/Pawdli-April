import 'package:get/get.dart';
import '../api service.dart';
import '../model/admin_ordermodel.dart';

class AdminOrdercontroller extends GetxController {

  var orderList = <AdminOrdermodel>[].obs;

  var isLoading = false.obs;

  var isUpdating = false.obs;

  @override
  void onInit() {
    fetchOrders();
    super.onInit();
  }

  /// FETCH ORDERS
  Future<void> fetchOrders() async {

    try {

      isLoading(true);

      final orders =
          await ApiService.getAdminOrders();

      orderList.assignAll(orders);

    } catch (e) {

      Get.snackbar(
        "Error",
        e.toString(),
      );

    } finally {

      isLoading(false);
    }
  }

  /// UPDATE ORDER STATUS
  Future<bool> updateOrderStatusNow({
    required int orderId,
    required String status,
  }) async {

    try {

      isUpdating(true);

      bool success =
          await ApiService.updateOrderStatus(
        orderId: orderId,
        status: status,
      );

      if (success) {

        Get.snackbar(
          "Success",
          "Order updated to ${status.capitalizeFirst}",
        );

        await fetchOrders();

        return true;
      }

      Get.snackbar(
        "Error",
        "Failed to update order",
      );

      return false;

    } catch (e) {

      Get.snackbar(
        "Error",
        e.toString(),
      );

      return false;

    } finally {

      isUpdating(false);
    }
  }
}