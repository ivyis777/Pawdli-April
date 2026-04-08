import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/model/admin_ordermodel.dart';

class AdminOrderDetailspage extends StatelessWidget {
  final AdminOrdermodel order;

  const AdminOrderDetailspage({Key? key, required this.order})
      : super(key: key);

  Map<String, dynamic>? parseAddress(String? address) {
    if (address == null) return null;
    try {
      final fixed = address.replaceAll("'", '"');
      return json.decode(fixed);
    } catch (e) {
      return null;
    }
  }

  String formatToIndianTime(String dateTime) {
    try {
      DateTime parsed = DateTime.parse(dateTime).toLocal();

      return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
    } catch (e) {
      return dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final address = parseAddress(order.shippingAddress);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Stack(
          children: [
            /// 🔹 TOP IMAGE (CURVE DESIGN)
            Positioned(
              top: 0,
              left: 0,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.55,
                height: 90,
                child: Image.network(
                  'https://pawlli-podcasts.s3.ap-south-1.amazonaws.com/static_images/topimage.png',
                  fit: BoxFit.cover,

                  /// ✅ prevent crash
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: Colors.transparent);
                  },
                ),
              ),
            ),

            /// 🔹 APPBAR CONTENT (ON TOP OF IMAGE)
            AppBar(
              centerTitle: true,
              elevation: 0, // keep flat like design
              backgroundColor: Colors.transparent,
              foregroundColor: Colours.brownColour,

              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.maybePop(context),
              ),

              title: const Text(
                "Request Details",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: const Color.fromARGB(255, 251, 236, 210), // ✅ your required color
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Order ID: ${order.orderId}",
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Text("User ID: ${order.user}"),
                  Text("Total Amount: ₹${order.totalAmount}"),
                  Text("Final Amount: ₹${order.finalAmount}"),
                  Text("Status: ${order.status}"),
                  const SizedBox(height: 10),

                  const Text("Shipping Address:",
                      style: TextStyle(fontWeight: FontWeight.bold)),

                  if (address != null) ...[
                    Text("Name: ${address['name']}"),
                    Text("Phone: ${address['phone']}"),
                    Text("Email: ${address['email']}"),
                    Text("Address: ${address['address']}"),
                  ] else
                    Text(order.shippingAddress ?? "N/A"),

                  const SizedBox(height: 10),
                  Text(
                    "Created At: ${formatToIndianTime(order.createdAt)}",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Order Items",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  ...order.items.map((item) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// 🔹 PRODUCT IMAGE
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.productImage,
                                height: 100,
                                width: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 100,
                                    width: 70,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.image_not_supported),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(width: 10),

                            /// 🔹 DETAILS
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text("Variant: ${item.variantName}"),
                                  Text("Qty: ${item.quantity}"),
                                  Text("Price: ₹${item.price}"),
                                  Text("Total: ₹${item.totalPrice}"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        )
      ),
    );
  }
}