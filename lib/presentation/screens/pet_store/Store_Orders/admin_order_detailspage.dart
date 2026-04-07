import 'dart:convert';
import 'package:flutter/material.dart';
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
                  Text("Created At: ${order.createdAt}"),
                ],
              ),
            ),
          ),
        )
      ),
    );
  }
}