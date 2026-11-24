
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/controller/GroomingCartUpdateController.dart';
import 'package:pawlli/data/controller/ServiceAddToCartController.dart';
import 'package:pawlli/data/controller/ServiceSlotsController.dart';
import 'package:pawlli/data/model/GroomingAddressModel.dart';
import 'package:pawlli/data/model/GroomingCartUpdateModel.dart';
import 'package:pawlli/data/model/ServiceCartModel.dart';
import 'package:pawlli/presentation/screens/PetGrooming/ServiceCartPage.dart';

class OneTimeGroomingSlotSelectionPage extends StatefulWidget {
  final String serviceName;
  final int selectedSession;
  final int selectedDuration;
  final int totalSessions;
  final int totalPrice;
  final String selectedPet;
  final int petId;
  final String peopleComfortLevel;
  final String dogsComfortLevel;
  final AddressModel selectedAddress;
  final String contactNumber;
  final double latitude;
  final double longitude;
  final List<Map<String, dynamic>> selectedServices;
  final int mainServiceId;
  final int? editCartItemId;
  final GroomingCartItemModel? existingCartItem;
  final List<int> existingPackageIds;
  final List<GroomingCartItemModel> existingCartItems;

  const OneTimeGroomingSlotSelectionPage({
    super.key,
    required this.serviceName,
    required this.selectedSession,
    required this.selectedDuration,
    required this.totalSessions,
    required this.totalPrice,
    required this.selectedPet,
    required this.petId,
    required this.peopleComfortLevel,
    required this.dogsComfortLevel,
    required this.selectedAddress,
    required this.contactNumber,
    required this.latitude,
    required this.longitude,
    required this.selectedServices,
    required this.mainServiceId,
    this.editCartItemId,
    this.existingCartItem,
    this.existingPackageIds = const [],
    this.existingCartItems = const [],
  });

  @override
  State<OneTimeGroomingSlotSelectionPage> createState() =>
      _OneTimeGroomingSlotSelectionPageState();
}

