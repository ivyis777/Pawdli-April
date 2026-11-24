
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/GroomingPriceController.dart';
import 'package:pawlli/data/controller/GroomingServicePlansController.dart';
import 'package:pawlli/data/controller/petslistcontroller.dart';
import 'package:pawlli/data/model/GroomingPriceModel.dart';
import 'package:pawlli/data/model/GroomingServicePlansModel.dart';
import 'package:pawlli/data/model/ServiceCartModel.dart';
import 'package:pawlli/presentation/screens/PetGrooming/BuildPlans/GroomingAddDetailsPage.dart';
import 'package:pawlli/presentation/screens/add%20pet/addpet.dart';

class BuildPlanBookingPage extends StatefulWidget {
  final String serviceName;
  final int serviceId;
  final int? editCartItemId;
  final GroomingCartItemModel? existingCartItem;


  const BuildPlanBookingPage({
    super.key,
    required this.serviceName,
    required this.serviceId,
    this.editCartItemId,
    this.existingCartItem,
  });

  @override
  State<BuildPlanBookingPage> createState() =>
      _BuildPlanBookingPageState();
}

class _BuildPlanBookingPageState extends State<BuildPlanBookingPage> {
  late final Petslistcontroller petsController;
  late final GroomingServiceController groomingController;
  late final GroomingPlanPriceController priceController;

  int selectedSession = 1;
  int selectedDuration = 3;
  int? selectedPetId;
  String? selectedPet;

