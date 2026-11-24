import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/myordercontroller.dart';
import 'package:pawlli/data/model/ordermodel.dart';
import 'package:pawlli/presentation/screens/pet_store/orderdetailspage.dart';
import 'package:pawlli/presentation/screens/pet_store/pet_storemain.dart';

double getResponsiveFont(BuildContext context, double size) {
  double screenWidth = MediaQuery.of(context).size.width;

  if (screenWidth < 360) {
    return size * 0.85;
  } else if (screenWidth < 400) {
    return size;
  } else if (screenWidth < 600) {
    return size * 1.1;
  } else {
    return size * 1.3;
  }
}

class OrdersPage extends StatelessWidget {
  OrdersPage({super.key});

  final MyOrdersController controller = Get.find<MyOrdersController>();

  final filterNames = {
    OrderFilter.all: "All",
    OrderFilter.ordered: "Ordered",
    OrderFilter.shipping: "Shipping",
    OrderFilter.delivered: "Delivered",
    OrderFilter.cancelled: "Cancelled",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Stack(
          children: [
            // ✅ BACKGROUND TOP IMAGE
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.55,
                height: 90,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://app.pawdli.com/media/static/topimage.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // ✅ APP BAR ON TOP (Back button + title visible)
            AppBar(
              centerTitle: true,
              elevation: 1,
              backgroundColor: Colors.transparent, // IMPORTANT
              foregroundColor: Colours.brownColour,

              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.maybePop(context),
              ),

              title:  Text(
                "My Orders".tr,
                style: TextStyle(
                  fontSize: getResponsiveFont(context, 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: _orderList(context),
      ),
    );
  }

  Widget _orderList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.filteredOrders.isEmpty) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          width: double.infinity,
          child: Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PetstorePage(),
                  ),
                );
              },
              child: Image.asset(
                'assets/images/NoOrders.png',
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.9,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await controller.fetchOrders(); // 👈 call your API again
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(), // IMPORTANT
          itemCount: controller.filteredOrders.length,
          itemBuilder: (context, i) =>
              _orderCard(controller.filteredOrders[i], context),
        ),
      );
    });
  }

  String getDisplayStatus(Order order) {
    final status = order.orderStatus.toLowerCase();

    /// ❌ CANCELLED
    if (status == "cancelled" ||
        status == "order cancelled") {
      return "Cancel";
    }

    /// ✅ PAID
    if (status == "paid") {
      return "Paid";
    }

    /// ✅ CONFIRMED (ADMIN ACCEPTED)
    if (status == "confirmed") {
      return "Confirmed";
    }

    /// 🚚 SHIPPED
    if (status == "shipped") {
      return "Shipped";
    }

    /// 📦 DELIVERED
    if (status == "delivered") {
      return "Delivered";
    }

    /// ⏳ PENDING
    if (status == "pending") {
      return "Pending";
    }

    return order.orderStatus.capitalize ?? "Pending";
  }

  Widget _orderCard(Order order, BuildContext context) {
    print("--------------------------------");
    print("Order ID: ${order.orderId}");
    print("Items Count: ${order.items.length}");

    if (order.items.isEmpty) {
      print("❌ Empty items for Order ${order.orderId}");

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: ListTile(
          title: Text("Order: ${order.orderId}"),
          subtitle: const Text("No items found"),
        ),
      );
    }
    final item = order.items.first;
    print("Order ID: ${order.orderId}");
    print("Items Count: ${order.items.length}");

    print("variantImages: ${item.variantImages}");
    print("variantImages length: ${item.variantImages.length}");

    print("productImage: ${item.productImage}");

    print("productImages: ${item.productImages}");
    print("productImages length: ${item.productImages.length}");

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsPage(
              order: order,
            ),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colours.brownColour,width: 0.3
          ),
        ),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Builder(
                  builder: (_) {
                    String imageUrl = "";

                    if (item.variantImages.isNotEmpty) {
                      imageUrl = item.variantImages.first;
                    } else if (item.productImage != null &&
                        item.productImage!.isNotEmpty) {
                      imageUrl = item.productImage!;
                    } else if (item.productImages.isNotEmpty) {
                      imageUrl = item.productImages.first;
                    } else {
                      imageUrl = "https://picsum.photos/80";
                    }

                    return Image.network(
                      imageUrl,
                      height: 90,
                      width: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          height: 90,
                          width: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              // RIGHT SIDE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔥 TOP ROW (TITLE + STATUS)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: getResponsiveFont(context, 14),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // ✅ STATUS BADGE (NO OVERLAP EVER)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _statusColor(getDisplayStatus(order)),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            getDisplayStatus(order),
                            style: TextStyle(
                              fontSize: getResponsiveFont(context, 12),
                              color: Colors.black,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "Order: ${order.orderId}".tr,
                      style: TextStyle(
                        fontSize: getResponsiveFont(context, 12),
                        color: Colors.grey[700]),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "Amount: ₹${order.finalAmount}".tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: getResponsiveFont(context, 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Status color helper
  Color _statusColor(String status) {

    switch (status.toLowerCase()) {

      case "paid":
        return Colors.orange;

      case "confirmed":
        return Colors.blue;

      case "shipped":
        return Colors.purple;

      case "delivered":
        return Colors.green;

      case "cancel":
      case "cancelled":
        return Colors.red;

      case "refunded":
        return Colors.teal;

      case "pending":
        return Colors.grey;

      default:
        return Colors.grey;
    }
  }
}
