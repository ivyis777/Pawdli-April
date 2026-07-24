import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/DoctorconsultationController.dart';

class DoctorLiveConsultationPage
    extends StatelessWidget {

  DoctorLiveConsultationPage({super.key});

  final controller =
    Get.find<DoctorConsultationController>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

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
          "Live Consultation Requests",
          style: TextStyle(
            color: Colours.brownColour,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Obx(() {

        if (controller
            .liveConsultations
            .isEmpty) {

          return const Center(

            child: Text(
              "No Live Requests",
            ),
          );
        }

        return ListView.builder(

          itemCount:
          controller
              .liveConsultations
              .length,

          itemBuilder:
              (context, index) {

            final consultation =
            controller
                .liveConsultations[index];

            return Card(

              margin:
              const EdgeInsets.all(10),

              child: Padding(

                padding:
                const EdgeInsets.all(15),

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(
                      consultation.petName ?? "",
                    ),

                    const SizedBox(height: 5),

                    Text(
                      consultation.petBreed ?? "",
                    ),

                    const SizedBox(height: 5),

                    Text(
                      consultation.problemDescription ?? "",
                    ),

                    const SizedBox(height: 5),

                    Text(
                      consultation.symptoms
                          ?.join(", ") ?? "",
                    ),

                    const SizedBox(height: 15),

                    SizedBox(

                      width: double.infinity,

                      child: ElevatedButton(

                        onPressed: () {

                          controller
                              .acceptConsultation(

                            consultation
                                .consultationRequestId!,
                          );
                        },

                        child: const Text(
                          "Accept Consultation",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}