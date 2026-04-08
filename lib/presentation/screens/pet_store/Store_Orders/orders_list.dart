import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/admin_ordercontroller.dart';
import 'package:pawlli/data/model/admin_ordermodel.dart';
import 'package:pawlli/presentation/screens/pet_store/Store_Orders/admin_order_detailspage.dart';



class AdminOrderListPage extends StatelessWidget {
  AdminOrderListPage({Key? key}) : super(key: key);

  final AdminOrdercontroller controller = Get.put(AdminOrdercontroller());

String formatToIndianTime(String dateTime) {
  try {
    DateTime parsed = DateTime.parse(dateTime).toLocal();

    // Format: 25 Mar 2026, 04:46 PM
    return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
  } catch (e) {
    return dateTime;
  }
}

Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case "paid":
    case "confirmed":
      return Colors.blue;
    case "pending":
      return Colors.orange;
    case "cancelled":
      return Colors.red;
    default:
      return Colors.grey;
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Stack(
          children: [
            /// ✅ TOP LEFT CURVED IMAGE
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.55,
                height: 90,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://pawlli-podcasts.s3.ap-south-1.amazonaws.com/static_images/topimage.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            /// ✅ APP BAR CONTENT
            AppBar(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: Colours.brownColour,

              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.maybePop(context),
              ),

              title:  Text(
                "Order Requests".tr, // change text if needed
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Obx(() {
        /// 🔹 LOADING
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        /// 🔹 EMPTY
        if (controller.orderList.isEmpty) {
          return  Center(child: Text("No Orders Found".tr));
        }

        /// 🔹 LIST
        return RefreshIndicator(
          onRefresh: controller.fetchOrders,
          child: ListView.builder(
            itemCount: controller.orderList.length,
            itemBuilder: (context, index) {
              final AdminOrdermodel order = controller.orderList[index];

              return Card(
                color: const Color.fromARGB(255, 251, 236, 210),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text("Order No: ${order.orderId}".tr),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Amount: ₹${order.finalAmount}".tr),
                      const SizedBox(height: 4),
                      Text(
                        "Date: ${formatToIndianTime(order.createdAt)}".tr,
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),

                  /// 🔥 STATUS BUTTON STYLE
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: getStatusColor(order.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order.status.capitalizeFirst ?? "".tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      // const Icon(Icons.arrow_forward_ios, size: 14),
                    ],
                  ),

                  onTap: () {
                    Get.to(() => AdminOrderDetailspage(order: order));
                  },
                ),
              );
            },
          ),
        );
      }),
    );
  }
}