import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/petslistcontroller.dart';
import 'package:pawlli/data/model/ServiceCartModel.dart';
import 'package:pawlli/presentation/screens/PetGrooming/OneTimeService/AddAddressPage.dart';
import 'package:pawlli/presentation/screens/add%20pet/addpet.dart';

class GroomingAddDetailsPage extends StatefulWidget {
  final String serviceName;
  final int selectedSession;
  final int selectedDuration;
  final int totalSessions;
  final int totalPrice;
  final String selectedPet;
  final List<Map<String, dynamic>> selectedServices;
  final int? editCartItemId;
  final GroomingCartItemModel? existingCartItem;
  final List<GroomingCartItemModel> existingCartItems;
  final List<int> existingPackageIds;

    const GroomingAddDetailsPage({
    super.key,
    required this.serviceName,
    required this.selectedSession,
    required this.selectedDuration,
    required this.totalSessions,
    required this.totalPrice,
    required this.selectedPet,
    required this.selectedServices,
    this.editCartItemId,
    this.existingCartItem,
    this.existingCartItems = const [],
    this.existingPackageIds = const [],
  });

  @override

  State<GroomingAddDetailsPage> createState() =>

      _GroomingAddDetailsPageState();

}

class _GroomingAddDetailsPageState

    extends State<GroomingAddDetailsPage> {

  // 0 = Not Comfortable

  // 1 = Uncomfortable Sometimes

  // 2 = Mostly Comfortable

  // 3 = Very Comfortable

  late final Petslistcontroller petsController;

  String? selectedPetName;
  int? selectedPetId;

  double peopleComfort = 0;

  double dogComfort = 0;

  final List<String> behaviourOptions = [

    "Hates paws touched",

    "Nervous around dryers",

    "Growls when brushed",

    "Wiggles during nail trim",

  ];

  final Set<String> selectedBehaviour = {};

  String getComfortLevel(double value) {
  const labels = [
    'Not Comfortable',
    'Uncomfortable Sometimes',
    'Mostly Comfortable',
    'Very Comfortable',
  ];

  return labels[value.round().clamp(0, 3)];
}

  final List<String> comfortLabels = [
    "Not\nComfortable",
    "Uncomfortable\nSometimes",
    "Mostly\nComfortable",
    "Very\nComfortable",
  ];

  final List<String> comfortEmoji = [
    "☹️",
    "😐",
    "🙂",
    "😁",
  ];

  @override
  void initState() {
    super.initState();

    selectedPetName = widget.selectedPet.trim().isEmpty
        ? null
        : widget.selectedPet.trim();

    petsController = Get.isRegistered<Petslistcontroller>()
        ? Get.find<Petslistcontroller>()
        : Get.put(Petslistcontroller());

    // Restore comfort levels when editing an existing cart item.
    final existingItem = widget.existingCartItem;

    if (existingItem != null) {
      peopleComfort = _comfortValue(
        existingItem.peopleComfortLevel,
      );

      dogComfort = _comfortValue(
        existingItem.dogsComfortLevel,
      );

      selectedPetId = existingItem.petId > 0
          ? existingItem.petId
          : null;
    }

    // Load pets first, then restore the matching pet name.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await petsController.loadUserPets(null);

      if (!mounted) return;

      final existingPetId = widget.existingCartItem?.petId;

      if (existingPetId == null || existingPetId <= 0) return;

      final matchingPets = petsController.userPets.where(
        (pet) => pet.petId == existingPetId,
      );

      if (matchingPets.isNotEmpty) {
        setState(() {
          selectedPetId = matchingPets.first.petId;
          selectedPetName = matchingPets.first.name?.trim();
        });
      }
    });
  }

  double _comfortValue(String label) {
    switch (label.trim().toLowerCase()) {
      case 'not comfortable':
        return 0;
      case 'uncomfortable sometimes':
        return 1;
      case 'mostly comfortable':
        return 2;
      case 'very comfortable':
        return 3;
      default:
        return 0;
    }
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

    final petName = result.toString().trim();

    final matchingPets = petsController.userPets.where(
      (pet) => pet.name?.trim() == petName,
    ).toList();

    if (matchingPets.isNotEmpty) {
      setState(() {
        selectedPetName = matchingPets.first.name?.trim();
        selectedPetId = matchingPets.first.petId;
      });
    }
  }


  @override

  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(

      backgroundColor: Colors.white,

      // =========================================================

      // APP BAR

      // =========================================================

      appBar: PreferredSize(

        preferredSize: const Size.fromHeight(90),

        child: AppBar(

          elevation: 0,

          backgroundColor: Colors.transparent,

          foregroundColor: Colors.black,

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

      // =========================================================

      // BOTTOM SUMMARY

      // =========================================================

      bottomNavigationBar: _buildBottomBar(context),

      // =========================================================

      // BODY

      // =========================================================

      body: SingleChildScrollView(

        padding: EdgeInsets.symmetric(

          horizontal: screenWidth * 0.05,

          vertical: 10,

        ),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // =====================================================

            // STEPPER

            // =====================================================

            buildOneTimeStepperSection(),

            const SizedBox(height: 24),

            // =====================================================

            // TITLE

            // =====================================================

            Text(

              "Add Your Details",

              style: TextStyle(

                fontSize: screenWidth * 0.045,

                fontWeight: FontWeight.w600,

                color: Colours.brownColour,

              ),

            ),

            const SizedBox(height: 18),

            // ===========================================
            // CHOOSE YOUR PET
            // ===========================================

            Text(
              'Choose your pet',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                          .where(
                            (pet) => (pet.name ?? '').trim().isNotEmpty,
                          )
                          .toList();

                      final validPetIds = pets
                          .map((pet) => pet.petId)
                          .toSet();

                      // Ensure selected pet is available.
                      final int? dropdownValue =
                          selectedPetId != null &&
                                  validPetIds.contains(selectedPetId)
                              ? selectedPetId
                              : null;

                      return DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: dropdownValue,
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

                            return DropdownMenuItem<int>(
                              value: pet.petId,
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

                                  if (selectedPetId == pet.petId)
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
                                    selectedPetId = value;

                                    final matchingPets = pets.where(
                                      (pet) => pet.petId == value,
                                    );

                                    selectedPetName =
                                        matchingPets.isNotEmpty
                                            ? matchingPets.first.name?.trim()
                                            : null;
                                  });
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
                    child: const Icon(
                      Icons.add,
                      size: 35,
                    ),
                  ),
                ),
              ],
            ),

            // const SizedBox(height: 28),

            const SizedBox(height: 10),

            // Obx(() {

            //   if (petsController.isLoading.value &&

            //       petsController.userPets.isEmpty) {

            //     return const Padding(

            //       padding: EdgeInsets.symmetric(vertical: 12),

            //       child: Center(child: CircularProgressIndicator()),

            //     );

            //   }
              
            //   if (petsController.userPets.isEmpty) {
            //     return Container(
            //       width: double.infinity,
            //       padding: const EdgeInsets.all(16),
            //       decoration: BoxDecoration(
            //         color: Colors.grey.shade50,
            //         borderRadius: BorderRadius.circular(14),
            //         border: Border.all(color: Colours.brownColour),
            //       ),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           const Text(
            //             'No pets found. Please add a pet first.',
            //             style: TextStyle(
            //               color: Colors.black54,
            //               fontSize: 14,
            //             ),
            //           ),
            //           const SizedBox(height: 12),
            //           SizedBox(
            //             width: double.infinity,
            //             child: OutlinedButton.icon(
            //               onPressed: _openAddPetPage,
            //               icon: const Icon(Icons.add, size: 20),
            //               label: const Text('Add Pet'),
            //               style: OutlinedButton.styleFrom(
            //                 foregroundColor: Colours.brownColour,
            //                 side: BorderSide(
            //                   color: Colours.brownColour,
            //                 ),
            //                 shape: RoundedRectangleBorder(
            //                   borderRadius: BorderRadius.circular(12),
            //                 ),
            //                 padding: const EdgeInsets.symmetric(
            //                   vertical: 12,
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //     );
            //   }

            //   final List<String> petNames = petsController.userPets

            //       .map((pet) => pet.name?.trim() ?? '')

            //       .where((name) => name.isNotEmpty)

            //       .toSet()

            //       .toList();

            //   if (selectedPetName != null &&

            //       !petNames.contains(selectedPetName)) {

            //     selectedPetName = null;

            //   }

            //   return DropdownButtonFormField<String>(

            //     value: selectedPetName,

            //     isExpanded: true,

            //     decoration: InputDecoration(

            //       hintText: 'Choose your pet',

            //       prefixIcon: const Icon(Icons.pets),

            //       filled: true,

            //       fillColor: Colors.grey.shade50,

            //       contentPadding: const EdgeInsets.symmetric(

            //         horizontal: 14,

            //         vertical: 14,

            //       ),

            //       border: OutlineInputBorder(

            //         borderRadius: BorderRadius.circular(14),

            //         borderSide: BorderSide(color: Colours.brownColour),

            //       ),

            //       enabledBorder: OutlineInputBorder(

            //         borderRadius: BorderRadius.circular(14),

            //         borderSide: BorderSide(color: Colours.brownColour),

            //       ),

            //       focusedBorder: OutlineInputBorder(

            //         borderRadius: BorderRadius.circular(14),

            //         borderSide: BorderSide(

            //           color: Colours.primarycolour,

            //           width: 1.5,

            //         ),

            //       ),

            //     ),

            //     items: petNames.map((name) {

            //       return DropdownMenuItem<String>(

            //         value: name,

            //         child: Text(name, overflow: TextOverflow.ellipsis),

            //       );

            //     }).toList(),

            //     onChanged: (String? value) {
            //       setState(() {
            //         selectedPetName = value;

            //         final matchingPets = petsController.userPets.where(
            //           (pet) => pet.name?.trim() == value,
            //         ).toList();

            //         selectedPetId = matchingPets.isNotEmpty
            //             ? matchingPets.first.petId
            //             : null;
            //       });
            //     },
            //   );
            // }),

            const SizedBox(height: 28),

            // =====================================================

            // QUESTION 1

            // =====================================================

            _buildQuestionSection(

              context: context,

              title: "How comfortable is your dog with",

              boldText: " other people?",

              value: peopleComfort,

              onChanged: (value) {

                setState(() {

                  peopleComfort = value;

                });

              },

            ),

            const SizedBox(height: 32),

            // =====================================================

            // QUESTION 2

            // =====================================================

            _buildQuestionSection(

              context: context,

              title: "How does your dog react around",

              boldText: " other dogs?",

              value: dogComfort,

              onChanged: (value) {

                setState(() {

                  dogComfort = value;

                });

              },

            ),

            const SizedBox(height: 32),

            // =====================================================

            // GROOMER SHOULD KNOW

            // =====================================================

            Text(

              "Anything your groomer should know?",

              style: TextStyle(

                fontSize: screenWidth * 0.035,

                fontWeight: FontWeight.w500,

                color: Colors.black87,

              ),

            ),

            const SizedBox(height: 16),

            Wrap(

              spacing: 10,

              runSpacing: 12,

              children: behaviourOptions.map((item) {

                return _buildBehaviourChip(

                  context,

                  item,

                );

              }).toList(),

            ),

            // bottom nav space

            const SizedBox(height: 130),

          ],

        ),

      ),

    );

  }

  // =============================================================

  // QUESTION + EMOJI + SLIDER

  // =============================================================

  Widget _buildQuestionSection({

    required BuildContext context,

    required String title,

    required String boldText,

    required double value,

    required ValueChanged<double> onChanged,

  }) {

    final screenWidth =

        MediaQuery.of(context).size.width;

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        // QUESTION

        RichText(

          text: TextSpan(

            style: TextStyle(

              fontSize: screenWidth * 0.034,

              color: Colors.black87,

              height: 1.4,

            ),

            children: [

              TextSpan(

                text: title,

              ),

              TextSpan(

                text: boldText,

                style: const TextStyle(

                  fontWeight: FontWeight.bold,

                ),

              ),

            ],

          ),

        ),

        const SizedBox(height: 20),

        // =========================================================

        // EMOJIS

        // =========================================================

        Padding(

          padding: const EdgeInsets.symmetric(

            horizontal: 12,

          ),

          child: Row(

            mainAxisAlignment:

                MainAxisAlignment.spaceBetween,

            children: List.generate(

              comfortEmoji.length,

              (index) {

                final isSelected =

                    value.round() == index;

                return GestureDetector(

                  onTap: () {

                    onChanged(index.toDouble());

                  },

                  child: AnimatedContainer(

                    duration:

                        const Duration(milliseconds: 200),

                    height: 48,

                    width: 48,

                    alignment: Alignment.center,

                    decoration: BoxDecoration(

                      color: isSelected

                          ? Colours.secondarycolour

                          : Colors.transparent,

                      shape: BoxShape.circle,

                    ),

                    child: Text(

                      comfortEmoji[index],

                      style: TextStyle(

                        fontSize:

                            screenWidth * 0.065,

                      ),

                    ),

                  ),

                );

              },

            ),

          ),

        ),

        const SizedBox(height: 6),

        // =========================================================

        // SLIDER

        // =========================================================

        SliderTheme(

          data: SliderTheme.of(context).copyWith(

            trackHeight: 7,

            activeTrackColor:

                Colours.primarycolour,

            inactiveTrackColor:

                Colors.grey.shade200,

            thumbColor:

                Colors.white,

            thumbShape:

                const RoundSliderThumbShape(

              enabledThumbRadius: 14,

              elevation: 2,

            ),

            overlayColor:

                Colours.primarycolour.withOpacity(0.10),

            overlayShape:

                const RoundSliderOverlayShape(

              overlayRadius: 20,

            ),

            activeTickMarkColor:

                Colours.primarycolour,

            inactiveTickMarkColor:

                Colors.grey.shade400,

            tickMarkShape:

                const RoundSliderTickMarkShape(

              tickMarkRadius: 1.5,

            ),

          ),

          child: Slider(

            min: 0,

            max: 3,

            divisions: 3,

            value: value,

            onChanged: onChanged,

          ),

        ),

        const SizedBox(height: 2),

        // =========================================================

        // SLIDER LABELS

        // =========================================================

        Row(

          crossAxisAlignment:

              CrossAxisAlignment.start,

          children: List.generate(

            comfortLabels.length,

            (index) {

              return Expanded(

                child: Text(

                  comfortLabels[index],

                  textAlign:

                      TextAlign.center,

                  style: TextStyle(

                    fontSize:

                        screenWidth * 0.025,

                    height: 1.35,

                    color:

                        Colors.grey.shade600,

                    fontWeight:

                        FontWeight.w500,

                  ),

                ),

              );

            },

          ),

        ),

      ],

    );

  }

  // =============================================================

  // BEHAVIOUR CHIP

  // =============================================================

  Widget _buildBehaviourChip(

    BuildContext context,

    String text,

  ) {

    final screenWidth =

        MediaQuery.of(context).size.width;

    final selected =

        selectedBehaviour.contains(text);

    return GestureDetector(

      onTap: () {

        setState(() {

          if (selected) {

            selectedBehaviour.remove(text);

          } else {

            selectedBehaviour.add(text);

          }

        });

      },

      child: AnimatedContainer(

        duration:

            const Duration(milliseconds: 200),

        padding: const EdgeInsets.symmetric(

          horizontal: 16,

          vertical: 10,

        ),

        decoration: BoxDecoration(

          color: selected

              ? Colours.secondarycolour

              : Colors.grey.shade50,

          borderRadius:

              BorderRadius.circular(14),

          border: Border.all(

            color: selected

                ? Colours.primarycolour

                : Colors.transparent,

            width: 1,

          ),

        ),

        child: Text(

          text,

          style: TextStyle(

            fontSize:

                screenWidth * 0.03,

            color: selected

                ? Colours.primarycolour

                : Colors.grey.shade700,

            fontWeight:

                FontWeight.w500,

          ),

        ),

      ),

    );

  }

  // =============================================================

  // BOTTOM BAR

  // =============================================================

  Widget _buildBottomBar(

    BuildContext context,

  ) {

    final screenWidth =

        MediaQuery.of(context).size.width;

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

            color:

                Colors.black.withOpacity(0.06),

            blurRadius: 12,

            offset:

                const Offset(0, -3),

          ),

        ],

      ),

      child: SafeArea(

        top: false,

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
                    "${widget.selectedServices.length} Services Added\n"
                    "${widget.selectedServices.map((service) => service['name'] ?? service['serviceName'] ?? '').where((name) => name.toString().isNotEmpty).join(', ')}",

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

            const SizedBox(height: 14),

            SizedBox(

              width: double.infinity,

              height: 52,

              child:

                  ElevatedButton(

                onPressed: () {

                  if (selectedPetName == null ||
                      selectedPetName!.trim().isEmpty ||
                      selectedPetId == null) {
                    Get.snackbar(
                      'Select pet',
                      'Please select a valid pet before continuing.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OneTimeGroomingAddressPage(
                        serviceName: widget.serviceName,
                        selectedSession: widget.selectedSession,
                        selectedDuration: widget.selectedDuration,
                        totalSessions: widget.totalSessions,
                        totalPrice: widget.totalPrice,
                        selectedPet: selectedPetName!,
                        petId: selectedPetId!,
                        selectedServices: widget.selectedServices,
                        peopleComfortLevel: getComfortLevel(peopleComfort),
                        dogsComfortLevel: getComfortLevel(dogComfort),
                        contactNumber: '7207396322',
                        latitude: 0.0,
                        longitude: 0.0,
                        existingCartItem: widget.existingCartItem,
                        existingCartItems: widget.existingCartItems,
                        editCartItemId: widget.editCartItemId,
                        existingPackageIds: widget.existingPackageIds,
                      ),
                    ),
                  );
                },

                style:

                    ElevatedButton.styleFrom(

                  elevation: 0,

                  backgroundColor:

                      Colours.primarycolour,

                  shape:

                      RoundedRectangleBorder(

                    borderRadius:

                        BorderRadius.circular(

                            16),

                  ),

                ),

                child: Text(

                  "Continue",

                  style: TextStyle(

                    color: Colors.white,

                    fontSize:

                        screenWidth * 0.042,

                    fontWeight:

                        FontWeight.w600,

                  ),

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

  // =============================================================

  // STEPPER

  // =============================================================

  Widget buildOneTimeStepperSection() {
    final steps = <String>[
      'Add\nDetails',
      'Add\nAddress',
      'Select\nSlot',
    ];

    return Column(
      children: [
        Row(
          children: List.generate(steps.length * 2 - 1, (index) {
            if (index.isOdd) {
              return Expanded(
                child: Container(
                  height: 1.5,
                  color: Colors.grey.shade300,
                ),
              );
            }

            final stepIndex = index ~/ 2;
            final isActive = stepIndex == 0;

            return Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? Colours.primarycolour : Colors.white,
                border: Border.all(
                  color: isActive
                      ? Colours.primarycolour
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isActive
                  ? const Icon(
                      Icons.circle,
                      size: 10,
                      color: Colors.white,
                    )
                  : null,
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          children: steps.asMap().entries.map((entry) {
            final isActive = entry.key == 0;

            return Expanded(
              child: Text(
                entry.value,
                textAlign: entry.key == 0
                    ? TextAlign.left
                    : entry.key == steps.length - 1
                        ? TextAlign.right
                        : TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  height: 1.4,
                  color: isActive
                      ? Colours.brownColour
                      : Colors.grey.shade500,
                  fontWeight: isActive
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
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

            // Add Details current

            activeStep(),

            Expanded(

              child: inactiveLine(),

            ),

            inactiveStep(),

            Expanded(

              child: inactiveLine(),

            ),

            inactiveStep(),

            Expanded(

              child: inactiveLine(),

            ),

            inactiveStep(),

            Expanded(

              child: inactiveLine(),

            ),

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

                textAlign:

                    TextAlign.left,

                style: TextStyle(

                  color:

                      Colours.brownColour,

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

                textAlign:

                    TextAlign.center,

                style: TextStyle(

                  color:

                      Colours.brownColour,

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

                textAlign:

                    TextAlign.center,

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

            Expanded(

              child: Text(

                "Select\nSlot",

                textAlign:

                    TextAlign.center,

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

}