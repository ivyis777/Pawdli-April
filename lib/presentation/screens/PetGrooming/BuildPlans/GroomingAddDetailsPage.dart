import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/model/ServiceCartModel.dart';
import 'package:pawlli/presentation/screens/PetGrooming/GroomingAddress/GroomingAddressPage.dart';

class GroomingAddDetailsPage extends StatefulWidget {
  final String serviceName;
  final int selectedSession;
  final int selectedDuration;
  final int totalSessions;
  final int totalPrice;
  final String selectedPet;
  final int petId;
  final int serviceId;
  final int pricingPlanId;
  final int? editCartItemId;
  final GroomingCartItemModel? existingCartItem;


  const GroomingAddDetailsPage({
    super.key,
    required this.serviceName,
    required this.selectedSession,
    required this.selectedDuration,
    required this.totalSessions,
    required this.totalPrice,
    required this.selectedPet,
    required this.petId,
    required this.serviceId,
    required this.pricingPlanId,
    this.editCartItemId,
    this.existingCartItem,
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

  double peopleComfort = 0;
  double dogComfort = 0;

  final List<String> behaviourOptions = [
    "Hates paws touched",
    "Nervous around dryers",
    "Growls when brushed",
    "Wiggles during nail trim",
  ];

  final Set<String> selectedBehaviour = {};

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

    final existing = widget.existingCartItem;

    if (existing != null) {
      peopleComfort = comfortIndex(existing.peopleComfortLevel);
      dogComfort = comfortIndex(existing.dogsComfortLevel);
    }
  }

  double comfortIndex(String? value) {
    switch (value?.trim().replaceAll('\n', ' ')) {
      case 'Not Comfortable':
        return 0;
      case 'Uncomfortable Sometimes':
        return 1;
      case 'Mostly Comfortable':
        return 2;
      case 'Very Comfortable':
        return 3;
      default:
        return 0;
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

            buildStepperSection(),

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

            const SizedBox(height: 24),

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

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 52,
              child:
                  ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BuildPlanAddressPage(
                        serviceName: widget.serviceName,
                        selectedSession: widget.selectedSession,
                        selectedDuration: widget.selectedDuration,
                        totalSessions: widget.totalSessions,
                        totalPrice: widget.totalPrice,
                        selectedPet: widget.selectedPet,
                        petId: widget.petId,
                        serviceId: widget.serviceId,
                        pricingPlanId: widget.pricingPlanId,
                        peopleComfortLevel: comfortLabels[peopleComfort.round()].replaceAll('\n', ' '),
                        dogsComfortLevel: comfortLabels[dogComfort.round()].replaceAll('\n', ' '),
                        contactNumber: '7207396322',
                        latitude: 0.0,
                        longitude: 0.0,
                        editCartItemId: widget.editCartItemId,
                        existingCartItem: widget.existingCartItem,
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