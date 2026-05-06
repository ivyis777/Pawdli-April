// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// import '../../../services/ZegoConfig/ZegoConfig.dart';
// import '../../../data/api service.dart';

// class ZegoVideoCallPage extends StatefulWidget {
//   final int userId;
//   final String userName;
//   final String roomId;
//   final int sessionId;
//   final bool isVideoCall;
//   final bool isCaller;

//   const ZegoVideoCallPage({
//     super.key,
//     required this.userId,
//     required this.userName,
//     required this.roomId,
//     required this.sessionId,
//     required this.isVideoCall,
//     required this.isCaller,
//   });

//   @override
//   State<ZegoVideoCallPage> createState() =>
//       _ZegoVideoCallPageState();
// }

// class _ZegoVideoCallPageState
//     extends State<ZegoVideoCallPage> {

//   WebSocketChannel? _callChannel;

//   @override
//   void initState() {
//     super.initState();
//     _initializeWebSocket();
//   }

//   Future<void> _initializeWebSocket() async {
//     try {
//       final token = await ApiService.getAccessToken();

//       final wsUrl =
//           'wss://app.pawdli.com/ws/call/${widget.roomId}/?token=$token';

//       _callChannel = WebSocketChannel.connect(
//         Uri.parse(wsUrl),
//       );

//       _callChannel!.stream.listen((message) {
//         debugPrint("WS MESSAGE: $message");
//       });

//     } catch (e) {
//       debugPrint("WS ERROR: $e");
//     }
//   }

//   Future<void> _endCall() async {

//     if (widget.isCaller) {
//       await ApiService.endCall(
//         userId: widget.userId,
//         sessionId: widget.sessionId,
//       );
//     } else {
//       await ApiService.LeaveCall(
//         userId: widget.userId,
//         sessionId: widget.sessionId,
//       );
//     }

//     await _callChannel?.sink.close();

//     if (mounted) {
//       Navigator.pop(context);
//     }
//   }

//   @override
//   void dispose() {
//     _callChannel?.sink.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {

//     final config = widget.isVideoCall
//         ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
//         : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

//     return SafeArea(
//       child: ZegoUIKitPrebuiltCall(
//         appID: ZegoConfig.appID,
//         appSign: ZegoConfig.appSign,
//         userID: widget.userId.toString(),
//         userName: widget.userName,
//         callID: widget.roomId,
//         config: config,
//       ),
//     );
//   }
// }