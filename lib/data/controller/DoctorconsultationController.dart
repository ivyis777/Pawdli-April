import 'dart:async';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/LiveConsultationModel.dart';
import 'package:pawlli/data/notification_service.dart';
import 'package:pawlli/presentation/screens/meet%20a%20vet/ConsultationCallPage.dart';
import 'package:pawlli/presentation/screens/meet%20a%20vet/quick_appointment.dart/ConsultationRequestsPage.dart';

class DoctorConsultationController
    extends GetxController {

  RxBool isLoading = false.obs;

  RxList<LiveConsultationData>
  liveConsultations =
      <LiveConsultationData>[].obs;

  final RxList<LiveConsultationData> pendingRequests =
      <LiveConsultationData>[].obs;

  bool _isAccepting = false;
  Timer? pollingTimer;
  Timer? countdownTimer;
  String? currentIncomingRequestId;
  bool isIncomingRequestPageOpen = false;

  @override
  void onInit() {

    super.onInit();

    // startPolling();
      print("DoctorConsultationController Created");
  }

  // / START POLLING


  void startPolling() {

  final isDoctor =
      GetStorage().read(LocalStorageConstants.isDoctor) ?? false;

  if (!isDoctor) {
    print("User is not a doctor. Polling not started.");
    return;
  }

  if (pollingTimer != null) return;

  print("STARTING DOCTOR POLLING");

  fetchLiveConsultations();

  startCountdown();

  pollingTimer = Timer.periodic(
    const Duration(seconds: 3),
    (_) {
      fetchLiveConsultations();
    },
  );
}

  void stopPolling() {
    print("🔴 STOPPING DOCTOR POLLING");

    pollingTimer?.cancel();
    pollingTimer = null;
  }

  void startCountdown() {

    countdownTimer?.cancel();

    countdownTimer = Timer.periodic(

      const Duration(seconds: 1),

      (_) {

        for (int i = pendingRequests.length - 1; i >= 0; i--) {

          final request = pendingRequests[i];

          if (request.remainingSearchSeconds == null) continue;

          request.remainingSearchSeconds =
              request.remainingSearchSeconds! - 1;

          if (request.remainingSearchSeconds! <= 0) {

            pendingRequests.removeAt(i);

          }
        }

        pendingRequests.refresh();
      },
    );
  }

  /// FETCH LIVE CONSULTATIONS
  Future fetchLiveConsultations() async {

    try {

      final response =
          await ApiService.fetchLiveConsultations();

      if (response != null &&
          response.status == true &&
          response.data != null) {

        final latest = response.data!;
        liveConsultations.assignAll(latest);

        latest.sort(
          (a, b) => b.consultationRequestId!
              .compareTo(a.consultationRequestId!),
        );

        final activeIds = response.data!
            .map((e) => e.consultationRequestId)
            .toSet();

        pendingRequests.removeWhere(
          (e) =>
              !activeIds.contains(
                e.consultationRequestId,
              ),
        );

        for (final request in latest) {

          final index =
              pendingRequests.indexWhere(

            (e) =>
                e.consultationRequestId ==
                request.consultationRequestId,
          );

          if (index == -1) {

            pendingRequests.insert(
              0,
              request,
            );

          } else {

            pendingRequests[index] = request;
          }
        }

        print("LIVE REQUEST COUNT : ${liveConsultations.length}");

        if (response.data!.isEmpty) {

          pendingRequests.clear();

          await NotificationService.stopDoctorRingtone();

          return;
        }

        final request = latest.first;

        // Prevent showing the same call repeatedly
        if (currentIncomingRequestId ==
            request.consultationRequestId.toString()) {
          return;
        }

        currentIncomingRequestId =
            request.consultationRequestId.toString();

        if (!Get.isRegistered<IncomingConsultationRequestsPage>()) {}

        if (liveConsultations.isNotEmpty &&
            !isIncomingRequestPageOpen) {

          isIncomingRequestPageOpen = true;
          await NotificationService.startDoctorRingtone();

          Get.to(
            () => const IncomingConsultationRequestsPage(),
          );
        }
      }

    } catch (e) {

      print("FETCH LIVE ERROR : $e");
    }
  }

  /// ACCEPT CONSULTATION
  Future <void> acceptConsultation( int consultationId) async {
    print("🚀 acceptConsultation() ENTERED");
    print("Consultation ID => $consultationId");
    try {
      if (_isAccepting) {
        return;
      }

      _isAccepting = true;

      isLoading.value = true;

      print("🚀 CALLING ACCEPT API...");
      print("Consultation ID: $consultationId");

      final response =
      await ApiService.acceptConsultation(consultationId);
      print("API RETURNED => $response");
      print("🚀 API FINISHED");
      print(response);

      if (response != null &&
          response.status == true) {

        print(
          "ACCEPTED ROOM ID : ${response.consultationRoomId}");

        print(
          "ACCEPTED SOCKET URL : ${response.websocketUrl}");

        print(
          "ACCEPTED STATUS : ${response.consultationStatus}");

        stopPolling();

        pendingRequests.removeWhere(

          (e) =>
              e.consultationRequestId ==
              consultationId,
        );

        await NotificationService.stopDoctorRingtone();

        print("STEP 1");

        FlutterCallkitIncoming.endAllCalls();

        print("STEP 2");

        await Future.delayed(
          const Duration(milliseconds: 300),
        );

        print("STEP 3");

        print("OPENING DOCTOR CALL PAGE");

        print("BEFORE NAVIGATION");

        Get.offAll(
          () => ConsultationCallPage(
            roomId: response.consultationRoomId ?? "",
            websocketUrl: response.websocketUrl ?? "",
            consultationRequestId: consultationId,
            isDoctor: true,
            receiverId: response.patient?.patientId ?? "",
          )
        );

        print("AFTER NAVIGATION");
      }
    } catch (e) {

      print(
          "ACCEPT ERROR : $e");

    } finally {

      isLoading.value = false;
      _isAccepting = false;
    }
  }

  Future<void> declineConsultation(
      int consultationId) async {

    try {

      isLoading.value = true;

      final success =
          await ApiService.declineConsultation(
        consultationId,
      );

      if (success) {

        liveConsultations.removeWhere(

          (e) =>
              e.consultationRequestId ==
              consultationId,
        );

        pendingRequests.removeWhere(

          (e) =>
              e.consultationRequestId ==
              consultationId,
        );

        await NotificationService.stopDoctorRingtone();

        Get.snackbar(

          "Success",

          "Consultation Declined Successfully",
        );

      } else {

        Get.snackbar(

          "Error",

          "Unable to decline consultation",
        );
      }

    } catch (e) {

      print("DECLINE ERROR : $e");

    } finally {

      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    pollingTimer?.cancel();
    countdownTimer?.cancel();
    super.onClose();
  }
}