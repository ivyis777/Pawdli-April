import 'package:flutter/material.dart';

import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/ServiceSlotsController.dart';

import 'package:pawlli/data/model/GroomingAddressModel.dart';
import 'package:pawlli/data/model/ServiceCartModel.dart';
import 'package:pawlli/data/model/ServiceSlotsModel.dart';
import 'package:pawlli/presentation/screens/PetGrooming/BuildPlans/GroomingPreviewSchedulePage.dart';



class GroomingSlotSelectionPage extends StatefulWidget {
  final String serviceName;
  final int selectedSession;
  final int selectedDuration;
  final int totalSessions;
  final int totalPrice;
  final String selectedPet;
  final AddressModel selectedAddress;
  final int mainServiceId;
  final int petId;
  final int pricingPlanId;
  final String peopleComfortLevel;
  final String dogsComfortLevel;
  final String contactNumber;
  final double latitude;
  final double longitude;
  final int? editCartItemId;
  final GroomingCartItemModel? existingCartItem;

  const GroomingSlotSelectionPage({
    super.key,
    required this.serviceName,
    required this.selectedSession,
    required this.selectedDuration,
    required this.totalSessions,
    required this.totalPrice,
    required this.selectedPet,
    required this.selectedAddress,
    required this.mainServiceId,
    required this.petId,
    required this.pricingPlanId,
    required this.peopleComfortLevel,
    required this.dogsComfortLevel,
    required this.contactNumber,
    required this.latitude,
    required this.longitude,
    this.editCartItemId,
    this.existingCartItem,
  });