  @override
    void initState() {
      super.initState();

      petsController = Get.isRegistered<Petslistcontroller>()
          ? Get.find<Petslistcontroller>()
          : Get.put(Petslistcontroller());

      groomingController = Get.isRegistered<GroomingServiceController>()
          ? Get.find<GroomingServiceController>()
          : Get.put(GroomingServiceController());

      priceController = Get.isRegistered<GroomingPlanPriceController>()
          ? Get.find<GroomingPlanPriceController>()
          : Get.put(GroomingPlanPriceController());

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        await groomingController.fetchServiceDetails(widget.serviceId);

        if (!mounted) return;

        final plans =
            groomingController.service.value?.pricingPlans ?? [];

        final existingItem = widget.existingCartItem;

        if (existingItem != null) {
          final matchingPlan = plans.where(
            (plan) =>
                plan.sessionsPerMonth == existingItem.sessionsPerMonth &&
                plan.numberOfMonths == existingItem.numberOfMonths,
          );

          setState(() {
            selectedSession = existingItem.sessionsPerMonth ??
                (plans.isNotEmpty ? plans.first.sessionsPerMonth : 1);

            selectedDuration = existingItem.numberOfMonths ??
                (matchingPlan.isNotEmpty
                    ? matchingPlan.first.numberOfMonths
                    : plans.isNotEmpty
                        ? plans.first.numberOfMonths
                        : 3);

            selectedPetId = existingItem.petId;
          });
        } else if (plans.isNotEmpty) {
          setState(() {
            selectedSession = plans.first.sessionsPerMonth;
            selectedDuration = plans.first.numberOfMonths;
          });
        }
      });

      // Keep the pet fetch here only if Petslistcontroller.onInit()
      // does not already fetch pets automatically.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (petsController.userPets.isEmpty) {
          await petsController.loadUserPets(null);
        }

        if (!mounted) return;

        final editItem = widget.existingCartItem;

        if (editItem != null) {
          final matchingPets = petsController.userPets.where(
            (pet) => pet.petId == editItem.petId,
          );

          if (matchingPets.isNotEmpty) {
            setState(() {
              selectedPetId = matchingPets.first.petId;
              selectedPet = matchingPets.first.name;
            });

            await _refreshPlanPrice();
          }
        }
      });
    }

    GroomingPricingPlan? get selectedPricingPlan {
      final plans =
          groomingController.service.value?.pricingPlans ??
              <GroomingPricingPlan>[];

      for (final plan in plans) {
        if (plan.sessionsPerMonth == selectedSession &&
            plan.numberOfMonths == selectedDuration) {
          return plan;
        }
      }

      return null;
    }

    List<int> get availableSessions {
      final plans =
          groomingController.service.value?.pricingPlans ??
              <GroomingPricingPlan>[];

      final sessions = plans
          .map((plan) => plan.sessionsPerMonth)
          .toSet()
          .toList();

      sessions.sort();
      return sessions;
    }

    List<GroomingPricingPlan> get availableDurations {
      final plans =
          groomingController.service.value?.pricingPlans ??
              <GroomingPricingPlan>[];

      final matching = plans
          .where((plan) => plan.sessionsPerMonth == selectedSession)
          .toList();

      matching.sort(
        (a, b) => a.numberOfMonths.compareTo(b.numberOfMonths),
      );

      return matching;
    }

    int get selectedTotalSessions =>
        selectedPricingPlan?.totalSessions ?? 0;

    int? get selectedTotalPrice {
      final price = selectedPricingPlan?.price;
      if (price == null) return null;

      final amount = double.tryParse(price);
      return amount?.round();
    }


    Future<void> _openAddPetPage() async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddPetPage(),
        ),
      );

      if (!mounted || result == null) return;

      await petsController.loadUserPets(null);

      if (!mounted) return;

      final matchingPets = petsController.userPets
          .where((pet) => pet.name == result.toString())
          .toList();

      if (matchingPets.isNotEmpty) {
        setState(() {
          selectedPet = matchingPets.first.name;
          selectedPetId = matchingPets.first.petId;
        });
      }
    }


    Future<void> _refreshPlanPrice() async {
      final petId = selectedPetId;

      if (petId == null || selectedPet == null) {
        priceController.clearPrice();
        return;
      }

      await priceController.fetchPrice(
        serviceId: widget.serviceId,
        petId: petId,
        sessionsPerMonth: selectedSession,
        numberOfMonths: selectedDuration,
      );
    }

    GroomingPlanPriceModel? get currentPriceResult {
      final result = priceController.priceResult.value;

      if (result == null ||
          result.serviceId != widget.serviceId ||
          result.petId != selectedPetId ||
          result.sessionsPerMonth != selectedSession ||
          result.numberOfMonths != selectedDuration ||
          result.pricingPlanId <= 0) {
        return null;
      }

      return result;
    }



    // Future<void> _openAddPetBottomSheet() async {
    //   final PetDetails? newPet = await showModalBottomSheet<PetDetails>(
    //     context: context,
    //     isScrollControlled: true,
    //     backgroundColor: Colors.white,
    //     shape: const RoundedRectangleBorder(
    //       borderRadius: BorderRadius.vertical(
    //         top: Radius.circular(24),
    //       ),
    //     ),
    //     builder: (_) => const AddPetBottomSheet(),
    //   );

    //   if (!mounted || newPet == null) return;

    //   // The add-pet page should save the pet to the backend.
    //   // Reload the API so the dropdown uses saved pet records.
    //   await petsController.loadUserPets(null);

    //   if (!mounted) return;

    //   final matchingPets = petsController.userPets
    //       .where((pet) => pet.name == newPet.name)
    //       .toList();

    //   if (matchingPets.isNotEmpty) {
    //     setState(() {
    //       selectedPet = matchingPets.first.name;
    //     });
    //   } else {
    //     Get.snackbar(
    //       'Pet added',
    //       'Pet details were returned, but the saved pet was not '
    //           'found in the refreshed list. Please refresh and select it.',
    //     );
    //   }
    // }

  @override
  Widget build(BuildContext context) {
    final plan = selectedPricingPlan;
    final totalSessions = plan?.totalSessions ?? 0;
    final totalPrice = double.tryParse(plan?.price ?? '');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
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
          flexibleSpace: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 220,
              height: 110,
              child: Image.network(
                'https://app.pawdli.com/media/static/topimage.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                final priceResult = currentPriceResult;

                String summary;

                if (selectedPetId == null) {
                  summary = 'Select your pet';
                } else if (priceController.isLoading.value) {
                  summary = 'Calculating price...';
                } else if (priceResult != null) {
                  summary =
                      '${widget.serviceName} • '
                      '${priceResult.sessionsPerMonth} Session'
                      '${priceResult.sessionsPerMonth > 1 ? 's' : ''} • '
                      '${priceResult.numberOfMonths} Months\n'
                      'Total ${priceResult.totalSessions} Sessions';
                } else {
                  summary = 'Price unavailable for this selection';
                }

                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        summary,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (priceController.isLoading.value)
                      const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Text(
                        priceResult?.formattedPrice ?? '—',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                );
              }),

              const SizedBox(height: 16),
              
              Obx(() {
                final priceResult = currentPriceResult;

                final canContinue =
                    selectedPetId != null &&
                    selectedPet != null &&
                    priceResult != null &&
                    !priceController.isLoading.value;

                return SizedBox(
                  height: 55,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colours.primarycolour,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: !canContinue
                        ? null
                        : () {
                            final result = currentPriceResult;

                            if (result == null || selectedPet == null) {
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GroomingAddDetailsPage(
                                  serviceName: widget.serviceName,
                                  selectedSession: result.sessionsPerMonth,
                                  selectedDuration: result.numberOfMonths,
                                  totalSessions: result.totalSessions,
                                  totalPrice: result.roundedPrice,
                                  selectedPet: selectedPet!,
                                  serviceId: result.serviceId,
                                  pricingPlanId: result.pricingPlanId,
                                  petId: result.petId,
                                  editCartItemId: widget.editCartItemId,
                                  existingCartItem: widget.existingCartItem,
                                ),
                              ),
                            );
                          },
                    child: const Text(
                      'Add Your Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepperSection(),
            const SizedBox(height: 20),
            Text(
              "Let's Build Your Plan",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colours.brownColour,
              ),
            ),
            // const SizedBox(height: 20),

            // Selected grooming service
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                      color: Colours.secondarycolour,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.bathtub_outlined,
                      size: 40,
                      color: Colours.primarycolour,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.serviceName,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // const SizedBox(height: 20),
            _sectionTitle('Choose your pet'),
            const SizedBox(height: 12),

            // Pets loaded from the user's API
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colours.brownColour,
                      ),
                    ),
                    child: Obx(() {
                      if (petsController.isLoading.value &&
                          petsController.userPets.isEmpty) {
                        return const SizedBox(
                          height: 56,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final pets = petsController.userPets
                          .where((pet) =>
                              (pet.name ?? '').trim().isNotEmpty)
                          .toList();

                      final validNames =
                          pets.map((pet) => pet.name!).toSet();

                      if (selectedPet != null &&
                          !validNames.contains(selectedPet)) {
                        selectedPet = null;
                      }

                      return DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedPet,
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colours.brownColour,
                            size: 28,
                          ),
                          hint: Text(
                            pets.isEmpty ? 'No saved pets' : 'Select Pet',
                            style: TextStyle(
                              color: Colours.textColour,
                              fontSize: 14,
                            ),
                          ),
                          items: pets.asMap().entries.map((entry) {
                            final index = entry.key;
                            final pet = entry.value;

                            final petColor = index.isEven
                                ? Colours.primarycolour
                                : Colours.brownColour;

                            return DropdownMenuItem<String>(
                              value: pet.name!,
                              child: Row(
                                children: [
                                  Container(
                                    height: 34,
                                    width: 34,
                                    decoration: BoxDecoration(
                                      color: petColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.pets_rounded,
                                      color: petColor,
                                      size: 19,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      pet.name!,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: petColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (selectedPet == pet.name)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: petColor,
                                      size: 20,
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          
                          onChanged: pets.isEmpty
                              ? null
                              : (value) {
                                  setState(() {
                                    selectedPet = value;

                                    final matchingPets = pets.where(
                                      (pet) => pet.name == value,
                                    );

                                    selectedPetId = matchingPets.isNotEmpty
                                        ? matchingPets.first.petId
                                        : null;
                                  });
                                  _refreshPlanPrice();
                                },

                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  height: 50,
                  width: 50,
                  child: OutlinedButton(
                    onPressed: _openAddPetPage,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colours.brownColour,
                      side: BorderSide(
                        color: Colours.brownColour,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(Icons.add, size: 35),
                  ),
                ),
              ],
            ),

            Obx(() {
              if (petsController.errorMessage.value.isEmpty) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        petsController.errorMessage.value,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          petsController.loadUserPets(null),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),
            _sectionTitle('Sessions per month'),
            const SizedBox(height: 15),

            Obx(() {
              final sessions = availableSessions;

              if (groomingController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (sessions.isEmpty) {
                return const Text('No pricing plans available.');
              }

              return SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: sessions.map((session) {
                    return _sessionCard(session);
                  }).toList(),
                ),
              );
            }),

            const SizedBox(height: 24),
            _sectionTitle('Choose your plan duration'),
            const SizedBox(height: 15),

            Obx(() {
              final durations = availableDurations;

              if (durations.isEmpty) {
                return const Text(
                  'No durations available for this session count.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                );
              }

              return SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: durations.map((plan) {
                    return _durationCard(
                      plan.numberOfMonths,
                      plan.formattedPrice,
                    );
                  }).toList(),
                ),
              );
            }),

            // Space above the fixed price summary
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _sessionCard(int value) {
    final selected = selectedSession == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSession = value;

          final durations = availableDurations;

          if (durations.isNotEmpty &&
              !durations.any(
                (plan) => plan.numberOfMonths == selectedDuration,
              )) {
            selectedDuration = durations.first.numberOfMonths;
          }
        });
        _refreshPlanPrice();
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colours.secondarycolour,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? Colours.primarycolour
                : Colours.brownColour,
          ),
        ),
        child: Center(
          child: Text(
            '$value Session${value > 1 ? 's' : ''}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _durationCard(int month, String price) {
    final selected = selectedDuration == month;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDuration = month;
        });
        _refreshPlanPrice();
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colours.secondarycolour,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? Colours.primarycolour
                : Colours.brownColour,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$month Months',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
            // const Spacer(),
            // Text(
            //   price,
            //   style: const TextStyle(
            //     color: Colors.black,
            //     fontSize: 14,
            //     fontWeight: FontWeight.w600,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperSection() {
    const labels = [
      'Build\nPlan',
      'Add\nDetails',
      'Add\nAddress',
      'Select\nSlot',
      'Preview\nSchedule',
    ];

    return Column(
      children: [
        Row(
          children: List.generate(9, (index) {
            if (index.isEven) {
              final step = index ~/ 2;

              return Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: step == 0
                      ? Colours.primarycolour
                      : Colors.white,
                  border: Border.all(
                    color: step == 0
                        ? Colours.primarycolour
                        : Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                child: step == 0
                    ? Center(
                        child: Container(
                          height: 10,
                          width: 10,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              );
            }

            return Expanded(
              child: Container(
                height: 1,
                color: Colors.grey.shade300,
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(labels.length, (index) {
            return Expanded(
              child: Text(
                labels[index],
                textAlign: index == 0
                    ? TextAlign.start
                    : TextAlign.center,
                style: TextStyle(
                  color: index == 0
                      ? Colours.brownColour
                      : Colors.grey,
                  fontSize: 10,
                  fontWeight: index == 0
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
