import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
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
      padding:const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colours.brownColour,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      "Pet Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colours.primarycolour,
                      ),
                    ),

                    const Divider(),

                    Text("Pet Name : ${consultationData["pet_name"]}"),

                    const SizedBox(height: 10),

                    Text("Pet Age : ${consultationData["pet_age"]}"),

                    const SizedBox(height: 10),

                    Text("Pet Gender : ${consultationData["pet_gender"]}"),

                    const SizedBox(height: 10),

                    Text("Pet Type : ${consultationData["pet_type"]}"),

                    const SizedBox(height: 10),

                    Text("Breed : ${consultationData["pet_breed"]}"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colours.brownColour,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Consultation Information",
                      style: TextStyle(
                        fontSize: getResponsiveFont(context, 18),
                        fontWeight: FontWeight.bold,
                        color: Colours.primarycolour,
                      ),
                    ),

                    const Divider(),

                    Text(
                      "Status : ${consultationData["consultation_status"] ?? "-"}",
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Consultation Type : ${consultationData["consultation_type"] == 1 ? "Quick Consultation" : "Scheduled Consultation"}",
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Created Date : ${DateFormat("dd MMM yyyy").format(DateTime.parse(consultationData["created_at"]))}",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colours.brownColour,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      "Symptoms",
                      style: TextStyle(
                        fontSize: getResponsiveFont(context, 18),
                        fontWeight: FontWeight.bold,
                        color: Colours.primarycolour,
                      ),
                    ),

                    const Divider(),

                    if (symptoms.isEmpty)
                      const Text(
                        "No Symptoms",
                      )
                    else
                      Text(
                        symptoms.join(", "),
                        style: TextStyle(
                          fontSize: getResponsiveFont(context, 15),
                          color: Colors.black87,
                          // fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colours.brownColour,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      "Problem Description",
                      style: TextStyle(
                        fontSize: getResponsiveFont(context, 18),
                        fontWeight: FontWeight.bold,
                        color: Colours.primarycolour,
                      ),
                    ),

                    const Divider(),

                    Text(
                      consultationData["problem_description"] ?? "-",
                      style: TextStyle(
                        fontSize: getResponsiveFont(context, 14),
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colours.brownColour,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      "Issue Images",
                      style: TextStyle(
                        fontSize: getResponsiveFont(context, 18),
                        fontWeight: FontWeight.bold,
                        color: Colours.primarycolour,
                      ),
                    ),

                    const Divider(),

                    if (issueImages.isEmpty)

                      Container(
                        height: 120,
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colours.primarycolour.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Text(
                          "No Images Available",
                        ),
                      )

                    else

                      SizedBox(
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: issueImages.length,
                          itemBuilder: (context, index) {

                            return Container(
                              width: 110,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colours.primarycolour, width: 0.3
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Get.to(
                                    () => FullScreenImageViewer(
                                      images: issueImages,
                                      initialIndex: index,
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    issueImages[index]["image"],
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(Icons.image_not_supported),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colours.brownColour,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      "Prescription Details",
                      style: TextStyle(
                        fontSize: getResponsiveFont(context, 18),
                        fontWeight: FontWeight.bold,
                        color: Colours.primarycolour,
                      ),
                    ),

                    const Divider(),

                    if (prescription == null)

                      const Text(
                        "Prescription Not Available",
                      )

                    else ...[

                      Text(
                        "Diagnosis : ${prescription["diagnosis"] ?? "-"}",
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Doctor Notes : ${prescription["doctor_notes"] ?? "-"}",
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Precautions : ${prescription["precautions"] ?? "-"}",
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Follow Up : ${prescription["follow_up_advice"] ?? "-"}",
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Next Visit : ${prescription["next_visit_date"] ?? "-"}",
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (prescription != null) ...[

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colours.brownColour,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        "Medicines",
                        style: TextStyle(
                          fontSize: getResponsiveFont(context, 18),
                          fontWeight: FontWeight.bold,
                          color: Colours.primarycolour,
                        ),
                      ),

                      const Divider(),

                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: medicines.length,
                        separatorBuilder: (_, __) => const Divider(height: 30),
                        itemBuilder: (context, index) {

                          final medicine = medicines[index];

                          String dosePattern =
                              "${medicine["morning"] == true ? "I" : "0"} - "
                              "${medicine["afternoon"] == true ? "I" : "0"} - "
                              "${medicine["night"] == true ? "I" : "0"}";

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                "Medicine ${index + 1}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: getResponsiveFont(context, 16),
                                  color: Colours.brownColour,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                "Medicine Name : ${medicine["medicine_name"] ?? "-"}",
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "Quantity : ${medicine["quantity"] ?? "-"}",
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "Dose Pattern : $dosePattern",
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "Duration : ${medicine["duration_days"] ?? "-"} Days",
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "Direction : ${medicine["direction_of_use"] ?? "-"}",
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
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
          ),
        ),
      ),
    );
  }
}

    class FullScreenImageViewer extends StatefulWidget {
      final List images;
      final int initialIndex;

      const FullScreenImageViewer({
        Key? key,
        required this.images,
        required this.initialIndex,
      }) : super(key: key);

      @override
      State<FullScreenImageViewer> createState() =>
          _FullScreenImageViewerState();
    }

    class _FullScreenImageViewerState
        extends State<FullScreenImageViewer> {

      late final PageController _pageController;

      late int currentIndex;

      @override
      void initState() {
        super.initState();

        currentIndex = widget.initialIndex;

        _pageController = PageController(
          initialPage: widget.initialIndex,
        );
      }

      @override
      Widget build(BuildContext context) {

        return Scaffold(

          backgroundColor: Colors.black,

          appBar: AppBar(

            backgroundColor: Colors.black,

            elevation: 0,

            title: Text(
              "${currentIndex + 1} / ${widget.images.length}",
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),

          body: PageView.builder(

            controller: _pageController,

            itemCount: widget.images.length,

            onPageChanged: (index) {

              setState(() {

                currentIndex = index;

              });
            },

            itemBuilder: (context, index) {

              return Center(

                child: InteractiveViewer(

                  minScale: 1,

                  maxScale: 5,

                  child: Image.network(

                    widget.images[index]["image"],

                    fit: BoxFit.contain,

                  ),
                ),
              );
            },
          ),
        );
      }
    }