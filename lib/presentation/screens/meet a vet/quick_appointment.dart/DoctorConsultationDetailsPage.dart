import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/presentation/screens/meet%20a%20vet/quick_appointment.dart/PrescriptionPage.dart';

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

class ConsultationDetailsPage
    extends StatelessWidget {

  final Map<String, dynamic>
      consultationData;

  const ConsultationDetailsPage({

    super.key,

    required this.consultationData,
  });

  @override
  Widget build(BuildContext context) {


    final prescription =
    consultationData["prescription"];

final medicines =
    prescription?["medicines"] ?? [];

final symptoms =
    consultationData["symptoms"] ?? [];

final issueImages =
    consultationData["issue_images"] ?? [];


    return Scaffold(

  backgroundColor:
      Colours.secondarycolour,

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

      title: Text(
        "Consultation Details",
        style: TextStyle(
          color: Colours.brownColour,
          fontSize: getResponsiveFont(context, 18),
          fontWeight: FontWeight.bold,
        ),
      ),
      foregroundColor: Colours.brownColour,
    ),

  body: SingleChildScrollView(


    child: Padding(

  padding:
      const EdgeInsets.all(16),

  child: Column(

    crossAxisAlignment:
        CrossAxisAlignment.start,

    children: [

      Text(

  "Pet Information",

  style: TextStyle(

    color:
        Colours.brownColour,

    fontSize:
        getResponsiveFont(
            context,
            16),

    fontWeight:
        FontWeight.bold,
  ),
),

const SizedBox(height: 12),

_buildInfoCard(
  "Pet Name",
  consultationData["pet_name"] ?? "",
),

_buildInfoCard(
  "Pet Age",
  consultationData["pet_age"] ?? "",
),

_buildInfoCard(
  "Pet Gender",
  consultationData["pet_gender"] ?? "",
),

_buildInfoCard(
  "Pet Breed",
  consultationData["pet_breed"] ?? "",
),

const SizedBox(height: 20),



Text(

  "Consultation Information",

  style: TextStyle(

    color:
        Colours.brownColour,

    fontSize:
        getResponsiveFont(
            context,
            16),

    fontWeight:
        FontWeight.bold,
  ),
),

const SizedBox(height: 12),

_buildInfoCard(

  "Status",

  consultationData[
      "consultation_status"] ??
      "",
),

_buildInfoCard(

  "Type",

  consultationData[
      "consultation_type"] == 1

      ? "Quick Consultation"

      : "Scheduled Consultation",
),

_buildInfoCard(

  "Created Date",

  DateFormat(
    "dd-MM-yyyy",
  ).format(

    DateTime.parse(
      consultationData[
          "created_at"],
    ),
  ),
),

const SizedBox(height: 20),

Text(

  "Symptoms",

  style: TextStyle(

    color:
        Colours.brownColour,

    fontSize:
        getResponsiveFont(
            context,
            16),

    fontWeight:
        FontWeight.bold,
  ),
),

const SizedBox(height: 12),

symptoms.isEmpty

    ? const Text(
        "No Symptoms",
      )

    : Wrap(

        spacing: 10,

        runSpacing: 10,

        children:

            symptoms.map<Widget>(
          (symptom) {

            return Container(

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),

              decoration:
                  BoxDecoration(

                color:
                    Colors.white,

                borderRadius:
                    BorderRadius.circular(
                        30),

                border: Border.all(
                  color: Colours
                      .primarycolour,
                ),
              ),

              child: Text(

                symptom,

                style: TextStyle(
                  color: Colours
                      .primarycolour,
                ),
              ),
            );
          },
        ).toList(),
      ),

const SizedBox(height: 20),

Text(

  "Problem Description",

  style: TextStyle(

    color:
        Colours.brownColour,

    fontSize:
        getResponsiveFont(
            context,
            16),

    fontWeight:
        FontWeight.bold,
  ),
),

const SizedBox(height: 12),

Container(

  width:
      double.infinity,

  padding:
      const EdgeInsets.all(
          16),

  decoration:
      BoxDecoration(

    color: Colors.white,

    borderRadius:
        BorderRadius.circular(
            15),

    border: Border.all(
      color: Colours
          .primarycolour
          .withOpacity(0.4),
    ),
  ),

  child: Text(

    consultationData[
            "problem_description"] ??
        "-",

    style: TextStyle(

      fontSize:
          getResponsiveFont(
              context,
              14),
    ),
  ),
),

const SizedBox(height: 20),

Text(

  "Issue Images",

  style: TextStyle(

    color:
        Colours.brownColour,

    fontSize:
        getResponsiveFont(
            context,
            16),

    fontWeight:
        FontWeight.bold,
  ),
),

const SizedBox(height: 12),

issueImages.isEmpty

? Container(

    height: 120,

    width:
        double.infinity,

    alignment:
        Alignment.center,

    decoration:
        BoxDecoration(

      color: Colors.white,

      borderRadius:
          BorderRadius.circular(
              15),

      border: Border.all(
        color: Colours
            .primarycolour
            .withOpacity(0.4),
      ),
    ),

    child: const Text(
      "No Images Available",
    ),
)

:

SizedBox(

  height: 140,

  child:
      ListView.builder(

    scrollDirection:
        Axis.horizontal,

    itemCount:
        issueImages.length,

    itemBuilder:
        (context, index) {

      return Padding(

        padding:
            const EdgeInsets.only(
          right: 12,
        ),

        child:
            ClipRRect(

          borderRadius:
              BorderRadius.circular(
                  15),

          child:
              Image.network(

            issueImages[index]
                ["image"],

            width: 140,

            fit:
                BoxFit.cover,

            errorBuilder:
                (
              context,
              error,
              stackTrace,
            ) {

              return Container(

                width: 140,

                color:
                    Colors.grey[300],

                child:
                    const Icon(
                  Icons.image,
                ),
              );
            },
          ),
        ),
      );
    },
  ),
),

const SizedBox(height: 24),

Text(

  "Prescription Details",

  style: TextStyle(

    color:
        Colours.brownColour,

    fontSize:
        getResponsiveFont(
            context,
            16),

    fontWeight:
        FontWeight.bold,
  ),
),

const SizedBox(height: 12),

if (prescription == null)

  Container(

    width:
        double.infinity,

    padding:
        const EdgeInsets.all(
            16),

    decoration:
        BoxDecoration(

      color: Colors.white,

      borderRadius:
          BorderRadius.circular(
              15),

      border: Border.all(
        color: Colours
            .primarycolour
            .withOpacity(0.4),
      ),
    ),

    child: const Text(
      "Prescription Not Available",
    ),
  ),

  if (prescription != null) ...[

  _buildInfoCard(

    "Diagnosis",

    prescription[
        "diagnosis"] ??
        "",
  ),

  _buildInfoCard(

    "Doctor Notes",

    prescription[
        "doctor_notes"] ??
        "",
  ),

  _buildInfoCard(

    "Precautions",

    prescription[
        "precautions"] ??
        "",
  ),

  _buildInfoCard(

    "Follow Up",

    prescription[
        "follow_up_advice"] ??
        "",
  ),

  _buildInfoCard(

    "Next Visit",

    prescription[
        "next_visit_date"] ??
        "",
  ),

  const SizedBox(height: 20),
],

if (prescription != null) ...[

  Text(

    "Medicines",

    style: TextStyle(

      color:
          Colours.brownColour,

      fontSize:
          getResponsiveFont(
              context,
              16),

      fontWeight:
          FontWeight.bold,
    ),
  ),

  const SizedBox(height: 12),

  ListView.builder(

    shrinkWrap: true,

    physics:
        const NeverScrollableScrollPhysics(),

    itemCount:
        medicines.length,

    itemBuilder:
        (context, index) {

      final medicine =
          medicines[index];

      String dosePattern =

          "${medicine["morning"] == true ? "I" : "0"} - "
          "${medicine["afternoon"] == true ? "I" : "0"} - "
          "${medicine["night"] == true ? "I" : "0"}";

      return Container(

        margin:
            const EdgeInsets.only(
          bottom: 12,
        ),

        padding:
            const EdgeInsets.all(
                16),

        decoration:
            BoxDecoration(

          color: Colors.white,

          borderRadius:
              BorderRadius.circular(
                  15),

          border: Border.all(
            color: Colours
                .primarycolour
                .withOpacity(0.4),
          ),
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            _medicineRow(
              "Medicine",
              medicine[
                  "medicine_name"],
            ),

            _medicineRow(
              "Quantity",
              medicine[
                  "quantity"],
            ),

            _medicineRow(
              "Pattern",
              dosePattern,
            ),

            _medicineRow(
              "Duration",
              "${medicine["duration_days"]} Days",
            ),

            _medicineRow(
              "Direction",
              medicine[
                  "direction_of_use"],
            ),
          ],
        ),
      );
    },
  ),
],


if (prescription != null)

Column(

  children: [

    const SizedBox(height: 20),

    SizedBox(

      width:
          double.infinity,

      child:
          ElevatedButton(

        style:
            ElevatedButton.styleFrom(

          backgroundColor:
              Colours.primarycolour,

          foregroundColor:
              Colors.white,

          padding:
              const EdgeInsets.symmetric(
            vertical: 16,
          ),

          shape:
              RoundedRectangleBorder(

            borderRadius:
                BorderRadius.circular(
                    15),
          ),
        ),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrescriptionPage(
                consultationRequestId:
                    consultationData["consultation_request_id"],
                prescriptionData: prescription,
              ),
            ),
          );
        },

        child: const Text(
          "Update Prescription",
        ),
      ),
    ),
  ],
),
    ],
  ),),),
);
  }
  

  Widget _buildInfoCard(
  String title,
  String value,
) {

  return Container(

    margin:
        const EdgeInsets.only(
      bottom: 12,
    ),

    padding:
        const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),

    decoration: BoxDecoration(

      color: Colors.white,

      borderRadius:
          BorderRadius.circular(15),

      border: Border.all(
        color: Colours.primarycolour
            .withOpacity(0.4),
      ),
    ),

    child: Row(

      children: [

        SizedBox(

          width: 120,

          child: Text(

            title,

            style: TextStyle(

              color:
                  Colours.brownColour,

              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),

        Expanded(

          child: Text(
            value,
          ),
        ),
      ],
    ),
  );
}

Widget _medicineRow(
  String title,
  String value,
) {

  return Padding(

    padding:
        const EdgeInsets.only(
      bottom: 10,
    ),

    child: Row(

      children: [

        SizedBox(

          width: 100,

          child: Text(

            title,

            style: TextStyle(

              color:
                  Colours.brownColour,

              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),

        Expanded(

          child: Text(
            value,
          ),
        ),
      ],
    ),
  );
}
  
    }