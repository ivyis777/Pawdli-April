// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:pawlli/core/storage_manager/colors.dart';

// class ConsultationNotificationService {

//   static final AudioPlayer player =
//       AudioPlayer();

//   static Future<void> showIncomingConsultation({

//     required String petName,
//     required String symptoms,
//     required VoidCallback onAccept,

//   }) async {

//     await player.play(
//       AssetSource("ringtone.mp3"),
//     );

//     Get.dialog(
//       barrierDismissible: false,
//       Dialog(
//         backgroundColor: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//           side: BorderSide(
//             color: Colours.primarycolour,
//             width: 1.5,
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Image.asset(
//                 "assets/images/GoodByeBuddyPopUp.png",
//                 height: 140,
//                 fit: BoxFit.contain,
//               ),

//               const SizedBox(height: 12),

//               const Text(
//                 "New Consultation",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),

//               const SizedBox(height: 15),

//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: Colours.primarycolour.withOpacity(0.2),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Pet Name : $petName",
//                       style: const TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     Text(
//                       "Symptoms : $symptoms",
//                       style: const TextStyle(
//                         fontSize: 15,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 20),

//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       style: OutlinedButton.styleFrom(
//                         side: BorderSide(
//                           color: Colours.primarycolour,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 14,
//                         ),
//                       ),
//                       onPressed: () {
//                         player.stop();
//                         Get.back();
//                       },
//                       child: Text(
//                         "Reject",
//                         style: TextStyle(
//                           color: Colours.primarycolour,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(width: 10),

//                   Expanded(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colours.primarycolour,
//                         foregroundColor: Colors.white,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 14,
//                         ),
//                       ),
//                       onPressed: () {
//                         player.stop();
//                         Get.back();
//                         onAccept();
//                       },
//                       child: const Text(
//                         "Accept",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }