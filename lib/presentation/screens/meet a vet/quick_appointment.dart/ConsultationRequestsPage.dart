import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/data/controller/DoctorconsultationController.dart';
import 'package:pawlli/data/model/LiveConsultationModel.dart';

class IncomingConsultationRequestsPage extends StatefulWidget {
  const IncomingConsultationRequestsPage({super.key});

  @override
  State<IncomingConsultationRequestsPage> createState() =>
      _IncomingConsultationRequestsPageState();
}

class _IncomingConsultationRequestsPageState
    extends State<IncomingConsultationRequestsPage> {

  final DoctorConsultationController controller =
      Get.find<DoctorConsultationController>();

  @override
    void initState() {
      super.initState();

      controller.fetchLiveConsultations();
    }

  @override
    void dispose() {

      controller.isIncomingRequestPageOpen = false;

      super.dispose();
    }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      appBar: AppBar(

        backgroundColor: Colors.white,

        elevation: 0,

        centerTitle: true,

        automaticallyImplyLeading: false,

        title: const Text(

          "Consultation Requests",

          style: TextStyle(

            color: Colors.black,

            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Obx(() {

        if (controller.liveConsultations.isEmpty) {

          return const Center(

            child: Text(

              "Waiting for consultation requests...",

              style: TextStyle(

                fontSize: 16,
              ),
            ),
          );
        }

        return ListView.builder(

          padding: const EdgeInsets.all(15),

          itemCount: controller.liveConsultations.length,

          itemBuilder: (context, index) {

            final request =
                controller.liveConsultations[index];

            return _consultationCard(request);
          },
        );
      }),
    );
  }

  Widget _consultationCard(
  LiveConsultationData request,
) {

  return Card(

    margin: const EdgeInsets.only(bottom: 18),

    elevation: 5,

    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),

    child: Padding(

      padding: const EdgeInsets.all(18),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Row(

            children: [

              // CircleAvatar(

              //   radius: 28,

              //   backgroundColor:
              //       Colors.blue.shade100,

              //   child: const Icon(
              //     Icons.pets,
              //     size: 32,
              //     color: Colors.blue,
              //   ),
              // ),

              // const SizedBox(width: 15),

              Expanded(

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(

                      request.petName ?? "",

                      style: const TextStyle(

                        fontSize: 20,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(

                      request.petBreed ?? "",

                      style: TextStyle(

                        color: Colors.grey.shade700,

                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              // Container(

              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 12,
              //     vertical: 6,
              //   ),

              //   decoration: BoxDecoration(

              //     color: Colors.green.shade100,

              //     borderRadius:
              //         BorderRadius.circular(25),
              //   ),

              //   child: Text(

              //     request.consultationFee ?? "",

              //     style: const TextStyle(

              //       fontWeight:
              //           FontWeight.bold,

              //       color: Colors.green,
              //     ),
              //   ),
              // ),
            ],
          ),

          const SizedBox(height: 20),

          Row(

            children: [

              Expanded(

                child: _infoTile(

                  "Gender",

                  request.petGender ?? "",
                ),
              ),

              const SizedBox(width: 12),

              Expanded(

                child: _infoTile(

                  "Age",

                  request.petAge ?? "",
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          const Text(

            "Symptoms",

            style: TextStyle(

              fontWeight: FontWeight.bold,

              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          Wrap(

            spacing: 8,

            runSpacing: 8,

            children:
                request.symptoms
                        ?.map(

                          (e) => Chip(

                            label: Text(e),

                            backgroundColor:
                                Colors.orange.shade100,
                          ),
                        )
                        .toList() ??
                    [],
          ),

          const SizedBox(height: 18),

          const Text(

            "Problem",

            style: TextStyle(

              fontWeight: FontWeight.bold,

              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          Container(

            width: double.infinity,

            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(

              color: Colors.grey.shade100,

              borderRadius:
                  BorderRadius.circular(10),
            ),

            child: Text(

              request.problemDescription ?? "",

              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(

            children: [

              const Icon(
                Icons.timer,
                color: Colors.red,
              ),

              const SizedBox(width: 8),

              Text(

                "Remaining : ${request.remainingSearchSeconds ?? 0} sec",

                style: const TextStyle(

                  color: Colors.red,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          Row(

            children: [

              Expanded(

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(

                    backgroundColor:
                        Colors.green,

                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),

                  onPressed: () {

                    controller.acceptConsultation(

                      request
                          .consultationRequestId!,
                    );
                  },

                  child: const Text(

                    "ACCEPT",

                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(

                    backgroundColor:
                        Colors.red,

                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),

                  onPressed: () async {

                    await controller.declineConsultation(

                      request.consultationRequestId!,
                    );
                  },

                  child: const Text(

                    "DECLINE",

                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _infoTile(
  String title,
  String value,
) {
  return Container(

    padding: const EdgeInsets.all(12),

    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(10),
    ),

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          value.isEmpty ? "-" : value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
}