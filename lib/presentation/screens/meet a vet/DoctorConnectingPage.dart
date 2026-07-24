import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:pawlli/data/controller/QuickConsultationController.dart';
import 'package:pawlli/presentation/screens/meet a vet/appointment.dart';
class DoctorConnectingPage
    extends StatefulWidget {

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

  final QuickConsultationController controller =
    Get.find<QuickConsultationController>();

    String _selectedReason = "Booked by mistake";
    bool _dialogShown = false;


  @override
    void initState() {

      super.initState();

      print("DOCTOR CONNECT PAGE OPENED");


      // controller = Get.put(
      //   QuickConsultationController(),
      //   permanent: true,
      // );

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

      // controller.pollingTimer?.cancel();

      super.dispose();
    }

    Future<void> _showCancelDialog() async {

      showDialog(

        context: context,

        barrierDismissible: false,

        builder: (context) {

          return AlertDialog(

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),

            title: const Text(
              "Cancel Request?",
            ),

            content: const Text(
              "Are you sure you want to cancel this consultation request?",
            ),

            actions: [

              TextButton(

                onPressed: () {

                  Get.back();

                },

                child: const Text("No"),
              ),

              ElevatedButton(

                onPressed: () {

                  Get.back();

                  _showReasonDialog();

                },

                child: const Text("Yes"),
              ),
            ],
          );
        },
      );
    }

    Future<void> _showReasonDialog() async {

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

            builder: (dialogStateContext, setStateDialog) {

              return AlertDialog(

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),

                title: const Text(
                  "Cancellation Reason",
                ),

                content: Column(

                  mainAxisSize: MainAxisSize.min,

                  children: reasons.map((reason) {

                    return RadioListTile<String>(

                      title: Text(reason),

                      value: reason,

                      groupValue: _selectedReason,

                      onChanged: (value) {

                        setStateDialog(() {

                          _selectedReason = value!;
                        });
                      },
                    );

                  }).toList(),
                ),

                actions: [

                  TextButton(

                    onPressed: () {

                      Get.back();

                    },

                    child: const Text("Close"),
                  ),

                  ElevatedButton(

                    onPressed: () async {

                      Get.back();

                      // controller.stopCheckingDoctor();

                      bool success = await controller.cancelConsultationRequest(
                        consultationId: widget.consultationId,
                        cancellationReason: _selectedReason,
                      );

                      if (success) {

                        if (!mounted) return;

                        Get.snackbar(
                          "Cancelled",
                          "Consultation cancelled successfully",
                        );

                        Navigator.of(context).popUntil(
                          (route) => route.isFirst,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AppointmentPage(),
                          ),
                        );
                      } else {

                        Get.snackbar(

                          "Error",

                          "Unable to cancel consultation",
                        );
                      }
                    },

                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    void _showNoDoctorDialog() {

      if (_dialogShown) return;

      _dialogShown = true;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {

          return AlertDialog(

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),

            title: const Text(
              "No Doctors Available",
            ),

            content: const Text(
              "Sorry, no doctors are available at the moment. Please try again later.",
            ),

            actions: [

              ElevatedButton(

                onPressed: () {

                  Get.back();

                  Navigator.of(context).popUntil(
                    (route) => route.isFirst,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AppointmentPage(),
                    ),
                  );
                },

                child: const Text("OK"),
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

            const CircularProgressIndicator(),

            const SizedBox(height: 30),

            const Text(
              "Connecting to doctor...",
            ),

            const SizedBox(height: 10),

            const Text(
              "Please wait while nearby doctors accept your request",
              textAlign: TextAlign.center,
            ),

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