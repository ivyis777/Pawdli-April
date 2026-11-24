import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/GroomingCartRemoveController.dart';
import 'package:pawlli/data/controller/GroomingCartUpdateController.dart';
import 'package:pawlli/data/model/ServiceCartModel.dart';
import 'package:pawlli/data/controller/ServiceAddToCartController.dart';
import 'package:pawlli/presentation/screens/PetGrooming/BuildPlans/GroomingBookingPage.dart';
import 'package:pawlli/presentation/screens/PetGrooming/CartCheckoutpage.dart';
import 'package:pawlli/presentation/screens/PetGrooming/GroomingMainPage.dart';
import 'package:pawlli/presentation/screens/PetGrooming/OneTimeService/GroomingOneTimeServicePage.dart';

class GroomingCartPage extends StatefulWidget {
  const GroomingCartPage({super.key});

  @override
  State<GroomingCartPage> createState() => _GroomingCartPageState();
}

class _GroomingCartPageState extends State<GroomingCartPage> {
  final GroomingAddToCartController cartController =
      GroomingAddToCartController();
  final GroomingCartUpdateController updateController =
      GroomingCartUpdateController();
  final GroomingCartRemoveController removeController =
      GroomingCartRemoveController();

  bool isLoading = true;
  String? errorMessage;

  List<GroomingCartItemModel> get cartItems =>
      cartController.cartItems;

  int get totalPrice => cartController.totalPrice.round();

  @override
  void initState() {
    super.initState();
    cartController.addListener(_onCartChanged);
    _loadCart();
  }