  @override
  State<GroomingSlotSelectionPage> createState() => _GroomingSlotSelectionPageState();
  }

  class _GroomingSlotSelectionPageState extends State<GroomingSlotSelectionPage> {

    int selectedDateIndex = 0;
    String selectedTime = '';

    late List<DateTime> dates;

    DateTime displayedMonth = DateTime.now();

    bool _savedSlotRestoreAttempted = false;

    final AvailableServiceSlotController slotController =
        AvailableServiceSlotController();

    
  
  @override
  void initState() {
    super.initState();

    dates = [];

    final sessions = widget.existingCartItem?.sessions ?? [];
    DateTime initialDate = DateTime.now();

    if (sessions.isNotEmpty) {
      final savedDate =
          DateTime.tryParse(sessions.first.scheduledDate);

      if (savedDate != null) {
        initialDate = savedDate;
        selectedTime = sessions.first.startTime;
      }
    }

    displayedMonth = DateTime(
      initialDate.year,
      initialDate.month,
    );

    _loadMonth(displayedMonth, restoreSavedSelection: true);
  }

  Future<void> _loadMonth(
    DateTime month, {
    bool restoreSavedSelection = false,
  }) async {
    await slotController.fetchSlots(
      mainServiceId: widget.mainServiceId,
      month: month,
    );

    if (!mounted) return;

    setState(() {
      dates = slotController.availableDates
          .map((item) => item.parsedDate)
          .whereType<DateTime>()
          .toList();

      if (dates.isEmpty) {
        selectedDateIndex = 0;
        selectedTime = '';
        return;
      }

      var index = -1;

      if (restoreSavedSelection) {
        final sessions =
            widget.existingCartItem?.sessions ?? [];

        if (sessions.isNotEmpty) {
          final savedDate =
              DateTime.tryParse(sessions.first.scheduledDate);

          if (savedDate != null) {
            index = dates.indexWhere(
              (date) =>
                  date.year == savedDate.year &&
                  date.month == savedDate.month &&
                  date.day == savedDate.day,
            );
          }
        }
      }

      selectedDateIndex = index >= 0 ? index : 0;

      final selectedDateString =
          _formatDate(dates[selectedDateIndex]);

      AvailableServiceDateModel? apiDate;

      for (final item in slotController.availableDates) {
        if (item.date == selectedDateString) {
          apiDate = item;
          break;
        }
      }

      // Assign directly here; do not notify listeners from this method.
      slotController.selectedDate = apiDate;

      if (apiDate != null &&
          apiDate.slots.contains(selectedTime)) {
        slotController.selectedTime = selectedTime;
      } else {
        selectedTime = '';
        slotController.selectedTime = null;
      }
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }


  @override
  void dispose() {
    // slotController.removeListener(_onSlotsUpdated);
    slotController.dispose();
    super.dispose();
  }

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

            onPressed: () {

              Navigator.pop(context);

            },

          ),



          flexibleSpace: Stack(

            children: [

              SizedBox(

                width: 220,

                height: 110,

                child: Image.network(

                  "https://app.pawdli.com/media/static/topimage.png",

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

              padding:

                  const EdgeInsets.all(20),



              child: Column(

                crossAxisAlignment:

                    CrossAxisAlignment.start,



                children: [



                  buildStepperSection(),



                  const SizedBox(height: 30),



                  const Text(

                    "Select Your Slots",

                    style: TextStyle(

                      fontSize: 20,

                      fontWeight:

                          FontWeight.w600,

                    ),

                  ),



                  const SizedBox(height: 20),



                  Text(

                    "Choose Date",

                    style: TextStyle(

                      fontSize: 15,

                      fontWeight:

                          FontWeight.w600,

                      color:

                          Colors.black,

                    ),

                  ),



                  const SizedBox(height: 16),



                  SizedBox(

                    height: 95,



                    child: ListView.builder(

                      scrollDirection:

                          Axis.horizontal,



                      itemCount: dates.length,



                      itemBuilder:

                          (context, index) {



                        bool selected =

                            selectedDateIndex ==

                                index;



                        DateTime date =

                            dates[index];



                        return GestureDetector(

                          onTap: () {
                            setState(() {
                              selectedDateIndex = index;
                              selectedTime = '';
                            });

                            final dateString = _formatDate(dates[index]);

                            AvailableServiceDateModel? apiDate;

                            for (final item in slotController.availableDates) {
                              if (item.date == dateString) {
                                apiDate = item;
                                break;
                              }
                            }

                            slotController.selectDate(apiDate!);
                          },



                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 12),
                            decoration:

                                BoxDecoration(

                              color: selected

                                  ? Colours.primarycolour

                                      .withOpacity(

                                          .12)

                                  : Colors.white,



                              borderRadius:

                                  BorderRadius.circular(

                                      18),



                              border: Border.all(

                                color: selected

                                    ? Colours

                                        .primarycolour

                                    : Colours.brownColour,

                                width:0.5

                              ),

                            ),



                            child: Column(

                              mainAxisAlignment:

                                  MainAxisAlignment

                                      .center,



                              children: [



                                Text(

                                  [

                                    "Sun",

                                    "Mon",

                                    "Tue",

                                    "Wed",

                                    "Thu",

                                    "Fri",

                                    "Sat"

                                  ][date.weekday %

                                      7],

                                  style: TextStyle(

                                    fontSize:14,

                                    color: Colors.grey.shade500,

                                  ),

                                ),



                                const SizedBox(

                                    height: 8),



                                Text(

                                  "${date.day}",

                                  style:

                                      const TextStyle(

                                    fontSize:

                                        20,

                                    fontWeight:

                                        FontWeight

                                            .w600,

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



                  Text(

                    "Choose Time",

                    style: TextStyle(

                      fontSize: 15,

                      fontWeight:

                          FontWeight.w600,

                      color:

                          Colors.black,

                    ),

                  ),

                  const SizedBox(height: 15),

                    Builder(
                      builder: (context) {
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
                                    onPressed: () {
                                      _loadMonth(displayedMonth);
                                    },
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
                              child: Text('No available dates this month'),
                            ),
                          );
                        }

                        final selectedDateString =
                            _formatDate(dates[selectedDateIndex]);

                        AvailableServiceDateModel? apiDate;

                        for (final item in slotController.availableDates) {
                          if (item.date == selectedDateString) {
                            apiDate = item;
                            break;
                          }
                        }

                        final times = apiDate?.slots ?? [];

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
                            final bool selected = selectedTime == time;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedTime = time;
                                });

                                slotController.selectTime(time);
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
                                    apiDate!.formatTime(time),
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
                      },
                    ),

                ],
              ),
            ),
          ),
          bottomSummary(),
        ],
      ),
    );
  }

  Widget buildStepperSection() {

      return Column(

        children: [

          // =========================================================

          // CIRCLES + LINES

          // =========================================================



          Row(

            children: [

              // Build Plan completed

              completedStep(),



              Expanded(

                child: activeLine(),

              ),



              completedStep(),



              Expanded(

                child: activeLine(),

              ),



              completedStep(),



              Expanded(

                child: activeLine(),

              ),



              activeStep(),



              Expanded(

                child: inactiveLine(),

              ),



              inactiveStep(),

            ],

          ),



          const SizedBox(height: 8),



          // =========================================================

          // STEP TEXTS

          // =========================================================



          Row(

            crossAxisAlignment:

                CrossAxisAlignment.start,

            children: [

              Expanded(

                child: Text(

                  "Build\nPlan",

                  textAlign: TextAlign.left,

                  style: TextStyle(

                    color: Colours.brownColour,

                    fontSize: 10,

                    height: 1.4,

                    fontWeight:

                        FontWeight.w600,

                  ),

                ),

              ),



              Expanded(

                child: Text(

                  "Add\nDetails",

                  textAlign: TextAlign.center,

                  style: TextStyle(

                    color: Colours.brownColour,

                    fontSize: 10,

                    height: 1.4,

                    fontWeight:

                        FontWeight.w600,

                  ),

                ),

              ),



              Expanded(

                child: Text(

                  "Add\nAddress",

                  textAlign: TextAlign.center,

                  style: TextStyle(

                    color: Colours.brownColour,

                    fontSize: 10,

                    height: 1.4,

                    fontWeight: FontWeight.w500,

                  ),

                ),

              ),



              Expanded(

                child: Text(

                  "Select\nSlot",

                  textAlign: TextAlign.center,

                  style: TextStyle(

                    color: Colors.grey.shade500,

                    fontSize: 10,

                    height: 1.4,

                    fontWeight: FontWeight.w500,

                  ),

                ),

              ),



              Expanded(

                child: Text(

                  "Preview\nSchedule",

                  textAlign:

                      TextAlign.right,

                  style: TextStyle(

                    color:

                        Colors.grey.shade500,

                    fontSize: 10,

                    height: 1.4,

                    fontWeight:

                        FontWeight.w500,

                  ),

                ),

              ),

            ],

          ),

        ],

      );

    }



    // =============================================================

    // COMPLETED STEP

    // =============================================================



    Widget completedStep() {

      return Container(

        height: 24,

        width: 24,

        decoration: BoxDecoration(

          color:

              Colours.primarycolour,

          shape:

              BoxShape.circle,

        ),

        child: const Icon(

          Icons.check,

          size: 15,

          color: Colors.white,

        ),

      );

    }



    // =============================================================

    // ACTIVE STEP

    // =============================================================



    Widget activeStep() {

      return Container(

        height: 24,

        width: 24,

        decoration: BoxDecoration(

          color:

              Colours.primarycolour,

          shape:

              BoxShape.circle,

        ),

        child: Center(

          child: Container(

            height: 9,

            width: 9,

            decoration:

                const BoxDecoration(

              color: Colors.white,

              shape:

                  BoxShape.circle,

            ),

          ),

        ),

      );

    }



    // =============================================================

    // INACTIVE STEP

    // =============================================================



    Widget inactiveStep() {

      return Container(

        height: 24,

        width: 24,

        decoration: BoxDecoration(

          color: Colors.white,



          shape:

              BoxShape.circle,



          border:

              Border.all(

            color:

                Colors.grey.shade400,

            width: 1.5,

          ),

        ),

      );

    }



    // =============================================================

    // ACTIVE LINE

    // =============================================================



    Widget activeLine() {

      return Container(

        height: 1.5,

        color:

            Colours.primarycolour,

      );

    }



    // =============================================================

    // INACTIVE LINE

    // =============================================================



    Widget inactiveLine() {

      return Container(

        height: 1.5,

        color:

            Colors.grey.shade300,

      );

    }



  Widget bottomSummary() {

    final screenWidth = MediaQuery.of(context).size.width;

    return Container(

      padding:

          const EdgeInsets.all(20),



      decoration: BoxDecoration(

        color: Colors.white,

        boxShadow: [

          BoxShadow(

            color:

                Colors.black.withOpacity(

                    0.05),

            blurRadius: 10,

          ),

        ],

      ),



      child: Column(

        mainAxisSize:

            MainAxisSize.min,



        children: [



          Row(

              crossAxisAlignment:

                  CrossAxisAlignment.center,

              children: [

                Expanded(

                  child: Text(

                    "${widget.serviceName} • "

                    "${widget.selectedSession} Session"

                    "${widget.selectedSession > 1 ? "s" : ""} • "

                    "${widget.selectedDuration} Months\n"

                    "Total ${widget.totalSessions} Sessions",

                    style: TextStyle(

                      fontSize:

                          screenWidth * 0.03,

                      height: 1.4,

                      fontWeight:

                          FontWeight.w500,

                      color:

                          Colors.grey.shade700,

                    ),

                  ),

                ),



                const SizedBox(width: 12),



                Text(

                  "₹${widget.totalPrice}",

                  style: TextStyle(

                    fontSize:

                        screenWidth * 0.042,

                    fontWeight:

                        FontWeight.w700,

                    color: Colors.black,

                  ),

                ),

              ],

            ),



          const SizedBox(height: 15),



          SizedBox(

            width: double.infinity,

            height: 55,



            child: ElevatedButton(

              onPressed: dates.isEmpty || selectedTime.isEmpty
                  ? null
                  : () {
                      final address = widget.selectedAddress;

                      final String addressLine = [

                        address.houseNo,

                        address.flatFloor,

                        address.area,

                        address.locality,

                        address.landmark,

                        address.city,

                        address.state,

                        address.pincode,

                      ]

                          .where((value) => value.trim().isNotEmpty)

                          .join(', ');



                      Navigator.push(context,

                        MaterialPageRoute(

                          builder: (_) => GroomingPreviewPage(
                            serviceName: widget.serviceName,
                            selectedSession: widget.selectedSession,
                            selectedDuration: widget.selectedDuration,
                            totalSessions: widget.totalSessions,
                            totalPrice: widget.totalPrice,
                            firstDate: dates[selectedDateIndex],
                            firstTime: selectedTime,
                            selectedPet: widget.selectedPet,
                            addressLine: addressLine,
                            petId: widget.petId,
                            serviceId: widget.mainServiceId,
                            pricingPlanId: widget.pricingPlanId,
                            peopleComfortLevel: widget.peopleComfortLevel,
                            dogsComfortLevel: widget.dogsComfortLevel,
                            houseNumber: address.houseNo,
                            locality: address.locality,
                            area: address.area,
                            landmark: address.landmark,
                            latitude: widget.latitude,
                            longitude: widget.longitude,
                            contactNumber: widget.contactNumber,
                            serviceSlotIds: [],
                            editCartItemId: widget.editCartItemId,
                            existingCartItem: widget.existingCartItem,
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colours.primarycolour,
              ),
              child: const Text(

                "Preview Schedule",

                style: TextStyle(

                  color: Colors.white,

                ),

              ),

            ),

          ),

        ],

      ),

    );

  }
}
