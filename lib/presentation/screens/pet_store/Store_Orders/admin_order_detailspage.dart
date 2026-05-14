import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/admin_ordercontroller.dart';
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

class AdminOrderDetailspage extends StatefulWidget {

  final AdminOrdermodel order;

  const AdminOrderDetailspage({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<AdminOrderDetailspage> createState() =>
      _AdminOrderDetailspageState();
}

class _AdminOrderDetailspageState
    extends State<AdminOrderDetailspage> {

  final AdminOrdercontroller controller =
      Get.find<AdminOrdercontroller>();

  late String currentStatus;

  @override
  void initState() {
    super.initState();

    currentStatus = widget.order.status;
  }

  List<String> getAvailableStatuses() {

    switch (currentStatus.toLowerCase()) {

      case "paid":
        return [
          "confirmed",
          "cancelled",
        ];

      case "confirmed":
        return [
          "shipped",
          "cancelled",
          "refunded",
        ];

      case "shipped":
        return [
          "delivered",
          "cancelled",
          "refunded",
        ];

      case "delivered":
        return [];

      case "cancelled":
        return [
          "refunded",
        ];

      case "refunded":
        return [];

      default:
        return [];
    }
  }

  Map<String, dynamic>? parseAddress(
      String? address) {

    if (address == null) return null;

    try {

      final fixed =
          address.replaceAll("'", '"');

      return json.decode(fixed);

    } catch (e) {

      return null;
    }
  }

  String formatToIndianTime(String dateTime) {

    try {

      DateTime parsed =
          DateTime.parse(dateTime).toLocal();

      return DateFormat(
        'dd MMM yyyy, hh:mm a',
      ).format(parsed);

    } catch (e) {

      return dateTime;
    }
  }

  /// STATUS COLORS
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
        return Colors.red;

      case "refunded":
        return Colors.teal;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {

    final address =
        parseAddress(
      widget.order.shippingAddress,
    );

    return Scaffold(

      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(80),

        child: Stack(
          children: [

            /// TOP IMAGE
            Positioned(
              top: 0,
              left: 0,

              child: SizedBox(
                width:
                    MediaQuery.of(context)
                            .size
                            .width *
                        0.55,

                height: 90,

                child: Image.network(
                  'https://pawlli-podcasts.s3.ap-south-1.amazonaws.com/static_images/topimage.png',
                  fit: BoxFit.cover,

                  errorBuilder:
                      (context,
                          error,
                          stackTrace) {

                    return Container(
                      color:
                          Colors.transparent,
                    );
                  },
                ),
              ),
            ),

            /// APP BAR
            AppBar(
              centerTitle: true,
              elevation: 0,

              backgroundColor:
                  Colors.transparent,

              foregroundColor:
                  Colours.brownColour,

              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                ),

                onPressed: () =>
                    Navigator.maybePop(
                        context),
              ),

              title: Text(
                "Request Details".tr,

                style: TextStyle(
                  fontSize:
                      getResponsiveFont(
                          context, 18),

                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Card(
          color:
              const Color.fromARGB(
            255,
            251,
            236,
            210,
          ),

          elevation: 2,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),

          child: Padding(
            padding:
                const EdgeInsets.all(16),

            child:
                SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  /// ORDER ID
                  Text(
                    "Order ID: ${widget.order.orderId}"
                        .tr,

                    style: TextStyle(
                      fontSize:
                          getResponsiveFont(
                              context,
                              16),

                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(
                      height: 10),

                  /// USER ID
                  Text(
                    "User ID: ${widget.order.user}"
                        .tr,

                    style: TextStyle(
                      fontSize:
                          getResponsiveFont(
                              context,
                              14),
                    ),
                  ),

                  /// TOTAL
                  Text(
                    "Total Amount: ₹${widget.order.totalAmount}"
                        .tr,

                    style: TextStyle(
                      fontSize:
                          getResponsiveFont(
                              context,
                              14),
                    ),
                  ),

                  /// FINAL
                  Text(
                    "Final Amount: ₹${widget.order.finalAmount}"
                        .tr,

                    style: TextStyle(
                      fontSize:
                          getResponsiveFont(
                              context,
                              14),
                    ),
                  ),

                  const SizedBox(
                      height: 10),

                  /// STATUS BADGE
                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          getStatusColor(
                              currentStatus),

                      borderRadius:
                          BorderRadius
                              .circular(
                                  20),
                    ),

                    child: Text(
                      currentStatus
                              .capitalizeFirst ??
                          "",

                      style: TextStyle(
                        color:
                            Colors.white,

                        fontWeight:
                            FontWeight.bold,

                        fontSize:
                            getResponsiveFont(
                                context,
                                13),
                      ),
                    ),
                  ),

                  const SizedBox(
                      height: 20),

                  /// ✅ DROPDOWN
                  if (getAvailableStatuses()
                      .isNotEmpty)

                    Obx(
                      () => Container(
                        width:
                            double.infinity,

                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              Colors.white,

                          borderRadius:
                              BorderRadius
                                  .circular(
                                      12),

                          border:
                              Border.all(
                            color: Colors
                                .grey
                                .shade300,
                          ),
                        ),

                        child:
                            DropdownButtonHideUnderline(
                          child:
                              DropdownButton<
                                  String>(

                            hint: Text(
                              "Update Order Status",

                              style:
                                  TextStyle(
                                fontSize:
                                    getResponsiveFont(
                                        context,
                                        14),

                                fontWeight:
                                    FontWeight
                                        .w500,
                              ),
                            ),

                            value: null,

                            items:
                                getAvailableStatuses()
                                    .map(
                              (status) {

                                return DropdownMenuItem<
                                    String>(

                                  value:
                                      status,

                                  child:
                                      Text(
                                    status
                                            .capitalizeFirst ??
                                        "",
                                  ),
                                );
                              },
                            ).toList(),

                            onChanged:
                                controller
                                        .isUpdating
                                        .value

                                    ? null

                                    : (value) async {

                                        if (value ==
                                            null) {
                                          return;
                                        }

                                        bool success =
                                            await controller
                                                .updateOrderStatusNow(

                                          orderId:
                                              widget
                                                  .order
                                                  .orderId,

                                          status:
                                              value,
                                        );

                                        if (success) {

                                          /// ✅ UPDATE UI INSTANTLY
                                          setState(() {

                                            currentStatus =
                                                value;
                                          });
                                        }
                                      },
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(
                      height: 20),

                  /// SHIPPING ADDRESS
                  Text(
                    "Shipping Address:",

                    style: TextStyle(
                      fontSize:
                          getResponsiveFont(
                              context,
                              15),

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                      height: 10),

                  if (address != null) ...[

                    Text(
                      "Name: ${address['name']}"
                          .tr,
                    ),

                    Text(
                      "Phone: ${address['phone']}"
                          .tr,
                    ),

                    Text(
                      "Email: ${address['email']}"
                          .tr,
                    ),

                    Text(
                      "Address: ${address['address']}"
                          .tr,
                    ),
                  ] else

                    Text(
                      widget.order.shippingAddress ??
                          "N/A",
                    ),

                  const SizedBox(
                      height: 15),

                  /// CREATED DATE
                  Text(
                    "Created At: ${formatToIndianTime(widget.order.createdAt)}"
                        .tr,

                    style: TextStyle(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                      height: 25),

                  /// ORDER ITEMS
                  Text(
                    "Order Items".tr,

                    style: TextStyle(
                      fontSize:
                          getResponsiveFont(
                              context,
                              15),

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                      height: 10),

                  ...widget.order.items
                      .map((item) {

                    return Card(
                      margin:
                          const EdgeInsets
                              .only(
                                  bottom: 12),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                10),
                      ),

                      elevation: 2,

                      child: Padding(
                        padding:
                            const EdgeInsets
                                .all(10),

                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            /// IMAGE
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(
                                      8),

                              child:
                                  Image.network(
                                item.productImage,

                                height: 100,
                                width: 70,
                                fit: BoxFit.cover,

                                errorBuilder:
                                    (context,
                                        error,
                                        stackTrace) {

                                  return Container(
                                    height: 100,
                                    width: 70,

                                    color: Colors
                                        .grey
                                        .shade200,

                                    child: const Icon(
                                      Icons
                                          .image_not_supported,
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(
                                width: 10),

                            /// DETAILS
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  Text(
                                    item.productName,

                                    style:
                                        TextStyle(
                                      fontSize:
                                          getResponsiveFont(
                                              context,
                                              14),

                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 4),

                                  Text(
                                    "Variant: ${item.variantName}"
                                        .tr,
                                  ),

                                  Text(
                                    "Qty: ${item.quantity}"
                                        .tr,
                                  ),

                                  Text(
                                    "Price: ₹${item.price}"
                                        .tr,
                                  ),

                                  Text(
                                    "Total: ₹${item.totalPrice}"
                                        .tr,
                                  ),
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
        ),
      ),
    );
  }
}