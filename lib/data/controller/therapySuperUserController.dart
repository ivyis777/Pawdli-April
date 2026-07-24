// import 'package:get/get.dart';
// import 'package:http/http.dart' as box;
// import 'package:pawlli/core/storage_manager/local_storage.dart';
// import 'package:pawlli/data/api service.dart';
// import 'package:pawlli/data/model/TherapyBookingModel.dart';
// import 'package:pawlli/data/model/therapySuperUsermodel.dart';

// class SuperTherapyBookingController extends GetxController {

//   RxBool isLoading = false.obs;

//   RxList<SuperTherapyBookingData> bookingList =
//       <SuperTherapyBookingData>[].obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchBookings();
//   }

//   Future<void> fetchBookings() async {

//     try {

//       isLoading.value = true;

//       final isSuperUser =
//           box.read(LocalStorageConstants.isSuperUser) ?? false;

//       if (isSuperUser) {

//         print("SUPER USER LOGIN");

//         final result =
//             await ApiService.fetchAllTherapyBookings();

//         if (result != null &&
//             result.data != null) {

//           bookingList.assignAll(

//             result.data!.map((e) {

//               return TherapyBookingData(

//                 bookingId: e.bookingId,

//                 userId: e.userId,

//                 userName: e.userName,

//                 pettherapyId: e.pettherapyId,

//                 therapyName: e.therapyName,

//                 therapyImage: e.therapyImage,

//                 bookingDate: e.bookingDate,

//                 bookingStatus: e.bookingStatus,

//                 slot: BookingSlot(

//                   slotId: e.slot?.slotId,

//                   startTime: e.slot?.startTime,

//                   endTime: e.slot?.endTime,

//                 ),

//               );

//             }).toList(),

//           );
//         }

//       } else {

//         print("NORMAL USER LOGIN");

//         final result =
//             await ApiService.fetchTherapyBookings();

//         if (result != null &&
//             result.data != null) {

//           bookingList.assignAll(result.data!);
//         }
//       }

//     } catch (e) {

//       print(e);

//     } finally {

//       isLoading.value = false;
//     }
//   }
// }