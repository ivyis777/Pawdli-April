// import 'package:flutter_callkit_incoming/entities/android_params.dart';
// import 'package:flutter_callkit_incoming/entities/ios_params.dart';
// import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
// import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
// import 'package:uuid/uuid.dart';

// class IncomingConsultationService {
//   static Future<void> show({
//     required String consultationId,
//     required String petName,
//     required String symptoms,
//   }) async {

//     print("========== CALLKIT START ==========");
//     print("Consultation ID: $consultationId");
//     print("Pet: $petName");

//     final params = CallKitParams(
//       id: const Uuid().v4(),
//       nameCaller: petName,
//       appName: "Pawlli",
//       handle: symptoms,

//       type: 0,

//       duration: 30000,

//       extra: {
//         "consultationId": consultationId,
//       },

//       ios: IOSParams(
//         // iconName: "CallKitLogo",
//         handleType: "generic",
//         supportsVideo: true,
//         maximumCallGroups: 1,
//         maximumCallsPerCallGroup: 1,
//         audioSessionMode: "default",
//         audioSessionActive: true,
//         audioSessionPreferredSampleRate: 44100.0,
//         audioSessionPreferredIOBufferDuration: 0.005,
//         supportsDTMF: true,
//         supportsHolding: false,
//         supportsGrouping: false,
//         supportsUngrouping: false,
//       ),

//       android: AndroidParams(
//         isCustomNotification: true,
//         isShowLogo: true,
//         ringtonePath: "ringtone",
//         backgroundColor: "#0955fa",
//       ),
//     );

//     try {
//       await FlutterCallkitIncoming.showCallkitIncoming(params);
//       print("========== CALLKIT SHOWN ==========");
//     } catch (e) {
//       print("========== CALLKIT ERROR ==========");
//       print(e);
//     }
//   }
// }