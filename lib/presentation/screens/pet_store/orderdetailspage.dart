import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pawlli/core/storage_manager/LocalStorageConstants.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/cart%20payment/storecheckoutservice.dart';
import 'package:pawlli/data/model/ordermodel.dart';
import 'package:pawlli/data/model/rating_review_model.dart';
import 'package:pawlli/presentation/screens/homepage/homepage.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsPage extends StatefulWidget {
  final Order order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final TextEditingController _reasonController = TextEditingController();
  bool isLoading = false;
  late String currentStatus;

  Map<int, double> ratings = {};
  Map<int, TextEditingController> reviewControllers = {};
  Map<int, bool> submittedReviews = {};

  @override
    void initState() {
      super.initState();

      currentStatus = widget.order.orderStatus;

      for (var item in widget.order.items) {

        ratings[item.productId] = 0;

        reviewControllers[item.productId] =
            TextEditingController();

        submittedReviews[item.productId] = false;
      }
    }

    Future<void> submitReview(item) async {

      final comment =
          reviewControllers[item.productId]?.text.trim() ?? "";

      if ((ratings[item.productId] ?? 0) == 0) {

        Get.snackbar(
          "Error",
          "Please select rating",
        );

        return;
      }

      if (comment.isEmpty) {
        Get.snackbar("Error", "Please enter review");
        return;
      }

      final review = RatingReviewModel(
        productId: item.productId,
        orderId: widget.order.orderId,
        rating: ratings[item.productId]!.toInt(),
        comment: comment,
      );

      String token = LocalStorage.getAccessToken() ?? "";

      bool success =
          await ApiService.submitReview(
        review,
        token,
      );

      if (success) {

        setState(() {
          submittedReviews[item.productId] = true;
        });

        Get.snackbar(
          "Success",
          "Review submitted successfully",
        );

      } else {

        Get.snackbar(
          "Error",
          "Failed to submit review",
        );
      }
    }

    @override
      void dispose() {

        for (var controller in reviewControllers.values) {
          controller.dispose();
        }

        _reasonController.dispose();

        super.dispose();
      }

  Future<void> _contactUs() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'contact@pawdli.com',
      // queryParameters: {
      //   'subject': 'Order Support',
      //   'body': 'Hi, I need help regarding my cancelled order.',
      // },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      Get.snackbar("Error", "Could not open email app");
    }
  }

  Future<void> _downloadInvoice() async {
    try {
      Get.snackbar("Please wait", "Downloading invoice...".tr);

      await StoreCheckoutService.downloadInvoice(
        orderId: widget.order.orderId.toString(),
      );

      Get.snackbar("Success", "Invoice downloaded".tr);
    } catch (e) {
      Get.snackbar("Error", "Failed to download invoice".tr);
    }
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:  Text("Cancel Order".tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Text("Please provide reason for cancellation".tr),
              const SizedBox(height: 10),
              TextField(
                controller: _reasonController,
                maxLines: 3,
                decoration:  InputDecoration(
                  hintText: "Enter reason".tr,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:  Text("Close".tr),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_reasonController.text.trim().isEmpty) {
                  Get.snackbar("Error", "Reason is required".tr);
                  return;
                }

                setState(() => isLoading = true);

                bool success = await StoreCheckoutService.cancelOrder(
                  orderId: widget.order.orderId.toString(),
                  reason: _reasonController.text.trim(),
                );

                setState(() => isLoading = false);

                if (success) {
                  Navigator.pop(context);

                  setState(() {
                    currentStatus = "Order Cancelled";
                  });

                  Get.snackbar("Success", "Order cancelled successfully".tr);
                }else {
                  Get.snackbar("Error", "Failed to cancel order".tr);
                }
              },
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  :  Text("Confirm".tr),
            ),
          ],
        );
      },
    );
  }

  Map<String, dynamic>? _parseAddress(String? rawAddress) {
    if (rawAddress == null || rawAddress.isEmpty) return null;

    try {
      final fixed = rawAddress.replaceAll("'", "\"");
      return jsonDecode(fixed);
    } catch (e) {
      return null;
    }
  }

    Color getStatusColor(String status) {

      switch (status.toLowerCase()) {

        case "paid":
          return Colors.orange;

        case "confirmed":
          return Colors.blue;

        case "shipped":
          return Colors.purple;

        case "delivered":
          return Colors.green;

        case "cancelled":
        case "order cancelled":
          return Colors.red;

        case "refunded":
          return Colors.teal;

        case "pending":
          return Colors.grey;

        default:
          return Colors.grey;
      }
    }

  Widget _addressCard(String title, String? addressString) {
    final address = _parseAddress(addressString);

    if (address == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
           Text("No address provided".tr),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              address['name'.tr] ?? "",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(address['phone'.tr] ?? ""),
            // Text(address['email'] ?? ""),
            const SizedBox(height: 6),
            Text(address['address'.tr] ?? ""),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // final item = widget.order.items.first;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Stack(
          children: [
            // ✅ BACKGROUND IMAGE
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.55,
                height: 80,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://app.pawdli.com/media/static/topimage.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // ✅ APP BAR ON TOP
            AppBar(
              centerTitle: true,
              title:  Text("Order Details".tr),
              backgroundColor: Colors.transparent, // important
              foregroundColor: Colours.brownColour,
              elevation: 0,

              actions: [
                PopupMenuButton<String>(
                  color: const Color.fromARGB(255, 251, 236, 210),
                  onSelected: (value) {
                    if (value == "cancel") {
                      _showCancelDialog();
                    } else if (value == "invoice") {
                      _downloadInvoice();
                    } else if (value == "contact") {
                      _contactUs();
                    }
                  },
                  itemBuilder: (context) => [

                    if (currentStatus.toLowerCase() == "delivered")
                      PopupMenuItem(
                        value: "invoice",
                        child: Text("Download Invoice".tr),
                      ),

                    if (currentStatus.toLowerCase() == "paid")
                      PopupMenuItem(
                        value: "cancel",
                        child: Text("Cancel Order".tr),
                      ),

                    PopupMenuItem(
                      value: "contact",
                      child: Text("Contact Us".tr),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Info
            Column(
              children: widget.order.items.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                  children: [

                    Row(
                      children: [

                        // ⭐ Product Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Builder(
                            builder: (_) {

                              String imageUrl = "";

                              if (item.variantImages.isNotEmpty) {
                                imageUrl = item.variantImages.first;
                              }

                              else if (item.productImage != null &&
                                  item.productImage!.isNotEmpty) {
                                imageUrl = item.productImage!;
                              }

                              else if (item.productImages.isNotEmpty) {
                                imageUrl = item.productImages.first;
                              }

                              else {
                                imageUrl = "https://picsum.photos/80";
                              }

                              return Image.network(
                                imageUrl,
                                height: 70,
                                width: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image, size: 40),
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        // ⭐ Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                item.productName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Row(
                                children: [

                                  Expanded(
                                    child: Text(
                                      "${item.variantName}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),

                                  Text(
                                    "Qty: ${item.quantity}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // REVIEW SECTION
                    if (currentStatus.toLowerCase() == "delivered") ...[

                      const SizedBox(height: 15),

                      if (submittedReviews[item.productId] == true)

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "Review Submitted",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )

                      else

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const Divider(),

                            const Text(
                              "Rate this product",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),

                            const SizedBox(height: 10),

                            RatingBar.builder(

                              initialRating:
                                  ratings[item.productId] ?? 0,

                              minRating: 1,

                              itemCount: 5,

                              allowHalfRating: false,

                              itemBuilder: (context, _) =>
                                  const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),

                              onRatingUpdate: (rating) {

                                setState(() {
                                  ratings[item.productId] = rating;
                                });
                              },
                            ),

                            const SizedBox(height: 12),

                            TextField(

                              controller:
                                  reviewControllers[item.productId],

                              maxLines: 3,

                              decoration: InputDecoration(
                                hintText: "Write your review",

                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              height: 45,

                              child: ElevatedButton(

                                onPressed: () {
                                  submitReview(item);
                                },

                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colours.primarycolour,
                                ),

                                child: const Text(
                                  "Submit Review",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ],
                ),
                );
              }).toList(),
            ),
            Divider(),

            // Payment and Order Info
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),

              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [

                  Text(
                    "Order Status",

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(
                      color: getStatusColor(currentStatus),

                      borderRadius:
                          BorderRadius.circular(20),
                    ),

                    child: Text(
                      currentStatus.capitalizeFirst ?? "",

                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _infoRow("Amount Paid", "₹${widget.order.finalAmount}"),
            _infoRow(
              "Order Date",
              DateFormat("dd MMM yyyy, hh:mm a")
                  .format(widget.order.createdAt.toLocal()),
            ),
            const SizedBox(height: 20),

            Divider(),

            // Shipping Address
            _addressCard("Shipping Address", widget.order.shippingAddress),
            Divider(),

            // Billing Address
            // _addressCard("Billing Address", widget.order.billingAddress),
            // const SizedBox(height: 100), // space for bottom button
          ],
        ),
      ),

      // BOTTOM BUTTON
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HomePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colours.primarycolour,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child:  Text(
                "Goto home...".tr,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
