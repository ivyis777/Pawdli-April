import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/ConsultationDetailsModel.dart';
import 'package:pawlli/data/model/ConsultationRequestModel.dart';
import 'package:pawlli/presentation/screens/meet%20a%20vet/ConsultationCallPage.dart';


class QuickConsultationController
    extends GetxController {

  /// LOADING
  RxBool isLoading = false.obs;

  /// CREATE CONSULTATION LOADING
  RxBool isCreatingConsultation =
      false.obs;

  /// CHECKING DOCTOR LOADING
  RxBool isCheckingDoctor =
      false.obs;

  /// CONSULTATION ID
  RxInt consultationId = 0.obs;

  /// ROOM ID
  RxString roomId = "".obs;

  /// STATUS
  RxString consultationStatus =
      "".obs;

  /// PAYMENT STATUS
  RxString paymentStatus =
      "".obs;

  /// ASSIGNED DOCTOR
  RxString assignedDoctorId = "".obs;

  /// TIMER
  Timer? pollingTimer;

  /// CREATE CONSULTATION
  Future<bool> createConsultation({

    required String petId,

    required String problemDescription,

    required List<String> symptomIds,

    required String otherSymptom,

    required List<File> issueImages,

  }) async {

    try {

      isLoading.value = true;

      isCreatingConsultation.value =
      true;

      final ConsultationRequestModel?
      response = await ApiService
          .createConsultationRequest(

        petId: petId,

        problemDescription:
        problemDescription,

        symptomIds:
        symptomIds,

        otherSymptom:
        otherSymptom,

        issueImages:
        issueImages,
      );

      print(
          "CREATE CONSULTATION RESPONSE : $response");

      /// SUCCESS
      if (response != null &&
          response.status == true) {

        consultationId.value =
            response.data
                ?.consultationRequestId ?? 0;

        consultationStatus.value =
            response.data
                ?.consultationStatus ?? "";

        paymentStatus.value =
            response.data
                ?.paymentStatus ?? "";

        assignedDoctorId.value =
         response.data?.assignedDoctor ?? "";

        print(
            "CONSULTATION ID : ${consultationId.value}");

        print(
            "CONSULTATION STATUS : ${consultationStatus.value}");

        print(
            "PAYMENT STATUS : ${paymentStatus.value}");

        return true;
      }

      return false;

    } catch (e) {

      print(
          "CREATE CONSULTATION CONTROLLER ERROR : $e");

      return false;

    } finally {

      isLoading.value = false;

      isCreatingConsultation.value =
      false;
    }
  }
  

  /// START CHECKING DOCTOR
  void startCheckingDoctor() {

    print(
        "START CHECKING DOCTOR");

    print(
      "START CHECKING DOCTOR FOR => ${consultationId.value}");

    isCheckingDoctor.value = true;

    pollingTimer = Timer.periodic(

      const Duration(seconds: 3),

          (timer) async {

        try {
          

          print("================================");
          print("POLLING RUNNING");
          print("CONSULTATION ID => ${consultationId.value}");
          print("================================");

          final ConsultationDetailsModel?
          response = await ApiService
              .getConsultationDetails(
            consultationId.value,
          );

          print("================================");
          print("API RETURNED");
          print("STATUS => ${response?.data?.consultationStatus}");
          print("ROOM => ${response?.data?.consultationRoomId}");
          print("WS => ${response?.data?.websocketUrl}");
          print("DOCTOR => ${response?.data?.assignedDoctor}");
          print("================================");

          print("FULL RESPONSE : ${response?.data}");
          print("ROOM ID API : ${response?.data?.consultationRoomId}");
          print("WEBSOCKET API : ${response?.data?.websocketUrl}");
          print("DOCTOR API : ${response?.data?.assignedDoctor}");
          print("STATUS API : ${response?.data?.consultationStatus}");

          if (response != null &&
              response.status == true) {

            consultationStatus.value =
                response.data
                    ?.consultationStatus ?? "";

            paymentStatus.value =
                response.data
                    ?.paymentStatus ?? "";

            roomId.value =
              response.data?.consultationRoomId ?? "";

            assignedDoctorId.value =
                response.data?.assignedDoctor?.doctorId
                    ?.toString() ??
                "";

            print(
                "LIVE CONSULTATION STATUS : ${consultationStatus.value}");
            print(
              "LIVE STATUS FROM API => ${response.data?.consultationStatus}",
            );

            print(
                "LIVE PAYMENT STATUS : ${paymentStatus.value}");

            print(
                "LIVE ROOM ID : ${roomId.value}");

            print(
                "LIVE ASSIGNED DOCTOR : ${assignedDoctorId.value}");

            /// DOCTOR ACCEPTED
            if (consultationStatus.value
                  == "ongoing") {

              print(
                  "DOCTOR ACCEPTED");

              stopCheckingDoctor();

              print(
                  "ROOM ID => ${response.data?.consultationRoomId}");

              print(
                "WEBSOCKET URL => ${response.data?.websocketUrl}");

              print(
                "STATUS : ${response.data?.consultationStatus}");

              print("OPENING USER CALL PAGE");

              /// OPEN CALL PAGE
              Get.offAll(

                () => ConsultationCallPage(
                  roomId:response.data?.consultationRoomId ?? "",
                  websocketUrl:response.data?.websocketUrl ?? "",
                  consultationRequestId:consultationId.value,
                  isDoctor: false,
                  receiverId:response.data?.assignedDoctor?.doctorId ?.toString() ?? "",
                ),
              );
            }

            /// CONSULTATION CANCELLED
            else if (consultationStatus.value
                == "cancelled") {

              print(
                  "CONSULTATION CANCELLED");

              stopCheckingDoctor();

              Get.snackbar(
                "Cancelled",
                "Consultation cancelled",
              );
            }

            /// NO DOCTOR FOUND
            else if (consultationStatus.value == "no_doctor_found" ||
                     consultationStatus.value == "failed") {

              print(
                  "NO DOCTOR FOUND");

              stopCheckingDoctor();
              consultationStatus.value = "no_doctor_found";
              print("CURRENT STATUS => ${consultationStatus.value}");

              // Get.snackbar(
              //   "Doctor Unavailable",
              //   "No doctors available now",
              // );
            }
          }

        } catch (e) {

          print(
              "CHECK DOCTOR ERROR : $e");
        }
      },
    );
  }

  /// STOP CHECKING
  void stopCheckingDoctor() {

    print("STOP CHECKING DOCTOR");

    pollingTimer?.cancel();

    pollingTimer = null;

    isCheckingDoctor.value = false;
  }

    Future<bool> cancelConsultationRequest({

      required int consultationId,

      required String cancellationReason,

    }) async {

      try {

        isLoading.value = true;

        final success =
            await ApiService.cancelConsultationRequest(

          consultationRequestId:
              consultationId,

          cancellationReason:
              cancellationReason,
        );

        if (success) {

          print("CONSULTATION CANCELLED");

          stopCheckingDoctor();

          resetConsultation();

          return true;
        }

        return false;

      } catch (e) {

        print("CANCEL ERROR : $e");

        return false;

      } finally {

        isLoading.value = false;
      }
    }

  /// RESET DATA
  void resetConsultation() {

    pollingTimer?.cancel();

    pollingTimer = null;

    consultationId.value = 0;

    roomId.value = "";

    consultationStatus.value = "";

    paymentStatus.value = "";

    assignedDoctorId.value = "";

    isCheckingDoctor.value = false;
  }

  /// CLOSE
  @override
    void onInit() {
      super.onInit();

      print(
        "QUICK CONTROLLER CREATED => ${hashCode}",
      );
    }

    @override
    void onClose() {
      print(
        "QUICK CONTROLLER CLOSED => ${hashCode}",
      );

      pollingTimer?.cancel();

      super.onClose();
    }
}