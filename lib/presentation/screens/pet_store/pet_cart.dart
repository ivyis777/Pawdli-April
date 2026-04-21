import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:pawlli/data/model/cartviewmodel.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/api service.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/presentation/screens/pet_store/placeorderpage.dart';
import '../../../data/controller/cartviewcontroller.dart';

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

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartController cartController = Get.find<CartController>();
  final RxList<int> selectedCartIds = <int>[].obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cartController.loadCart();
    });
  }

  // ------------------- QUANTITY UPDATE -------------------
  void _incrementQuantity(int index) async {
    final item = cartController.cartItems[index];
    final newQty = (item.quantity ?? 1) + 1;

    await ApiService.cartupdateURL(
      cartId: item.cartId!,
      quantity: newQty,
      item: item,
    );

    await cartController.loadCart();
  }

  void _decrementQuantity(int index) async {
    final item = cartController.cartItems[index];
    final currentQty = item.quantity ?? 1;

    if (currentQty == 1) {
      await ApiService.cartRemove(cartId: item.cartId!);

      // 🔥 REMOVE FROM SELECTED LIST ALSO
      selectedCartIds.remove(item.cartId);

      await cartController.loadCart();
      return;
    }

    final newQty = currentQty - 1;

    await ApiService.cartupdateURL(
      cartId: item.cartId!,
      quantity: newQty,
      item: item,
    );

    await cartController.loadCart();
  }

  // ------------------- TOTAL OF SELECTED ITEMS -------------------
  double _calculateSelectedTotal() {
    double total = 0.0;

    for (var item in cartController.cartItems) {
      if (selectedCartIds.contains(item.cartId)) {
        final price = double.tryParse(item.priceAtAdded ?? "0") ?? 0.0;
        total += price * (item.quantity ?? 1);
      }
    }
    return total;
  }

  // ------------------- UI -------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Stack(
          children: [
            // ✅ TOP IMAGE (BACKGROUND)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.55,
                height: 80,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://pawlli-podcasts.s3.ap-south-1.amazonaws.com/static_images/topimage.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // ✅ APP BAR ON TOP (Back button + title)
            AppBar(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent, // IMPORTANT
              foregroundColor: Colours.brownColour,

              // ✅ BACK BUTTON
              leading: Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.maybePop(context),
                ),
              ),

              title: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Cart".tr,
                  style: TextStyle(
                    fontSize: getResponsiveFont(context, 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Obx(() {
        if (cartController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (cartController.cartItems.isEmpty) {
          return  Center(
            child: Text("Your cart is empty".tr, style: TextStyle(fontSize: getResponsiveFont(context, 16))),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartController.cartItems.length,
                padding: const EdgeInsets.all(12),
                itemBuilder: (_, index) {
                  return _buildCartItem(cartController.cartItems[index], index);
                },
              ),
            ),

            // ------------------- FOOTER -------------------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Obx(() {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text("Total amount".tr,
                            style: TextStyle(
                                fontSize: getResponsiveFont(context, 14), fontWeight: FontWeight.bold)),
                        Text(
                          "₹${_calculateSelectedTotal().toStringAsFixed(2)}",
                          style: TextStyle(
                              fontSize: getResponsiveFont(context, 16), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedCartIds.isEmpty) {
                            Fluttertoast.showToast(
                              msg: "Please select at least one item".tr,
                            );
                            return;
                          }

                          Get.to(() => PlaceOrderPage(
                                selectedCartIds: selectedCartIds.toList(),
                              ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colours.primarycolour,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child:  Text(
                          "Place Order".tr,
                          style: TextStyle(fontSize: getResponsiveFont(context, 15), color: Colors.white),
                        ),
                      ),
                    )
                  ],
                );
              }),
            ),
          ],
        );
      }),
    );
  }

  // ------------------- CART ITEM WITH CHECKBOX OVER IMAGE -------------------
  Widget _buildCartItem(Data item, int index) {
    final String imageUrl = item.variantImage ?? item.productImage ?? "";
    final String discountedPrice = item.priceAtAdded ?? "0.0";
    final String regularPrice =
        item.variantDetails?["regular_price"]?.toString() ?? discountedPrice;

    // return Obx(() {
    return Card(
      elevation: 9,
      color: const Color.fromARGB(255, 251, 236, 210),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------- IMAGE + CHECKBOX -------------------
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 110,
                    height: 130,
                    color: Colours.secondarycolour, // ✅ background visible
                    padding: const EdgeInsets.all(8), // 🔥 KEY LINE
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain, // ✅ do NOT use cover
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.pets, size: 60, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: -9,
                  left: -9,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Obx(
                      () => Checkbox(
                        value: selectedCartIds.contains(item.cartId),
                        activeColor: Colours.primarycolour,
                        onChanged: (value) {
                          if (value == true) {
                            selectedCartIds.add(item.cartId!);
                          } else {
                            selectedCartIds.remove(item.cartId);
                          }
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(width: 10),

            // ------------------- DETAILS + QTY -------------------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.storeProductName ?? "",
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: getResponsiveFont(context, 14), fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 5),

                  if (item.variantName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        item.variantName!,
                        style: TextStyle(
                          fontSize: getResponsiveFont(context, 12),
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(height: 5),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (regularPrice != discountedPrice)
                        Text(
                          "₹$regularPrice",
                          style: TextStyle(
                            fontSize: getResponsiveFont(context, 13),
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Text(
                        "₹$discountedPrice",
                        style: TextStyle(
                          fontSize: getResponsiveFont(context, 15),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  // ------------------- QUANTITY BUTTONS -------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () => _decrementQuantity(index),
                        icon: CircleAvatar(
                          backgroundColor: Colours.primarycolour,
                          radius: 12,
                          child: Icon(
                            (item.quantity ?? 1) > 1
                                ? Icons.remove
                                : Icons.delete,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                      Text("${item.quantity}",
                          style: TextStyle(fontSize: getResponsiveFont(context, 13),)),
                      IconButton(
                        onPressed: () => _incrementQuantity(index),
                        icon: CircleAvatar(
                          backgroundColor: Colours.primarycolour,
                          radius: 12,
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 12),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
    // });
  }
}
