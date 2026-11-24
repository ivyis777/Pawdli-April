
import 'package:flutter/material.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/ServiceAddToCartController.dart';
import 'package:pawlli/presentation/screens/PetGrooming/ServiceCartPage.dart';

class FloatingGroomingCart extends StatefulWidget {
  const FloatingGroomingCart({super.key});

  @override
  State<FloatingGroomingCart> createState() =>
      _FloatingGroomingCartState();
}

class _FloatingGroomingCartState extends State<FloatingGroomingCart> {
  final GroomingAddToCartController cartController =
      GroomingAddToCartController();

  int count = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCartCount();
  }

  Future<void> loadCartCount() async {
    try {
      final success = await cartController.fetchCart();

      if (!mounted) return;

      setState(() {
        count = success ? cartController.cartItems.length : 0;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        count = 0;
        isLoading = false;
      });

      debugPrint('Failed to load grooming cart count: $e');
    }
  }

  @override
  void dispose() {
    cartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || count == 0) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;

    final cartWidth = (screenWidth * 0.40).clamp(180.0, 260.0);
    final cartHeight = (screenWidth * 0.10).clamp(56.0, 78.0);
    final imageSize = cartHeight * 0.68;
    final arrowRadius = cartHeight * 0.30;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 20,
      child: Center(
        child: Material(
          color: Colours.brownColour,
          elevation: 4,
          shadowColor: Colors.black26,
          borderRadius: BorderRadius.circular(50),
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const GroomingCartPage(),
                ),
              );

              if (mounted) {
                await loadCartCount();
              }
            },
            child: SizedBox(
              width: cartWidth,
              height: cartHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Container(
                      width: imageSize,
                      height: imageSize,
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colours.primarycolour,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: Colours.brownColour,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'View cart',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$count ${count == 1 ? 'Item' : 'Items'}',
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: arrowRadius,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: arrowRadius - 2,
                        backgroundColor: Colours.primarycolour,
                        child: Icon(
                          Icons.chevron_right,
                          color: Colours.brownColour,
                          size: arrowRadius * 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
