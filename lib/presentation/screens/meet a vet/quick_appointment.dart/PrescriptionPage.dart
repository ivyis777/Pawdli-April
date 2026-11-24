import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/controller/UpdatePrescriptionController.dart';
import 'package:pawlli/data/model/MedicineModel.dart';
import 'package:pawlli/data/model/PrescriptionModel.dart';
import 'package:pawlli/presentation/screens/meet%20a%20vet/appointment.dart';

class PrescriptionPage extends StatefulWidget {

  final int consultationRequestId;
  final Map<String, dynamic>?
    prescriptionData;

  const PrescriptionPage({
    super.key,
    required this.consultationRequestId,
    this.prescriptionData,
  });

  @override
  State<PrescriptionPage> createState() =>
      _PrescriptionPageState();
}

class _PrescriptionPageState
    extends State<PrescriptionPage> {

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

  final diagnosisController =
      TextEditingController();

  final doctorNotesController =
      TextEditingController();

  final precautionsController =
      TextEditingController();

  final followUpController =
      TextEditingController();

  DateTime? nextVisitDate;

  List<Map<String, dynamic>>
      medicines = [];

  @override
    void initState() {

      super.initState();

      if (widget.prescriptionData != null) {

        diagnosisController.text =
            widget.prescriptionData![
                "diagnosis"] ?? "";

        precautionsController.text =
            widget.prescriptionData![
                "precautions"] ?? "";

        followUpController.text =
            widget.prescriptionData![
                "follow_up_advice"] ?? "";

        if (widget.prescriptionData![
                "next_visit_date"] !=
            null) {

          nextVisitDate =
              DateTime.parse(

            widget.prescriptionData![
                "next_visit_date"],
          );
        }

        final medicineList =
              widget.prescriptionData!["medicines"];

          if (medicineList != null) {

            medicines = [];

            for (var med in medicineList) {

              String pattern = "I-I-I";

              if (med["morning"] == true &&
                  med["afternoon"] == false &&
                  med["night"] == false) {

                pattern = "I-0-0";

              } else if (med["morning"] == false &&
                  med["afternoon"] == true &&
                  med["night"] == false) {

                pattern = "0-I-0";

              } else if (med["morning"] == false &&
                  med["afternoon"] == false &&
                  med["night"] == true) {

                pattern = "0-0-I";

              } else if (med["morning"] == true &&
                  med["afternoon"] == true &&
                  med["night"] == false) {

                pattern = "I-I-0";

              } else if (med["morning"] == false &&
                  med["afternoon"] == true &&
                  med["night"] == true) {

                pattern = "0-I-I";

              } else if (med["morning"] == true &&
                  med["afternoon"] == false &&
                  med["night"] == true) {

                pattern = "I-0-I";
              }

              medicines.add({

                "medicine_name":
                    med["medicine_name"],

                "medicine_type":
                    med["medicine_type"] ?? "",

                "quantity":
                    med["quantity"]?.toString() ??
                    "",

                "dose_pattern":
                    pattern,

                "duration_days":
                    med["duration_days"]
                        .toString(),

                "direction_of_use":
                    med["direction_of_use"],
              });
            }
          }

      } else {

        addMedicine();
      }
    }

  InputDecoration customDecoration(
      String label) {

    return InputDecoration(

      labelText: label,

      labelStyle: TextStyle(

        color:
            Colors.black54,

        fontSize: 14,
      ),

      filled: true,

      fillColor: Colors.white,

      border:
          OutlineInputBorder(

        borderRadius:
            BorderRadius.circular(
                15),

        borderSide: BorderSide(
          color:
              Colours.primarycolour,
        ),
      ),

      enabledBorder:
          OutlineInputBorder(

        borderRadius:
            BorderRadius.circular(
                15),

        borderSide: BorderSide(
          color: Colors
              .grey
              .withValues(alpha: 0.4),
        ),
      ),

      focusedBorder:
          OutlineInputBorder(

        borderRadius:
            BorderRadius.circular(
                15),

        borderSide: BorderSide(
          color:
              Colours.primarycolour,
          width: 2,
        ),
      ),
    );
  }

  void addMedicine() {

    medicines.add({

      "medicine_name": "",

      "medicine_type": "",

      "quantity": "",

      "dose_pattern": null,

      "duration_days": "",

      "direction_of_use": "",
    });

    setState(() {});
  }

  void removeMedicine(int index) {

    medicines.removeAt(index);

    setState(() {});
  }

  @override
Widget build(BuildContext context) {

  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      toolbarHeight: 60,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,

      flexibleSpace: Stack(
        children: [
          SizedBox(
            height: 100,
            width: 250,
            child: Image.network(
              'https://app.pawdli.com/media/static/topimage.png',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),

      foregroundColor: Colours.brownColour,

      title: Text(
        widget.prescriptionData == null
            ? "Create Prescription"
            : "Update Prescription",
        style: TextStyle(
          color: Colours.brownColour,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    body: SingleChildScrollView(

      padding:
          const EdgeInsets.all(16),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const Text(
            "Doctor Note",
            style: TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          TextFormField(
            controller:
                diagnosisController,
            maxLines: 2,
            decoration:
            customDecoration(
              "Diagnosis",
            ),
          ),

          const SizedBox(height: 15),

          TextFormField(
            controller:
                doctorNotesController,
            maxLines: 2,
            decoration:
                customDecoration(
              "Doctor Notes",
            ),
          ),

          const SizedBox(height: 15),

          TextFormField(
            controller:
                precautionsController,
            maxLines: 2,
            decoration:
                customDecoration(
              "Precautions",
            ),
          ),

          const SizedBox(height: 15),

          TextFormField(
            controller:
                followUpController,
            maxLines: 2,
            decoration:
                customDecoration(
              "Follow Up Advice",
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Next Consultation Date",
            style: TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          InkWell(

            onTap: () async {

              final picked =
                  await showDatePicker(

                context: context,

                initialDate:
                    DateTime.now(),

                firstDate:
                    DateTime.now(),

                lastDate:
                    DateTime(2035),
              );

              if (picked != null) {

                setState(() {

                  nextVisitDate =
                      picked;
                });
              }
            },

            child: Container(

              width: double.infinity,

              padding:
                  const EdgeInsets.all(
                      15),

              decoration:
                  BoxDecoration(

                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.4),
                ),

                borderRadius:
                    BorderRadius.circular(
                        12),
              ),

              child: Text(

                nextVisitDate == null

                    ? "Select Date"

                    : DateFormat(
                        "dd-MM-yyyy",
                      ).format(
                        nextVisitDate!,
                      ),

                style: TextStyle(

                  color: nextVisitDate == null
                      ? Colors.black54
                      : Colors.black,

                  fontSize:
                      getResponsiveFont(
                          context,
                          14),

                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(

            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: [

              const Text(
                "Medicines",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  foregroundColor: Colours.primarycolour,
                  side: BorderSide(
                    color: Colours.primarycolour,
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: addMedicine,
                child: const Text(
                  "+ Add",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),

          ...List.generate(
              medicines.length,
              (index) {

                return Card(
                  elevation: 0,
                  color: Colors.white,
                  margin:const EdgeInsets.only(
                    top: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colours.brownColour,
                      width: 1,
                    ),
                  ),

                  child: Padding(
                    padding:const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue:
                              medicines[index]
                                  ["medicine_name"]
                                  ?.toString() ?? "",

                          decoration:
                              customDecoration(
                            "Medicine Name",
                          ),

                          onChanged: (value) {

                            medicines[index]
                                    ["medicine_name"] =
                                value;
                          },
                        ),

                        const SizedBox(
                            height: 10),

                        DropdownButtonFormField<String>(

                          decoration:
                              customDecoration(
                            "Medicine Type",
                          ),

                          initialValue: medicines[index]["medicine_type"],

                          items: const [


                            DropdownMenuItem(
                              value: "",
                              child: Text("Select Type"),
                            ),

                            DropdownMenuItem(
                              value: "tablet",
                              child: Text("Tablet"),
                            ),

                            DropdownMenuItem(
                              value: "liquid",
                              child: Text("Liquid"),
                            ),

                            DropdownMenuItem(
                              value: "drops",
                              child: Text("Drops"),
                            ),

                            DropdownMenuItem(
                              value: "powder",
                              child: Text("Powder"),
                            ),

                            DropdownMenuItem(
                              value: "capsule",
                              child: Text("Capsule"),
                            ),

                            DropdownMenuItem(
                              value: "ointment",
                              child: Text("Ointment"),
                            ),

                            DropdownMenuItem(
                              value: "injection",
                              child: Text("Injection"),
                            ),
                          ],

                          onChanged: (value) {

                            medicines[index]
                                    ["medicine_type"] =
                                value;
                          },
                        ),

                        const SizedBox(height: 10),

                        DropdownButtonFormField<String>(

                          decoration:
                              customDecoration(
                            "Dose Pattern",
                          ),

                          initialValue: medicines[index]
                              ["dose_pattern"],
                              

                          items: const [

                            DropdownMenuItem(
                              value: "I-I-I",
                              child: Text(
                                "I - I - I",
                              ),
                            ),

                            DropdownMenuItem(
                              value: "I-0-I",
                              child: Text(
                                "I - 0 - I",
                              ),
                            ),

                            DropdownMenuItem(
                              value: "0-I-I",
                              child: Text(
                                "0 - I - I",
                              ),
                            ),

                            DropdownMenuItem(
                              value: "I-I-0",
                              child: Text(
                                "I - I - 0",
                              ),
                            ),

                            DropdownMenuItem(
                              value: "I-0-0",
                              child: Text(
                                "I - 0 - 0",
                              ),
                            ),

                            DropdownMenuItem(
                              value: "0-I-0",
                              child: Text(
                                "0 - I - 0",
                              ),
                            ),

                            DropdownMenuItem(
                              value: "0-0-I",
                              child: Text(
                                "0 - 0 - I",
                              ),
                            ),
                          ],

                          onChanged: (value) {

                            medicines[index]
                                ["dose_pattern"] = value;

                            setState(() {});
                          },
                        ),

                        const SizedBox(height: 10),

                        TextFormField(

                          initialValue:
                              medicines[index]
                                  ["quantity"]
                                  ?.toString() ?? "",

                          decoration:
                              customDecoration(
                            "Quantity",
                          ),

                          onChanged: (value) {

                            medicines[index]["quantity"] =
                                value;
                          },
                        ),

                        const SizedBox(height: 10),

                        TextFormField(

                          initialValue:
                              medicines[index]
                                  ["duration_days"]
                                  ?.toString() ?? "",

                          keyboardType:
                              TextInputType.number,

                              decoration:
                              customDecoration(
                                "Duration Days",
                          ),

                          onChanged: (value) {

                            medicines[index]
                                ["duration_days"] = value;
                          },
                        ),

                        const SizedBox(height: 10),

                        DropdownButtonFormField<String>(

                          decoration:
                              customDecoration(
                            "Direction Of Use",
                          ),

                          initialValue: medicines[index]
                              ["direction_of_use"],

                          items: const [

                            DropdownMenuItem(
                              value: "",
                              child: Text("Choose Direction"),
                            ),

                            DropdownMenuItem(
                              value: "Before food",
                              child:
                                  Text("Before Food"),
                            ),

                            DropdownMenuItem(
                              value: "After food",
                              child:
                                  Text("After Food"),
                            ),

                            DropdownMenuItem(
                              value: "Mix With food",
                              child:
                                  Text("Mix With Food"),
                            ),

                            DropdownMenuItem(
                              value: "Mix with water",
                              child:
                                  Text("Mix with Water"),
                            ),
                          ],

                          onChanged: (value) {

                            medicines[index]
                                ["direction_of_use"] =
                                value;
                          },
                        ),

                        const SizedBox(height: 10),

                        Align(

                          alignment:
                              Alignment.centerRight,

                          child: TextButton(

                            onPressed: () {

                              removeMedicine(index);
                            },

                            child: const Text(
                              "Remove Medicine",
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,

            child: ElevatedButton(

              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colours.primarycolour,
                foregroundColor:
                    Colors.white,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 16,
                ),
              ),

              onPressed: () async {

                // if (nextVisitDate == null) {

                //   Get.snackbar(
                //     "Error",
                //     "Select Next Consultation Date",
                //   );

                //   return;
                // }

                List<MedicineModel>
                    medicineList = [];

                for (var medicine
                    in medicines) {

                  bool morning = false;
                  bool afternoon = false;
                  bool night = false;

                  switch (
                      medicine["dose_pattern"]) {

                    case "I-I-I":

                      morning = true;
                      afternoon = true;
                      night = true;
                      break;

                    case "I-0-I":

                      morning = true;
                      afternoon = false;
                      night = true;
                      break;

                    case "0-I-I":

                      morning = false;
                      afternoon = true;
                      night = true;
                      break;

                    case "I-I-0":

                      morning = true;
                      afternoon = true;
                      night = false;
                      break;

                    case "I-0-0":

                      morning = true;
                      afternoon = false;
                      night = false;
                      break;

                    case "0-I-0":

                      morning = false;
                      afternoon = true;
                      night = false;
                      break;

                    case "0-0-I":

                      morning = false;
                      afternoon = false;
                      night = true;
                      break;
                  }

                  print(
                    "CURRENT MEDICINE => $medicine",
                  );

                  medicineList.add(

                    MedicineModel(

                      medicineName:
                          medicine["medicine_name"],

                      medicineType:
                        medicine["medicine_type"]
                            ?.toString() ?? "",

                      quantity:
                          medicine["quantity"],

                      morning: morning,

                      afternoon: afternoon,

                      night: night,

                      durationDays:
                          int.tryParse(
                                medicine[
                                    "duration_days"],
                              ) ??
                              0,

                      directionOfUse:
                        medicine["direction_of_use"]
                            ?.toString() ?? "",
                    ),
                  );
                }

                final prescription =
                    PrescriptionModel(

                  consultationRequestId:
                      widget
                          .consultationRequestId,

                  diagnosis:
                      diagnosisController.text,

                  doctorNotes:
                      doctorNotesController.text,

                  precautions:
                      precautionsController.text,

                  followUpAdvice:
                      followUpController.text,

                  nextVisitDate: nextVisitDate != null
                    ? DateFormat("yyyy-MM-dd").format(nextVisitDate!)
                    : null,

                  medicines:
                      medicineList,
                );

                print(
                  "CONSULTATION ID : ${widget.consultationRequestId}",
                );

                print(
                  "DIAGNOSIS : ${diagnosisController.text}",
                );

                print(
                  "NEXT DATE : $nextVisitDate",
                );

                print(
                  "MEDICINES : $medicines",
                );

                bool success = false;

                print(
                "MEDICINES DATA : $medicines"
                );

                  if (widget.prescriptionData == null) {

                    success =
                        await ApiService()
                            .createPrescription(
                      prescription,
                    );

                  } else {

                    final updateController =
                        Get.put(
                      UpdatePrescriptionController(),
                    );

                    print(
                      "UPDATE REQUEST => ${prescription.toJson()}",
                    );

                    Map<String, dynamic> updateBody =
                      prescription.toJson();

                        updateBody.remove(
                          "consultation_request_id",
                        );

                        print(
                          "UPDATE REQUEST => $updateBody",
                        );

                        success =
                            await updateController
                                .updatePrescription(

                          prescriptionId:

                              widget.prescriptionData![
                                  "prescription_id"],

                          requestBody:
                              updateBody,
                        );
                  }

                if (success) {

                  Get.snackbar(
                    "Success",

                    widget.prescriptionData == null

                    ? "Prescription Send Successfully"

                    : "Prescription Updated Successfully"
                  );

                  Future.delayed(
                    const Duration(seconds: 1),
                    () {

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentPage(),
                        ),
                      );
                    },
                  );
                } else {

                  Get.snackbar(
                    "Error",
                    "Failed to Send Prescription",
                  );
                }
              },

                child: Text(

                  widget.prescriptionData == null

                      ? "Send Prescription"

                      : "Update Prescription",

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
            ),
          ),
        ],
      ),
    ),
  );
}

@override
  void dispose() {

    diagnosisController.dispose();

    doctorNotesController.dispose();

    precautionsController.dispose();

    followUpController.dispose();

    super.dispose();
  }
}
    