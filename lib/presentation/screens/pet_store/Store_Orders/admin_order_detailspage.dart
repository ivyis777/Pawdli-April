import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/model/admin_ordermodel.dart';

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

              title: Text(
                "Request Details".tr,
                style: TextStyle(
                  fontSize: getResponsiveFont(context, 18),
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
                  Text("Order ID: ${order.orderId}".tr,
                      style: TextStyle(fontSize: getResponsiveFont(context, 16),fontWeight: FontWeight.w600,)),
                  const SizedBox(height: 10),
                  Text("User ID: ${order.user}".tr,style: TextStyle(fontSize: getResponsiveFont(context, 14)),),
                  Text("Total Amount: ₹${order.totalAmount}".tr,style: TextStyle(fontSize: getResponsiveFont(context, 14)),),
                  Text("Final Amount: ₹${order.finalAmount}".tr,style: TextStyle(fontSize: getResponsiveFont(context, 14)),),
                  Text("Status: ${order.status}".tr,style: TextStyle(fontSize: getResponsiveFont(context, 14)),),
                  const SizedBox(height: 10),

                  Text("Shipping Address:",
                      style: TextStyle(fontSize: getResponsiveFont(context, 15),
                        fontWeight: FontWeight.bold)),

                  if (address != null) ...[
                    Text("Name: ${address['name']}".tr,style: TextStyle(fontSize: getResponsiveFont(context, 13)),),
                    Text("Phone: ${address['phone']}".tr,style: TextStyle(fontSize: getResponsiveFont(context, 13)),),
                    Text("Email: ${address['email']}".tr,style: TextStyle(fontSize: getResponsiveFont(context, 13)),),
                    Text("Address: ${address['address']}".tr,style: TextStyle(fontSize: getResponsiveFont(context, 13)),),
                  ] else
                    Text(order.shippingAddress ?? "N/A", style: TextStyle(fontSize: getResponsiveFont(context, 13)),),

                  const SizedBox(height: 10),
                  Text(
                    "Created At: ${formatToIndianTime(order.createdAt)}".tr,
                    style: TextStyle(fontSize: getResponsiveFont(context, 13),
                      fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 20),

                   Text(
                    "Order Items".tr,
                    style: TextStyle(fontSize: getResponsiveFont(context, 15), fontWeight: FontWeight.bold),
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
                                    style: TextStyle(
                                        fontSize: getResponsiveFont(context, 14), fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text("Variant: ${item.variantName}".tr, style: TextStyle(fontSize: getResponsiveFont(context, 13))),

                                  Text("Qty: ${item.quantity}".tr, style: TextStyle(fontSize: getResponsiveFont(context, 13))),

                                  Text("Price: ₹${item.price}".tr, style: TextStyle(fontSize: getResponsiveFont(context, 13))),

                                  Text("Total: ₹${item.totalPrice}".tr, style: TextStyle(fontSize: getResponsiveFont(context, 13))),

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