import 'package:get/get.dart';
import '../api service.dart';
import '../model/admin_ordermodel.dart';

class AdminOrdercontroller extends GetxController {
  var orderList = <AdminOrdermodel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchOrders();
    super.onInit();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading(true);
      final orders = await ApiService.getAdminOrders();
      orderList.assignAll(orders);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }
}