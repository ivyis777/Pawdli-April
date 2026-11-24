import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/controller/GroomingCartUpdateController.dart';
import 'package:pawlli/data/controller/ServiceAddToCartController.dart';
import 'package:pawlli/data/model/GroomingCartUpdateModel.dart';
import 'package:pawlli/data/model/GroomingPreviewModel.dart';
import 'package:pawlli/data/model/ServiceCartModel.dart';
import 'package:pawlli/presentation/screens/PetGrooming/ServiceCartPage.dart';

class GroomingPreviewPage extends StatefulWidget {
  // Existing preview details
  final String serviceName;
  final int selectedSession;
  final int selectedDuration;
  final int totalSessions;
  final int totalPrice;
  final DateTime firstDate;
  final String firstTime;
  final String selectedPet;
  final String addressLine;

  final int petId;
  final int serviceId;
  final int pricingPlanId;

  final String peopleComfortLevel;
  final String dogsComfortLevel;

  final String houseNumber;
  final String locality;
  final String area;
  final String landmark;

  final double latitude;
  final double longitude;

  final String contactNumber;

  // IDs returned by the available service-slots API
  final List<int> serviceSlotIds;
  final int? editCartItemId;
  final GroomingCartItemModel? existingCartItem;

  const GroomingPreviewPage({
    super.key,
    required this.serviceName,
    required this.selectedSession,
    required this.selectedDuration,
    required this.totalSessions,
    required this.totalPrice,
    required this.firstDate,
    required this.firstTime,
    required this.selectedPet,
    required this.addressLine,
    required this.petId,
    required this.serviceId,
    required this.pricingPlanId,
    required this.peopleComfortLevel,
    required this.dogsComfortLevel,
    required this.houseNumber,
    required this.locality,
    required this.area,
    required this.landmark,
    required this.latitude,
    required this.longitude,
    required this.contactNumber,
    required this.serviceSlotIds,
    this.editCartItemId,
    this.existingCartItem,
  });

  @override
  State<GroomingPreviewPage> createState() =>
      _GroomingPreviewPageState();
}

class _GroomingPreviewPageState extends State<GroomingPreviewPage> {
  final GroomingAddToCartController cartController =
      GroomingAddToCartController();
  final GroomingCartUpdateController updateController =
    GroomingCartUpdateController();

  final List<ScheduleItem> schedules = [];

  final List<int?> scheduleSlotIds = [];

  final Map<int, List<String>> availableSlotsBySchedule = {};

  final Map<String, List<String>> availableTimesByMonth = {};

  int? editingIndex;

  DateTime? originalDate;
  String? originalTime;
  int? originalSlotId;

  bool isGeneratingSchedule = false;
  bool isLoadingTimeSlots = false;


  @override
  void initState() {
    super.initState();

    generateSchedules();

    cartController.addListener(_onCartControllerChanged);
  }