  void _onCartChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _goToPetServicesPage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const PetServicesPage(),
      ),
      (route) => false,
    );
  }

  Future<void> _loadCart() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    final success = await cartController.fetchCart();

    if (!mounted) return;

    setState(() {
      isLoading = false;
      if (!success) {
        errorMessage = cartController.cartErrorMessage ??
            'Unable to load grooming cart.';
      }
    });
  }

  
  Future<void> _editPlan(GroomingCartItemModel item) async {
    final serviceType = item.serviceType.toUpperCase();

    // One-Time service: open the One-Time grooming flow.
    if (serviceType == 'ONE_TIME') {
      final groupItems = cartItems.where((cartItem) {
        return cartItem.serviceType.toUpperCase() == 'ONE_TIME' &&
            cartItem.oneTimePackageId != null &&
            item.oneTimePackageId != null;
      }).toList();

      await _editOneTimeGroup(
        groupItems.isNotEmpty ? groupItems : [item],
      );

      return;
    }

    // Build Plan: preserve the existing edit flow.
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BuildPlanBookingPage(
          serviceName: item.serviceName,
          serviceId: item.serviceId,
          editCartItemId: item.cartItemId,
          existingCartItem: item,
        ),
      ),
    );

    if (!mounted) return;

    if (updated == true) {
      await _loadCart();
    }
  }


  Future<void> _editOneTimeGroup(
    List<GroomingCartItemModel> items,
  ) async {
    if (items.isEmpty) return;

    // Use the first item for shared pet, address and contact details.
    final firstItem = items.first;

    // Collect every package ID in this One-Time group.
    final packageIds = items
        .map((item) => item.oneTimePackageId)
        .whereType<int>()
        .where((id) => id > 0)
        .toSet()
        .toList();

    if (packageIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No valid One-Time package IDs were found.'),
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OneTimeGroomingServicePage(
          editCartItemId: firstItem.cartItemId,
          existingCartItem: firstItem,
          existingPackageIds: packageIds,
          existingCartItems: items,
        ),
      ),
    );

    if (!mounted) return;

    await _loadCart();
  }



  @override
  void dispose() {
    cartController.removeListener(_onCartChanged);
    cartController.dispose();
    updateController.dispose();
    removeController.dispose();
    super.dispose();
  }

  
  
  Future<void> _deletePlan(int cartItemId) async {
    if (!mounted || removeController.isLoading) return;

    // DELETE CONFIRMATION DIALOG
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colours.primarycolour,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/DeleteGroomingService.png',
                  height: 140,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 15),

                const Text(
                  'Are you sure you want to delete this grooming plan?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colours.primarycolour,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(dialogContext, false);
                        },
                        child: Text(
                          'Close',
                          style: TextStyle(
                            color: Colours.primarycolour,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colours.primarycolour,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(dialogContext, true);
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;

    // EXISTING DELETE API - UNCHANGED
    final success = await removeController.removeCartItem(
      cartId: cartItemId,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            removeController.result?.message ??
                'Grooming plan removed successfully.',
          ),
        ),
      );

      await _loadCart();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            removeController.errorMessage ??
                'Unable to remove grooming plan.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  
  Future<void> _deleteOneTimeGroup(
    List<GroomingCartItemModel> items,
  ) async {
    if (items.isEmpty ||
        !mounted ||
        removeController.isLoading) {
      return;
    }

    // DELETE CONFIRMATION DIALOG
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colours.primarycolour,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/DeleteGroomingService.png',
                  height: 140,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 15),

                Text(
                  'Are you sure you want to delete all '
                  '${items.length} One-Time services?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colours.primarycolour,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(dialogContext, false);
                        },
                        child: Text(
                          'Close',
                          style: TextStyle(
                            color: Colours.primarycolour,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colours.primarycolour,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(dialogContext, true);
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;

    // EXISTING DELETE API - UNCHANGED
    for (final item in items) {
      final success = await removeController.removeCartItem(
        cartId: item.cartItemId,
      );

      if (!success) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              removeController.errorMessage ??
                  'Unable to remove ${item.packageName}.',
            ),
            backgroundColor: Colors.red,
          ),
        );

        await _loadCart();
        return;
      }
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('One-Time services removed successfully.'),
      ),
    );

    await _loadCart();
  }
  
  Future<void> _confirmAndPay() async {
    if (cartItems.isEmpty) return;

    // Get all selected cart item IDs.
    final cartIds = cartItems
        .map((item) => item.cartItemId)
        .where((id) => id > 0)
        .toSet()
        .toList();

    if (cartIds.isEmpty) return;

    // Preserve pet names from the existing cart response.
    final Map<int, String> petNames = {
      for (final item in cartItems)
        item.cartItemId: item.petName,
    };

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => GroomingCheckoutPage(
          cartIds: cartIds,
          petNames: petNames,
          walletBalance: 0,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await _loadCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goToPetServicesPage();
      },
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: _goToPetServicesPage,
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 21,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Cart (${cartItems.length})',
          style: TextStyle(
            color: Colours.brownColour,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadCart,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : cartItems.isEmpty
                  ? _emptyCart()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      itemCount: _displayCartItems().length,
                      itemBuilder: (context, index) {
                        final entry = _displayCartItems()[index];

                        if (entry is List<GroomingCartItemModel>) {
                          return _oneTimeGroupCard(entry);
                        }

                        return _planCard(entry as GroomingCartItemModel);
                      },
                    ),

      bottomNavigationBar:
          !isLoading &&
                  errorMessage == null &&
                  cartItems.isNotEmpty
              ? SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                      18, 14, 18, 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Total (${cartItems.length} plans)',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colours.brownColour,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '₹$totalPrice',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _confirmAndPay,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colours.primarycolour,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Confirm & Pay',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
    ),
    );
  }

  List<Object> _displayCartItems() {
    final List<Object> result = [];

    // Keep each main_cart_id separate.
    for (final cart in cartController.carts) {
      final List<GroomingCartItemModel> oneTimeItems = [];

      for (final item in cart.items) {
        if (item.serviceType.toUpperCase() == 'ONE_TIME') {
          oneTimeItems.add(item);
        } else {
          result.add(item);
        }
      }

      // Group One-Time services only within this main cart.
      if (oneTimeItems.isNotEmpty) {
        result.add(oneTimeItems);
      }
    }

    return result;
  }

  
  Widget _oneTimeGroupCard(List<GroomingCartItemModel> items) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final firstItem = items.first;
    final firstSession = firstItem.sessions.isNotEmpty
        ? firstItem.sessions.first
        : null;

    final total = items.fold<double>(
      0,
      (sum, item) => sum + item.price,
    );

    final rawDate = firstSession?.scheduledDate ?? '';
    final rawTime = firstSession?.startTime ?? '';

    String formattedDate = rawDate;
    try {
      if (rawDate.isNotEmpty) {
        formattedDate =
            DateFormat('EEE, MMM d').format(DateTime.parse(rawDate));
      }
    } catch (_) {}

    final address = firstItem.completeAddress.trim().isNotEmpty
        ? firstItem.completeAddress
        : [
            firstItem.houseNumber,
            firstItem.locality,
            firstItem.area,
            firstItem.landmark,
          ].where((value) => value.trim().isNotEmpty).join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colours.brownColour.withValues(alpha: 0.75),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            color: Colours.primarycolour.withValues(alpha: 0.15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'One Time Services',
                  style: TextStyle(
                    color: Colours.brownColour,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '₹${total.round()}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service names and prices
                ...items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Container(
                      padding: const EdgeInsets.only(left: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.grey.shade300,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.packageName.isNotEmpty
                                  ? item.packageName
                                  : item.serviceName,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF384253),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '₹${item.price.round()}/-',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF384253),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 8),

                Divider(
                  color: Colors.grey.shade300,
                  thickness: 1,
                ),

                const SizedBox(height: 16),

                _detailRow(
                  Icons.pets_outlined,
                  'Pet',
                  '${firstItem.petName} (${firstItem.breedName})',
                ),

                const SizedBox(height: 16),

                _detailRow(
                  Icons.access_time,
                  'Date & Time',
                  firstSession == null
                      ? 'Schedule not available'
                      : '$formattedDate - $rawTime',
                ),

                const SizedBox(height: 16),

                _detailRow(
                  Icons.location_on_outlined,
                  'Address',
                  address.isEmpty ? 'Not provided' : address,
                ),

                const SizedBox(height: 20),

                // Bottom actions only, matching the existing cart style.
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _editOneTimeGroup(items),
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 19,
                      ),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colours.brownColour,
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const Spacer(),

                    TextButton.icon(
                      onPressed: () => _deleteOneTimeGroup(items),
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 19,
                      ),
                      label: const Text('Delete Plan'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _planCard(GroomingCartItemModel item) {
    final firstSession =
        item.sessions.isNotEmpty ? item.sessions.first : null;

    final String rawDate = firstSession?.scheduledDate ?? '';
    final String rawTime = firstSession?.startTime ?? '';

    String formattedDate = rawDate;

    try {
      if (rawDate.isNotEmpty) {
        formattedDate = DateFormat('dd MMM yyyy').format(
          DateTime.parse(rawDate),
        );
      }
    } catch (_) {
      // Keep the original date if parsing fails.
    }

    final String address = item.completeAddress.trim().isNotEmpty
        ? item.completeAddress
        : [
            item.houseNumber,
            item.locality,
            item.area,
            item.landmark,
          ].where((value) => value.trim().isNotEmpty).join(', ');

    final String petDetails = [
      item.petName,
      item.breedName,
    ].where((value) => value.trim().isNotEmpty).join(' (');

    final String formattedPetDetails =
        item.petName.trim().isNotEmpty &&
                item.breedName.trim().isNotEmpty
            ? '${item.petName} (${item.breedName})'
            : item.petName.trim().isNotEmpty
                ? item.petName
                : item.breedName.trim().isNotEmpty
                    ? item.breedName
                    : 'Not provided';

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colours.brownColour.withValues(alpha: 0.75),
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.serviceName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colours.brownColour,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Price',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '₹${item.price.round()}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 10),

          _detailRow(
            Icons.pets_outlined,
            'Pet',
            formattedPetDetails,
          ),

          const SizedBox(height: 14),

          _detailRow(
            Icons.event_repeat,
            'Sessions / Duration',
            item.sessionsPerMonth == null ||
                    item.numberOfMonths == null
                ? 'Not applicable'
                : '${item.sessionsPerMonth} sessions / month'
                    ' • ${item.numberOfMonths} months',
          ),

          const SizedBox(height: 14),

          _detailRow(
            Icons.calendar_month_outlined,
            'Total Sessions',
            '${item.totalSessions} sessions',
          ),

          const SizedBox(height: 14),

          _detailRow(
            Icons.access_time,
            'Date & Time',
            firstSession == null
                ? 'Schedule not available'
                : '${formattedDate.isEmpty ? 'Date not available' : formattedDate}'
                    '\n${rawTime.isEmpty ? 'Time not available' : rawTime}',
          ),

          const SizedBox(height: 14),

          _detailRow(
            Icons.location_on_outlined,
            'Address',
            address.isEmpty ? 'Not provided' : address,
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              // LEFT BOTTOM: EDIT
              TextButton.icon(
                onPressed: () => _editPlan(item),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 19,
                ),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: Colours.brownColour,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Spacer(),

              // RIGHT BOTTOM: DELETE
              TextButton.icon(
                onPressed: () => _deletePlan(item.cartItemId),
                icon: const Icon(
                  Icons.delete_outline,
                  size: 19,
                ),
                label: const Text('Delete Plan'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  // Widget _oneTimePlanCard(GroomingCartItemModel item) {
  //   final firstSession =
  //       item.sessions.isNotEmpty ? item.sessions.first : null;

  //   final rawDate = firstSession?.scheduledDate ?? '';
  //   final rawTime = firstSession?.startTime ?? '';

  //   String formattedDate = rawDate;

  //   try {
  //     if (rawDate.isNotEmpty) {
  //       formattedDate =
  //           DateFormat('EEE, MMM d').format(DateTime.parse(rawDate));
  //     }
  //   } catch (_) {}

  //   final address = item.completeAddress.trim().isNotEmpty
  //       ? item.completeAddress
  //       : [
  //           item.houseNumber,
  //           item.locality,
  //           item.area,
  //           item.landmark,
  //         ].where((value) => value.trim().isNotEmpty).join(', ');

  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 20),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(20),
  //       border: Border.all(color: Colors.grey.shade300),
  //     ),
  //     clipBehavior: Clip.antiAlias,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // Services header
  //         Container(
  //           width: double.infinity,
  //           padding: const EdgeInsets.symmetric(
  //             horizontal: 20,
  //             vertical: 18,
  //           ),
  //           decoration: const BoxDecoration(
  //             gradient: LinearGradient(
  //               colors: [
  //                 Color(0xFFFFE9E1),
  //                 Color(0xFFFFD1B8),
  //               ],
  //             ),
  //           ),
  //           child: const Row(
  //             children: [
  //               Text('✨', style: TextStyle(fontSize: 25)),
  //               SizedBox(width: 12),
  //               Text(
  //                 'Services',
  //                 style: TextStyle(
  //                   color: Color(0xFFCB4B0A),
  //                   fontSize: 17,
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),

  //         Padding(
  //           padding: const EdgeInsets.all(20),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 item.serviceName,
  //                 style: const TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.w600,
  //                   color: Color(0xFF384253),
  //                 ),
  //               ),

  //               const SizedBox(height: 18),

  //               // Package row
  //               Container(
  //                 padding: const EdgeInsets.only(left: 12),
  //                 decoration: BoxDecoration(
  //                   border: Border(
  //                     left: BorderSide(
  //                       color: Colors.grey.shade300,
  //                       width: 3,
  //                     ),
  //                   ),
  //                 ),
  //                 child: Row(
  //                   children: [
  //                     Expanded(
  //                       child: Text(
  //                         item.serviceName,
  //                         style: const TextStyle(
  //                           fontSize: 16,
  //                           color: Color(0xFF384253),
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(width: 10),
  //                     Text(
  //                       '₹${item.price.round()}/-',
  //                       style: const TextStyle(
  //                         fontSize: 17,
  //                         fontWeight: FontWeight.w700,
  //                         color: Color(0xFF384253),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),

  //               const SizedBox(height: 22),
  //               Divider(
  //                 color: Colors.grey.shade300,
  //                 thickness: 1,
  //                 height: 1,
  //               ),
  //               const SizedBox(height: 20),

  //               _detailRow(
  //                 Icons.pets_outlined,
  //                 'Pet',
  //                 item.petId > 0 ? 'Pet ID: ${item.petId}' : 'Not provided',
  //               ),

  //               const SizedBox(height: 16),

  //               _detailRow(
  //                 Icons.access_time,
  //                 'Date & Time',
  //                 firstSession == null
  //                     ? 'Schedule not available'
  //                     : '$formattedDate - $rawTime',
  //               ),

  //               const SizedBox(height: 16),

  //               _detailRow(
  //                 Icons.home_outlined,
  //                 'Address',
  //                 address.isEmpty ? 'Not provided' : address,
  //               ),

  //               const SizedBox(height: 20),

  //               Row(
  //                 children: [
  //                   OutlinedButton(
  //                     onPressed: () => _editPlan(item),
  //                     style: OutlinedButton.styleFrom(
  //                       foregroundColor: const Color(0xFFAC50FF),
  //                       side: const BorderSide(
  //                         color: Color(0xFFAC50FF),
  //                         width: 1.5,
  //                       ),
  //                       padding: const EdgeInsets.symmetric(
  //                         horizontal: 24,
  //                         vertical: 14,
  //                       ),
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(16),
  //                       ),
  //                     ),
  //                     child: const Text(
  //                       'Edit Plan',
  //                       style: TextStyle(fontSize: 16),
  //                     ),
  //                   ),

  //                   const Spacer(),

  //                   IconButton(
  //                     onPressed: () => _deletePlan(item.cartItemId),
  //                     icon: const Icon(
  //                       Icons.delete_outline,
  //                       color: Colors.red,
  //                       size: 28,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }



  Widget _detailRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colours.primarycolour,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _emptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 65,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 14),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add grooming services to book them together.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: _goToPetServicesPage,
              child: const Text('Continue Booking'),
            ),
          ],
        ),
      ),
    );
  }
}
