import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/SymptomController.dart';
import 'package:pawlli/gen/fonts.gen.dart';

double getResponsiveFont(
    BuildContext context,
    double size,
    ) {

  double screenWidth =
      MediaQuery.of(context).size.width;

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

class SymptomWidget extends StatefulWidget {

  final Function(

    List<String> symptomNames,

    List<String> symptomIds,

  ) onSymptomsSelected;

  const SymptomWidget({
    super.key,
    required this.onSymptomsSelected,
  });

  @override
  State<SymptomWidget> createState() =>
      _SymptomWidgetState();
}

class _SymptomWidgetState
    extends State<SymptomWidget> {

  final SymptomController symptomController =
    Get.put(SymptomController());

  Set<String> selectedSymptoms = {};

  Set<String> selectedSymptomIds = {};

  List<TextEditingController>
        otherControllers = [
      TextEditingController(),
    ];

  bool showOtherField = false;

  @override
  Widget build(BuildContext context) {

    final screenWidth =
        MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        /// TITLE
        Text(
          "Symptoms".tr,

          style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
        ),

        const SizedBox(height: 14),

        /// API DATA
        Obx(() {

          if (symptomController
              .isLoading.value) {

            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          return Wrap(
            spacing: 14,
            runSpacing: 14,

            children: [

              /// API SYMPTOMS
              ...symptomController
                  .symptomsList
                  .map((symptom) {

                return SizedBox(
                  width:
                      (screenWidth - 50) / 2,

                  child:
                      buildSymptomButton(

                      symptom.name ?? '',

                      symptom.id.toString(),
                    ),
                );
              }),

              /// OTHERS BUTTON
              SizedBox(
                width:
                    (screenWidth - 50) / 2,

                child: buildSymptomButton(
                  "Others",
                  "",
                ),
              ),
            ],
          );
        }),

        /// OTHER TEXTFIELD
        if (showOtherField) ...[

          const SizedBox(height: 16),

          Column(
            children: List.generate(
              otherControllers.length,
              (index) {

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                  ),

                  child: Row(
                    children: [

                      Expanded(
                        child: TextField(

                          controller:
                              otherControllers[index],

                          maxLines: 1,

                          onChanged: (value) {

                            updateSelectedSymptoms();
                          },

                          decoration: InputDecoration(

                            labelText: "Write symptom", labelStyle: TextStyle(color: Colors.black54),

                            filled: true,

                            fillColor: Colors.white,

                            contentPadding:
                                const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),

                            enabledBorder: OutlineInputBorder(

                              borderRadius:
                                  BorderRadius.circular(12),

                              borderSide: BorderSide(
                                color: Colours.primarycolour.withOpacity(0.4),

                                width: 1,
                              ),
                            ),

                            focusedBorder: OutlineInputBorder(

                              borderRadius:
                                  BorderRadius.circular(12),

                              borderSide: BorderSide(
                                color: Colours.primarycolour,
                                width: 1.5,
                              ),
                            ),

                            border: OutlineInputBorder(

                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Container(
                        height: screenWidth * 0.10,
                        width: screenWidth * 0.10,

                        decoration:
                            BoxDecoration(
                          color: Colours.brownColour,
                          shape: BoxShape.circle,
                        ),

                        child: IconButton(

                          onPressed: () {

                            setState(() {

                              if (index ==
                                  otherControllers.length -
                                      1) {

                                otherControllers.add(
                                  TextEditingController(),
                                );

                              } else {

                                otherControllers
                                    .removeAt(index);

                                updateSelectedSymptoms();
                              }
                            });
                          },

                          icon: Icon(

                            index ==
                                    otherControllers
                                            .length -
                                        1
                                ? Icons.add
                                : Icons.remove,

                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  /// BUTTON
  Widget buildSymptomButton(

            String symptom,

            String symptomId,
        ) {

    final isSelected =
        selectedSymptoms.contains(
            symptom);

    return ElevatedButton(

      onPressed: () {

        setState(() {

          if (isSelected) {

              selectedSymptoms.remove(
                  symptom);

              selectedSymptomIds.remove(
                  symptomId);

              if (symptom == "Others") {

                showOtherField = false;

                otherControllers = [
                  TextEditingController(),
                ];
              }

            } else {

            
              selectedSymptoms.add(
                  symptom);

              /// STORE IDS
              if (symptom != "Others") {

                selectedSymptomIds.add(
                    symptomId);
              }

              if (symptom == "Others") {

                showOtherField = true;
              }
            }
        });

        updateSelectedSymptoms();
      },

      style: ElevatedButton.styleFrom(

        backgroundColor:
            isSelected
                ? Colours.primarycolour
                : Colors.white,

        elevation: 0,

        side: BorderSide(

          color: isSelected
              ? Colours.primarycolour
              : Colours.primarycolour
                  .withOpacity(0.4),

          width: 1.5,
        ),

        shape:
            RoundedRectangleBorder(

          borderRadius:
              BorderRadius.circular(15),
        ),

        minimumSize:
            const Size(150, 50),
      ),

      child: Text(
        symptom,

        textAlign: TextAlign.center,

        style: TextStyle(

          fontSize:
              getResponsiveFont(
                  context,
                  13),

          // fontFamily:
          //     FontFamily.Cairo,

          color: isSelected
              ? Colours.secondarycolour
              : Colors.black54,
        ),
      ),
    );
  }

  /// UPDATE SELECTED
  void updateSelectedSymptoms() {

    List<String> finalSymptoms =
        selectedSymptoms.toList();

    /// REMOVE OTHERS
    finalSymptoms.remove("Others");

    /// ADD CUSTOM TEXT
    for (var controller
        in otherControllers) {

      if (controller.text
          .trim()
          .isNotEmpty) {

        finalSymptoms.add(
          controller.text.trim(),
        );
      }
    }

    /// CALLBACK
    widget.onSymptomsSelected(

      finalSymptoms,

      selectedSymptomIds.toList(),
    );

    print(
        "SYMPTOM NAMES : $finalSymptoms");

    print(
        "SYMPTOM IDS : ${selectedSymptomIds.toList()}");
  }
}