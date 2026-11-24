import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:pawlli/data/controller/QuickConsultationController.dart';
import 'package:pawlli/presentation/widgets/bottom%20bar/bottombar.dart';
class DoctorConnectingPage extends StatefulWidget {

  final int consultationId;

  const DoctorConnectingPage({
    super.key,
    required this.consultationId,
  });

  @override
  State<DoctorConnectingPage>
  createState() =>
      _DoctorConnectingPageState();
}

class _DoctorConnectingPageState
    extends State<DoctorConnectingPage> {

  // final QuickConsultationController controller =
  //   Get.find<QuickConsultationController>();

  late final QuickConsultationController controller;

    String _selectedReason = "Booked by mistake";
    bool _dialogShown = false;


  @override
    void initState() {
      super.initState();

      print("DOCTOR CONNECT PAGE OPENED");


      controller =
          Get.isRegistered<QuickConsultationController>()
              ? Get.find<QuickConsultationController>()
              : Get.put(
                  QuickConsultationController(),
                  permanent: true,
                );

      print("================================");
      print("DOCTOR CONNECT PAGE OPENED");
      print("CONSULTATION ID => ${widget.consultationId}");
      print("CONTROLLER HASH => ${controller.hashCode}");
      print("================================");

      controller.consultationId.value =
          widget.consultationId;

      print(
        "CONTROLLER CONSULTATION ID => ${controller.consultationId.value}",
      );

      controller.startCheckingDoctor();
    }

  @override
    void dispose() {
      controller.stopCheckingDoctor();
      super.dispose();
    }

    Future<void> _showCancelDialog() async {
      final reasons = [
        "Booked by mistake",
        "Doctor taking too long",
        "No longer needed",
        "Found another doctor",
        "Other",
      ];

      _selectedReason = reasons.first;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(
                    color: Colors.brown,
                    width: 2,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        /// IMAGE
                        Image.asset(
                          "assets/images/CancelRequest.png",
                          height: 100,
                        ),

                        const SizedBox(height: 15),

                        // const Text(
                        //   "Cancel Request?",
                        //   style: TextStyle(
                        //     fontSize: 20,
                        //     fontWeight: FontWeight.bold,
                        //     color: Colors.brown,
                        //   ),
                        // ),

                        const SizedBox(height: 10),

                        const Text(
                          "Are you sure you want to cancel this consultation request?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Cancellation Reason",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.brown.shade700,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.brown.shade200,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: reasons.map((reason) {
                              return RadioListTile<String>(
                                dense: true,
                                title: Text(
                                  reason,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                value: reason,
                                groupValue: _selectedReason,
                                activeColor: Colors.brown,
                                onChanged: (value) {
                                  setDialogState(() {
                                    _selectedReason = value!;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [

                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Colors.brown,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  Get.back();
                                },
                                child: const Text(
                                  "No",
                                  style: TextStyle(
                                    color: Colors.brown,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  Get.back();

                                  bool success =
                                      await controller
                                          .cancelConsultationRequest(
                                    consultationId:
                                        widget.consultationId,
                                    cancellationReason:
                                        _selectedReason,
                                  );

                                  if (success) {

                                    controller.stopCheckingDoctor();

                                    Get.snackbar(
                                      "Cancelled",
                                      "Consultation cancelled successfully",
                                    );

                                    Get.offAll(() => MainLayout());
                                  } else {
                                    Get.snackbar(
                                      "Error",
                                      "Unable to cancel consultation",
                                    );
                                  }
                                },
                                child: const Text("Yes"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }

    // Future<void> _showReasonDialog() async {

    //   final reasons = [

    //     "Booked by mistake",

    //     "Doctor taking too long",

    //     "No longer needed",

    //     "Found another doctor",

    //     "Other",
    //   ];

    //   _selectedReason = reasons.first;

    //   showDialog(

    //     context: context,

    //     barrierDismissible: false,

    //     builder: (dialogContext) {

    //       return StatefulBuilder(

    //         builder: (dialogStateContext, setStateDialog) {

    //           return AlertDialog(

    //             shape: RoundedRectangleBorder(
    //               borderRadius: BorderRadius.circular(15),
    //             ),

    //             title: const Text(
    //               "Cancellation Reason",
    //             ),

    //             content: Column(

    //               mainAxisSize: MainAxisSize.min,

    //               children: reasons.map((reason) {

    //                 return RadioListTile<String>(

    //                   title: Text(reason),

    //                   value: reason,

    //                   groupValue: _selectedReason,

    //                   onChanged: (value) {

    //                     setStateDialog(() {

    //                       _selectedReason = value!;
    //                     });
    //                   },
    //                 );

    //               }).toList(),
    //             ),

    //             actions: [

    //               TextButton(

    //                 onPressed: () {

    //                   Get.back();

    //                 },

    //                 child: const Text("Close"),
    //               ),

    //               ElevatedButton(

    //                 onPressed: () async {

    //                   Get.back();

    //                   // controller.stopCheckingDoctor();

    //                   bool success = await controller.cancelConsultationRequest(
    //                     consultationId: widget.consultationId,
    //                     cancellationReason: _selectedReason,
    //                   );

    //                   if (success) {

    //                     if (!mounted) return;

    //                     Get.snackbar(
    //                       "Cancelled",
    //                       "Consultation cancelled successfully",
    //                     );

    //                     Navigator.of(context).popUntil(
    //                       (route) => route.isFirst,
    //                     );

    //                     Navigator.push(
    //                       context,
    //                       MaterialPageRoute(
    //                         builder: (_) => const AppointmentPage(),
    //                       ),
    //                     );
    //                   } else {

    //                     Get.snackbar(

    //                       "Error",

    //                       "Unable to cancel consultation",
    //                     );
    //                   }
    //                 },

    //                 child: const Text("OK"),
    //               ),
    //             ],
    //           );
    //         },
    //       );
    //     },
    //   );
    // }

    void _showNoDoctorDialog() {

      if (_dialogShown) return;

      _dialogShown = true;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {

          return AlertDialog(

            title: const Text(
              "No Doctors Available",
            ),

            content: const Text(
              "Sorry, no doctors are available right now.",
            ),

            actions: [

              /// CLOSE
              TextButton(
                onPressed: () {

                  Get.back();

                  Get.offAll(() => MainLayout());

                },
                child: const Text("Close"),
              ),

              /// RETRY
              ElevatedButton(
                onPressed: () {

                  Get.back();

                  _dialogShown = false;

                  controller.consultationStatus.value =
                      "searching";

                  controller.startCheckingDoctor();
                },
                child: const Text("Retry"),
              ),
            ],
          );
        },
      );
    }
  @override
  Widget build(BuildContext context) {

    print("DOCTOR CONNECT PAGE BUILD");

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        _showCancelDialog();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.brown,
          ),
          onPressed: () {
            _showCancelDialog();
          },
        ),

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

        foregroundColor: Colors.brown,

        title: const Text(
          "Connecting to Doctor",
          style: TextStyle(
            color: Colors.brown,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Obx(() {

        if (controller.consultationStatus.value == "no_doctor_found" ||
            controller.consultationStatus.value == "failed") {

          WidgetsBinding.instance.addPostFrameCallback((_) {

            _showNoDoctorDialog();

          });
        }

        return Center(

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            Image.asset(
              "assets/images/DoctorSearch.gif",
              height: 300,
              width: 300,
            ),

            const SizedBox(height: 20),

            const Text(
              "Searching...",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.brown,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Please wait while we find an available doctor for your consultation.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),

            // const SizedBox(height: 10),

            // const Text(
            //   "Please wait while nearby doctors accept your request",
            //   textAlign: TextAlign.center,
            // ),

            const SizedBox(height: 40),

            SizedBox(

              width: 180,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(

                  backgroundColor: Colors.red,

                  foregroundColor: Colors.white,
                ),

                onPressed: () {

                  _showCancelDialog();

                },

                child: const Text(
                  "Cancel Request",
                ),
              ),
            ),
          ],
        ),
      );
      }),
      ),
    );
  }
}