  void _onCartControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    cartController.removeListener(_onCartControllerChanged);
    cartController.dispose();
    updateController.dispose();
    super.dispose();
  }

  
  
  Future<void> generateSchedules() async {
    if (!mounted) return;

    setState(() {
      schedules.clear();
      scheduleSlotIds.clear();
      availableSlotsBySchedule.clear();
      isGeneratingSchedule = true;
    });

    final int totalSlots =
        widget.selectedSession * widget.selectedDuration;

    try {
      // Regenerate every session, including sessions that
      // previously existed in the cart.
      for (int i = 0; i < totalSlots; i++) {
        late DateTime sessionDate;

        if (widget.selectedSession == 1) {
          // One session per month, keeping the same day
          // when possible.
          final DateTime targetMonth = DateTime(
            widget.firstDate.year,
            widget.firstDate.month + i,
            1,
          );

          final int lastDayOfMonth = DateTime(
            targetMonth.year,
            targetMonth.month + 1,
            0,
          ).day;

          final int day = widget.firstDate.day <= lastDayOfMonth
              ? widget.firstDate.day
              : lastDayOfMonth;

          sessionDate = DateTime(
            targetMonth.year,
            targetMonth.month,
            day,
          );
        } else {
          // Distribute sessions using the existing interval
          // logic, starting from the newly selected date.
          final int intervalDays =
              (30 / widget.selectedSession).round();

          sessionDate = widget.firstDate.add(
            Duration(days: intervalDays * i),
          );
        }

        schedules.add(
          ScheduleItem(
            date: sessionDate,
            time: widget.firstTime,
          ),
        );

        // Never reuse the old cart's slot ID.
        scheduleSlotIds.add(null);
      }

      if (!mounted) return;
      setState(() {});

      // Fetch available slots for every newly generated date.
      // This assigns fresh slot IDs from the API.
      for (int i = 0; i < schedules.length; i++) {
        await loadSlotForSchedule(
          i,
          preferredTime: widget.firstTime,
          preferredSlotId: null,
        );
      }
    } catch (e) {
      debugPrint('Schedule generation error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to generate schedule: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isGeneratingSchedule = false;
        });
      }
    }
  }




  String formatApiDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String formatApiMonth(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}';
  }

  Future<List<String>> fetchSlotsForDate(DateTime date) async {
    final month = formatApiMonth(date);

    // Reuse monthly availability when it is already loaded.
    if (!availableTimesByMonth.containsKey(month)) {
      final response =
          await ApiService.fetchAvailableServiceSlots(
        mainServiceId: widget.serviceId,
        month: month,
      );

      availableTimesByMonth[month] = [];

      for (final availableDate in response.availableDates) {
        // Store the times against the exact date separately.
        _timesByDate[availableDate.date] =
            List<String>.from(availableDate.slots);
      }
    }

    return _timesByDate[formatApiDate(date)] ?? [];
  }

  final Map<String, List<String>> _timesByDate = {};


  
  Future<void> loadSlotForSchedule(
    int index, {
    String? preferredTime,
    int? preferredSlotId,
  }) async {
    if (index < 0 || index >= schedules.length) return;

    try {
      final times = await fetchSlotsForDate(
        schedules[index].date,
      );

      if (!mounted) return;

      String selectedTime = '';

      // Preserve the preferred time when it is still available.
      if (preferredTime != null &&
          times.contains(preferredTime)) {
        selectedTime = preferredTime;
      } else if (times.isNotEmpty) {
        selectedTime = times.first;
      }

      setState(() {
        availableSlotsBySchedule[index] = times;
        schedules[index].time = selectedTime;

        // The monthly API does not return slot IDs.
        scheduleSlotIds[index] = null;
      });
    } catch (e) {
      debugPrint(
        'Failed to load slots for '
        '${schedules[index].date}: $e',
      );

      if (!mounted) return;

      setState(() {
        availableSlotsBySchedule[index] = [];
        schedules[index].time = '';
        scheduleSlotIds[index] = null;
      });
    }
  }

  void startEditingSlot(int index) {
    setState(() {
      editingIndex = index;

      originalDate = schedules[index].date;
      originalTime = schedules[index].time;
      originalSlotId = scheduleSlotIds[index];
    });
  }

  
  Future<void> pickScheduleDate(int index) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: schedules[index].date,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (!mounted || pickedDate == null) return;

    setState(() {
      schedules[index].date = pickedDate;
      schedules[index].time = '';
      scheduleSlotIds[index] = null;
      availableSlotsBySchedule.remove(index);
      isLoadingTimeSlots = true;
    });

    await loadSlotForSchedule(
      index,
      preferredTime: originalTime,
    );

    if (!mounted) return;

    setState(() {
      isLoadingTimeSlots = false;
    });
  }


  
  Future<void> showAvailableTimeSlots(int index) async {
    setState(() {
      isLoadingTimeSlots = true;
    });

    List<String> times;

    try {
      times = await fetchSlotsForDate(schedules[index].date);

      if (mounted) {
        setState(() {
          availableSlotsBySchedule[index] = times;
          isLoadingTimeSlots = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingTimeSlots = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to load time slots: $e'),
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    if (times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No available time slots for this date.'),
        ),
      );
      return;
    }

    final String? selectedTime = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Time',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height:
                      MediaQuery.of(dialogContext).size.height * 0.45,
                  child: ListView.builder(
                    itemCount: times.length,
                    itemBuilder: (context, slotIndex) {
                      final time = times[slotIndex];

                      return InkWell(
                        onTap: () {
                          Navigator.pop(dialogContext, time);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 18,
                          ),
                          child: Text(
                            _formatDisplayTime(time),
                            style: const TextStyle(
                              fontSize: 17,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.pop(dialogContext),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selectedTime == null) return;

    setState(() {
      schedules[index].time = selectedTime;
      scheduleSlotIds[index] = null;
    });
  }

  String _toApiTime(String time) {
    final value = time.trim();

    // Already in 24-hour format, such as 14:30 or 14:30:00.
    final twentyFourHour =
        RegExp(r'^([01]?\d|2[0-3]):([0-5]\d)(?::[0-5]\d)?$');

    if (twentyFourHour.hasMatch(value)) {
      final parts = value.split(':');
      return '${parts[0].padLeft(2, '0')}:${parts[1]}';
    }

    // Convert display format such as 2:30 PM to 14:30.
    final parsed = DateFormat('h:mm a').tryParse(value.toUpperCase());

    if (parsed != null) {
      return DateFormat('HH:mm').format(parsed);
    }

    throw FormatException('Invalid session time: $time');
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

    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;

    return '$hour12:${minute.toString().padLeft(2, '0')} $period';
  }

  
  
  Future<void> addBookingToCart() async {
    // STEP 1: Validate all session dates and times.
    if (schedules.isEmpty ||
        schedules.any((session) => session.time.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select an available time for every session.',
          ),
        ),
      );
      return;
    }

    setState(() {
      isGeneratingSchedule = true;
    });

    try {
      bool success = false;
      String successMessage = '';

      // STEP 2: EDIT EXISTING CART ITEM - PUT API.
      if (widget.editCartItemId != null) {
        final updateSessions = schedules.map((schedule) {
          return GroomingUpdateSessionRequest(
            date: formatApiDate(schedule.date),
            startTime: _toApiTime(schedule.time),
          );
        }).toList();

        final updateRequest = GroomingCartUpdateRequest(
          cartItemId: widget.editCartItemId!,
          petId: widget.petId,
          pricingPlanId: widget.pricingPlanId,
          sessionsPerMonth: widget.selectedSession,
          numberOfMonths: widget.selectedDuration,
          contactNumber: widget.contactNumber,
          peopleComfortLevel: widget.peopleComfortLevel,
          dogsComfortLevel: widget.dogsComfortLevel,
          houseNumber: widget.houseNumber,
          area: widget.area,
          locality: widget.locality,
          landmark: widget.landmark,
          completeAddress: widget.addressLine,
          latitude: widget.latitude,
          longitude: widget.longitude,
          sessions: updateSessions,
        );

        success = await updateController.updateCart(
          request: updateRequest,
        );

        successMessage = success
            ? (updateController.result?.message ??
                'Grooming booking updated successfully.')
            : (updateController.errorMessage ??
                'Unable to update grooming booking.');

      } else {
        // STEP 3: NEW BOOKING - KEEP EXISTING POST API.

        final sessionRequests = schedules.map((schedule) {
          return GroomingSessionRequest(
            date: formatApiDate(schedule.date),
            startTime: _toApiTime(schedule.time),
          );
        }).toList();

        final serviceRequest = GroomingPlanServiceRequest(
          serviceId: widget.serviceId,
          pricingPlanId: widget.pricingPlanId,
          sessionsPerMonth: widget.selectedSession,
          numberOfMonths: widget.selectedDuration,
          sessions: sessionRequests,
        );

        final request = GroomingAddToCartRequest(
          petId: widget.petId,
          contactNumber: widget.contactNumber,
          peopleComfortLevel: widget.peopleComfortLevel,
          dogsComfortLevel: widget.dogsComfortLevel,
          houseNumber: widget.houseNumber,
          area: widget.area,
          locality: widget.locality,
          landmark: widget.landmark,
          completeAddress: widget.addressLine,
          latitude: widget.latitude,
          longitude: widget.longitude,
          services: [serviceRequest],
        );

        success = await cartController.addToCart(request);

        successMessage = success
            ? 'Grooming booking added to cart successfully.'
            : 'Unable to add grooming booking to cart.';
      }

      // STEP 4: Handle the API result.
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );

      if (success) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const GroomingCartPage(),
          ),
        );
      }
    } catch (e) {
      debugPrint('Grooming cart save error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to save grooming plan: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isGeneratingSchedule = false;
        });
      }
    }
  }




  Widget buildScheduleCard(int index) {
    final item = schedules[index];
    final bool isEditing = editingIndex == index;

    final borderColor = Colours.brownColour;

    Widget fieldBox({
      required IconData icon,
      required String text,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey.shade600, size: 25),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (index == 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: const Color(0xffE6F7EA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'FIRST SESSION',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (isEditing) ...[
            const Text(
              'Date',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 8),

            fieldBox(
              icon: Icons.calendar_month,
              text: DateFormat('EEE, d MMM').format(item.date),
              onTap: () => pickScheduleDate(index),
            ),

            const SizedBox(height: 12),

            const Text(
              'Time',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 8),

            fieldBox(
              icon: Icons.access_time,
              text: isLoadingTimeSlots
                  ? 'Loading available times...'
                  : item.time.isEmpty
                      ? 'Select available time'
                      : _formatDisplayTime(item.time),
              onTap: () => showAvailableTimeSlots(index),
            ),

            const SizedBox(height: 22),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        if (originalDate != null) {
                          item.date = originalDate!;
                        }

                        if (originalTime != null) {
                          item.time = originalTime!;
                        }

                        scheduleSlotIds[index] = originalSlotId;
                        editingIndex = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 50),
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: schedules[index].time.isEmpty
                        ? null
                        : () {
                            setState(() {
                              editingIndex = null;
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 50),
                      backgroundColor: Colours.primarycolour,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ] else
            Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: Colors.grey.shade600,
                  size: 25,
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    '${DateFormat('EEE, d MMM').format(item.date)}   '
                    '${item.time.isEmpty ? 'No time available' : _formatDisplayTime(item.time)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () => startEditingSlot(index),
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      color: Colours.primarycolour,
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
                  errorBuilder: (_, __, ___) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                buildStepper(),
                const SizedBox(height: 30),

                Text(
                  'Your Grooming Schedule',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colours.brownColour,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'You can edit your session times now—or anytime later from your plan details.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 30),

                ...List.generate(
                  schedules.length,
                  (index) => buildScheduleCard(index),
                ),
              ],
            ),
          ),

          bottomSummary(),
        ],
      ),
    );
  }

  Widget buildStepper() {
    return buildStepperSection();
  }

  Widget buildStepperSection() {
    return Row(
      children: [
        completedStep(),
        Expanded(child: activeLine()),
        completedStep(),
        Expanded(child: activeLine()),
        completedStep(),
        Expanded(child: activeLine()),
        completedStep(),
        Expanded(child: activeLine()),
        activeStep(),
      ],
    );
  }

  Widget completedStep() {
    return Container(
      height: 24,
      width: 24,
      decoration: BoxDecoration(
        color: Colours.primarycolour,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check,
        size: 14,
        color: Colors.white,
      ),
    );
  }

  Widget activeStep() {
    return Container(
      height: 24,
      width: 24,
      decoration: BoxDecoration(
        color: Colours.primarycolour,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget activeLine() {
    return Container(
      height: 2,
      color: Colours.primarycolour,
    );
  }

  Widget bottomSummary() {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  '${widget.serviceName} • '
                  '${widget.selectedSession} Session'
                  '${widget.selectedSession > 1 ? 's' : ''} • '
                  '${widget.selectedDuration} Months\n'
                  'Total ${widget.totalSessions} Sessions',
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

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: isGeneratingSchedule || cartController.isLoading
                  ? null
                  : addBookingToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colours.primarycolour,
                disabledBackgroundColor:
                    Colours.primarycolour.withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isGeneratingSchedule || cartController.isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Buy Now',
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
    );
  }
}