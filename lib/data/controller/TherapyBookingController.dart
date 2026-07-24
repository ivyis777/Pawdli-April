import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/TherapyBookingModel.dart';
import 'package:pawlli/data/model/therapySuperUsermodel.dart' hide BookingSlot;

class TherapyBookingController
    extends GetxController {

  RxBool isLoading = false.obs;

  RxList<TherapyBookingData>
      bookingList =
      <TherapyBookingData>[].obs;

  RxList<SuperTherapyBookingData> superBookingList =
    <SuperTherapyBookingData>[].obs;

  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();

    fetchBookings();
  }

  Future<void> fetchBookings() async {

    try {

      isLoading.value = true;

      final isSuperUser =
          box.read(LocalStorageConstants.isSuperUser) ?? false;

      if (isSuperUser) {

        print("SUPER USER LOGIN");

        final result =
            await ApiService.fetchAllTherapyBookings();

        if (result != null && result.data != null) {

          // Keep full super user data
          superBookingList.assignAll(result.data!);

          for (final booking in result.data!) {
            print(
              "Booking ${booking.bookingId} -> ${booking.bookingStatus}",
            );
          }

          // Create simplified list only for ListView
          bookingList.assignAll(

            result.data!.map((e) {

              return TherapyBookingData(

                bookingId: e.bookingId,

                userId: e.userId,

                userName: e.userName,

                pettherapyId: e.pettherapyId,

                therapyName: e.therapyName,

                therapyImage: e.therapyImage,

                bookingDate: e.slot?.date,

                bookingStatus: e.bookingStatus,

                slot: BookingSlot(

                  slotId: e.slot?.slotId,

                  date: e.slot?.date,

                  startTime: e.slot?.startTime,

                  endTime: e.slot?.endTime,

                ),

              );

            }).toList(),

          );
        }

      } else {

        print("NORMAL USER LOGIN");

        final result =
            await ApiService.fetchTherapyBookings();

        if (result != null &&
            result.data != null) {

          bookingList.assignAll(result.data!);
        }
      }

    } catch (e) {

      print(e);

        } finally {

          isLoading.value = false;
        }
      }

      Future<bool> updateBookingStatus({
        required int bookingId,
        required String status,
      }) async {
          print("===============");
          print("UPDATE STATUS");
          print("Booking ID : $bookingId");
          print("Status : $status");

        bool success = false;

        if (status == "Cancelled") {

          
          print("CALLING CANCEL API...");
          print("CANCEL API RESULT = $success");

          success = await ApiService.cancelTherapyBooking(
            bookingId: bookingId,
          );

        } else {

          success = await ApiService.updateTherapyBookingStatus(
            bookingId: bookingId,
            bookingStatus: status,
          );

        }
          print("REFRESHING BOOKINGS...");
        if (success) {

          await fetchBookings();

        }
        print("BOOKINGS REFRESHED");
        print("===============");

        return success;
      }
    }