class _OneTimeGroomingSlotSelectionPageState
    extends State<OneTimeGroomingSlotSelectionPage> {
  int selectedDateIndex = 0;
  String selectedTime = '';

  List<DateTime> dates = [];

  final Map<String, List<String>> _timesByDate = {};

  DateTime displayedMonth = DateTime.now();

  final AvailableServiceSlotController slotController =
      AvailableServiceSlotController();

  final GroomingAddToCartController cartController =
      GroomingAddToCartController();

  final GroomingCartUpdateController updateController =
      GroomingCartUpdateController();

  bool isAddingToCart = false;

  
  
  @override
  void initState() {
    super.initState();
    _loadSlotsAndRestoreSelection();
  }

  String _formatApiDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatApiMonth(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}';
  }

  Future<void> _loadMonth(
    DateTime month, {
    String? preferredDate,
    String? preferredTime,
  }) async {
    setState(() {
      displayedMonth = DateTime(month.year, month.month);
    });

    final fetchFuture = slotController.fetchSlots(
      mainServiceId: widget.mainServiceId,
      month: month,
    );

    if (mounted) {
      setState(() {});
    }

    try {
      await fetchFuture;

      if (!mounted) return;

      if (slotController.errorMessage != null) {
        setState(() {});
        return;
      }

      final loadedTimes = <String, List<String>>{};

      for (final availableDate in slotController.availableDates) {
        loadedTimes[availableDate.date] =
            List<String>.from(availableDate.slots);
      }

      final loadedDates = slotController.availableDates
          .where((item) => item.slots.isNotEmpty)
          .map((item) => item.parsedDate)
          .whereType<DateTime>()
          .toList()
        ..sort((a, b) => a.compareTo(b));

      setState(() {
        _timesByDate.addAll(loadedTimes);
        dates = loadedDates;

        if (dates.isEmpty) {
          selectedDateIndex = 0;
          selectedTime = '';
          return;
        }

        var index = -1;

        if (preferredDate != null) {
          index = dates.indexWhere(
            (date) => _formatApiDate(date) == preferredDate,
          );
        }

        selectedDateIndex = index >= 0 ? index : 0;

        final dateString =
            _formatApiDate(dates[selectedDateIndex]);

        final times = _timesByDate[dateString] ?? [];

        selectedTime =
            preferredTime != null && times.contains(preferredTime)
                ? preferredTime
                : '';
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load available slots: $e'),
        ),
      );
    }
  }

  Future<void> _loadSlotsAndRestoreSelection() async {
    final existingSessions =
        widget.existingCartItem?.sessions ?? [];

    String? savedDate;
    String? savedTime;

    if (existingSessions.isNotEmpty) {
      final session = existingSessions.first;
      final parsedDate = DateTime.tryParse(session.scheduledDate);

      if (parsedDate != null) {
        savedDate = _formatApiDate(parsedDate);
        displayedMonth = DateTime(
          parsedDate.year,
          parsedDate.month,
        );
      }

      savedTime = _normalizeSavedTime(session.startTime);
    }

    await _loadMonth(
      displayedMonth,
      preferredDate: savedDate,
      preferredTime: savedTime,
    );
  }

  String? _normalizeSavedTime(String value) {
    final trimmed = value.trim();

    // API time: 13:30 or database time: 13:30:00.
    final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(trimmed);

    if (match != null) {
      final hour = int.tryParse(match.group(1)!);
      final minute = int.tryParse(match.group(2)!);

      if (hour != null &&
          minute != null &&
          hour >= 0 &&
          hour <= 23 &&
          minute >= 0 &&
          minute <= 59) {
        return '${hour.toString().padLeft(2, '0')}:'
            '${minute.toString().padLeft(2, '0')}';
      }
    }

    // Convert saved display times such as 1:30 PM.
    final parts = trimmed.split(RegExp(r'\s+'));

    if (parts.length == 2) {
      final timeParts = parts[0].split(':');

      if (timeParts.length == 2) {
        var hour = int.tryParse(timeParts[0]);
        final minute = int.tryParse(timeParts[1]);
        final period = parts[1].toUpperCase();

        if (hour != null &&
            minute != null &&
            hour >= 1 &&
            hour <= 12 &&
            minute >= 0 &&
            minute <= 59 &&
            (period == 'AM' || period == 'PM')) {
          if (period == 'PM' && hour != 12) hour += 12;
          if (period == 'AM' && hour == 12) hour = 0;

          return '${hour.toString().padLeft(2, '0')}:'
              '${minute.toString().padLeft(2, '0')}';
        }
      }
    }

    return null;
  }


  @override
  void dispose() {
    // slotController.removeListener(_onSlotsUpdated);
    slotController.dispose();
    cartController.dispose();
    updateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: Stack(
            children: [
              SizedBox(
                width: 220,
                height: 110,
                child: Image.network(
                  'https://app.pawdli.com/media/static/topimage.png',
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildStepperSection(),
                  const SizedBox(height: 30),
                  const Text(
                    'Select Your Slots',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Choose Date',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 95,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dates.length,
                      itemBuilder: (context, index) {
                        final date = dates[index];
                        final selected = selectedDateIndex == index;

                        const weekdays = [
                          'Sun', 'Mon', 'Tue', 'Wed',
                          'Thu', 'Fri', 'Sat',
                        ];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDateIndex = index;

                              final dateString = _formatApiDate(date);
                              final times = _timesByDate[dateString] ?? [];

                              if (!times.contains(selectedTime)) {
                                selectedTime = '';
                              }
                            });
                          },
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colours.primarycolour.withOpacity(.12)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: selected
                                    ? Colours.primarycolour
                                    : Colours.brownColour,
                                width: 0.5,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  weekdays[date.weekday % 7],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${date.day}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Choose Time',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildTimeSlots(),
                ],
              ),
            ),
          ),
          bottomSummary(),
        ],
      ),
    );
  }

  Widget _buildTimeSlots() {
    if (slotController.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (slotController.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                slotController.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _loadSlotsAndRestoreSelection,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (dates.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('No available slots for this month'),
        ),
      );
    }

    final dateString =
        _formatApiDate(dates[selectedDateIndex]);

    final times = _timesByDate[dateString] ?? [];

    if (times.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('No available slots for this date'),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: times.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.4,
      ),
      itemBuilder: (context, index) {
        final time = times[index];
        final selected = selectedTime == time;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedTime = time;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: selected
                  ? Colours.primarycolour.withOpacity(.12)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? Colours.primarycolour
                    : Colours.brownColour,
                width: 0.5,
              ),
            ),
            child: Center(
              child: Text(
                _formatDisplayTime(time),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDisplayTime(String time) {
    final parts = time.split(':');

    if (parts.length < 2) return time;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return time;
    }

    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour >= 12 ? 'PM' : 'AM';

    return '$hour12:${minute.toString().padLeft(2, '0')} $period';
  }


  Widget buildStepperSection() {
    const steps = ['Add\nDetails', 'Add\nAddress', 'Select\nSlot'];

    return Column(
      children: [
        Row(
          children: List.generate(5, (index) {
            if (index.isOdd) {
              return Expanded(
                child: Container(
                  height: 1.5,
                  color: Colours.primarycolour,
                ),
              );
            }

            final step = index ~/ 2;

            return Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colours.primarycolour,
                border: Border.all(
                  color: Colours.primarycolour,
                  width: 2,
                ),
              ),
              child: step < 2
                  ? const Icon(
                      Icons.check,
                      size: 17,
                      color: Colors.white,
                    )
                  : const Icon(
                      Icons.circle,
                      size: 10,
                      color: Colors.white,
                    ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          children: steps.asMap().entries.map((entry) {
            return Expanded(
              child: Text(
                entry.value,
                textAlign: entry.key == 0
                    ? TextAlign.left
                    : entry.key == 2
                        ? TextAlign.right
                        : TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  height: 1.4,
                  color: Colours.brownColour,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
    String _toApiTime(String value) {
      final input = value.trim();

      final match = RegExp(
        r'^(\d{1,2}):(\d{2})(?::\d{2})?\s*(AM|PM)?$',
        caseSensitive: false,
      ).firstMatch(input);

      if (match == null) {
        throw FormatException('Invalid selected time: $value');
      }

      var hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      final period = match.group(3)?.toUpperCase();

      if (minute > 59) {
        throw FormatException('Invalid selected time: $value');
      }

      if (period != null) {
        if (hour < 1 || hour > 12) {
          throw FormatException('Invalid selected time: $value');
        }

        if (period == 'PM' && hour != 12) hour += 12;
        if (period == 'AM' && hour == 12) hour = 0;
      } else if (hour > 23) {
        throw FormatException('Invalid selected time: $value');
      }

      return '${hour.toString().padLeft(2, '0')}:'
          '${minute.toString().padLeft(2, '0')}';
    }

  
  Future<void> _continueToCart() async {
    if (isAddingToCart) return;

    if (dates.isEmpty || selectedTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an available date and time.'),
        ),
      );
      return;
    }

    if (selectedDateIndex < 0 || selectedDateIndex >= dates.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a valid date.'),
        ),
      );
      return;
    }

    final selectedDate = dates[selectedDateIndex];
    final selectedDateString = _formatApiDate(selectedDate);

    final availableTimes = _timesByDate[selectedDateString] ?? [];

    if (!availableTimes.contains(selectedTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The selected time is no longer available. Please select another time.',
          ),
        ),
      );
      return;
    }

    if (widget.selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one service.'),
        ),
      );
      return;
    }

    // // The new add endpoint creates cart items.
    // // Do not call it to edit an existing cart item.
    // if (widget.editCartItemId != null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text(
    //         'Editing requires the updated cart-item API to accept '
    //         'the selected date and time.',
    //       ),
    //     ),
    //   );
    //   return;
    // }

    setState(() => isAddingToCart = true);

    try {
      final address = widget.selectedAddress;

      final houseNumber = [
        address.houseNo,
        address.flatFloor,
      ].where((value) => value.trim().isNotEmpty).join(', ');

      final completeAddress = [
        address.houseNo,
        address.flatFloor,
        address.area,
        address.locality,
        address.landmark,
        address.city,
        address.state,
        address.pincode,
      ].where((value) => value.trim().isNotEmpty).join(', ');

      final session = GroomingSessionRequest(
        date: selectedDateString,
        startTime: _toApiTime(selectedTime),
      );

      // Build all selected packages for NORMAL ADD TO CART.
      final serviceRequests = <OneTimeServiceCartRequest>[];

      for (final service in widget.selectedServices) {
        final serviceId = int.tryParse(
          '${service['service_id'] ?? service['main_service_id'] ?? ''}',
        );

        final packageId = int.tryParse(
          '${service['one_time_package_id'] ?? ''}',
        );

        if (serviceId == null || packageId == null) {
          throw Exception(
            'A selected service is missing its service ID or package ID.',
          );
        }

        serviceRequests.add(
          OneTimeServiceCartRequest(
            serviceId: serviceId,
            oneTimePackageId: packageId,
            sessions: [session],
          ),
        );
      }

      debugPrint(
        'NORMAL ADD SERVICES COUNT: ${serviceRequests.length}',
      );

      // if (updateServices.isEmpty) {
      //   throw Exception('There are no new services to add.');
      // }

      // EDIT MODE
      if (widget.editCartItemId != null) {
        // 1. Get all package IDs already in the cart group.
        final originalPackageIds =
            widget.existingPackageIds.toSet();

        // 2. Get all package IDs currently selected by the user.
        final selectedPackageIds = widget.selectedServices
            .map((service) => int.tryParse(
                  '${service['one_time_package_id'] ?? ''}',
                ))
            .whereType<int>()
            .toSet();

        // 3. Find newly selected packages.
        final packagesToAdd =
            selectedPackageIds.difference(originalPackageIds);

        // 4. Find packages deselected by the user.
        final packagesToRemove =
            originalPackageIds.difference(selectedPackageIds);

        // 5. Get the cart item IDs of the deselected packages.
        final cartItemIdsToRemove = widget.existingCartItems
            .where((item) =>
                item.oneTimePackageId != null &&
                packagesToRemove.contains(item.oneTimePackageId))
            .map((item) => item.cartItemId)
            .toList();

        debugPrint('EXISTING PACKAGE IDS: $originalPackageIds');
        debugPrint('SELECTED PACKAGE IDS: $selectedPackageIds');
        debugPrint('PACKAGES TO ADD: $packagesToAdd');
        debugPrint('PACKAGES TO REMOVE: $packagesToRemove');
        debugPrint('CART ITEM IDS TO REMOVE: $cartItemIdsToRemove');

        // 6. Build only newly selected services.
        final updateServices = <Map<String, dynamic>>[];

        for (final service in widget.selectedServices) {
          final serviceId = int.tryParse(
            '${service['service_id'] ?? service['main_service_id'] ?? ''}',
          );

          final packageId = int.tryParse(
            '${service['one_time_package_id'] ?? ''}',
          );

          if (serviceId == null || packageId == null) {
            throw Exception('Invalid service or package ID.');
          }

          // Do not send existing packages again.
          if (!packagesToAdd.contains(packageId)) {
            continue;
          }

          updateServices.add({
            'service_id': serviceId,
            'one_time_package_id': packageId,
            'sessions': [
              {
                'date': selectedDateString,
                'start_time': _toApiTime(selectedTime),
              },
            ],
          });
        }

        // 7. ADD newly selected services.
        if (updateServices.isNotEmpty) {
          final updateRequest = GroomingCartUpdateRequest(
            cartItemId: widget.editCartItemId!,
            petId: widget.petId,
            contactNumber: widget.contactNumber,
            peopleComfortLevel: widget.peopleComfortLevel,
            dogsComfortLevel: widget.dogsComfortLevel,
            houseNumber: houseNumber,
            area: address.area,
            locality: address.locality,
            landmark: address.landmark,
            completeAddress: completeAddress,
            latitude: widget.latitude,
            longitude: widget.longitude,
            sessions: [
              GroomingUpdateSessionRequest(
                date: selectedDateString,
                startTime: _toApiTime(selectedTime),
              ),
            ],
            action: 'ADD_SERVICES',
            services: updateServices,
          );

          debugPrint(
            'ONE-TIME ADD BODY: ${jsonEncode(updateRequest.toJson())}',
          );

          final success = await updateController.updateCart(
            request: updateRequest,
          );

          if (!mounted) return;

          if (!success) {
            throw Exception(
              updateController.errorMessage ??
                  'Unable to add new grooming services.',
            );
          }
        }

        // 8. REMOVE deselected services.
        if (cartItemIdsToRemove.isNotEmpty) {
          for (final cartItemId in cartItemIdsToRemove) {
            final removed = await ApiService.removeOneTimeServices(
              cartItemId: cartItemId,
            );

            if (!mounted) return;

            if (!removed) {
              throw Exception(
                'Unable to remove grooming cart item $cartItemId.',
              );
            }
          }
        }

        // 9. Refresh and return to cart.
        await cartController.fetchCart();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('One-Time services updated successfully.'),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const GroomingCartPage(),
          ),
        );

        return;
      }

      final request = OneTimeGroomingAddToCartRequest(
        petId: widget.petId,
        contactNumber: widget.contactNumber,
        peopleComfortLevel: widget.peopleComfortLevel,
        dogsComfortLevel: widget.dogsComfortLevel,
        houseNumber: houseNumber,
        area: address.area,
        locality: address.locality,
        landmark: address.landmark,
        completeAddress: completeAddress,
        latitude: widget.latitude,
        longitude: widget.longitude,
        services: serviceRequests,
      );

      debugPrint('ONE-TIME GROOMING REQUEST: '
          '${request.toJson()}');

      final success = await cartController.addOneTimeToCart(request);

      if (!mounted) return;

      if (!success) {
        throw Exception(
          cartController.errorMessage ??
              'Unable to add One-Time services to cart.',
        );
      }

      // The controller already refreshes the cart after a successful POST.
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const GroomingCartPage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isAddingToCart = false);
      }
    }
  }


  Widget bottomSummary() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.05,
        14,
        screenWidth * 0.05,
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    '${widget.serviceName}\nPet: ${widget.selectedPet}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '₹${widget.totalPrice}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.042,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: selectedTime.isEmpty ||
                        dates.isEmpty ||
                        isAddingToCart
                    ? null
                    : _continueToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colours.primarycolour,
                  disabledBackgroundColor:
                      Colours.primarycolour.withOpacity(.4),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isAddingToCart
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
