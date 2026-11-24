import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/presentation/screens/meet%20a%20vet/consultationSocketService.dart';
import 'package:pawlli/presentation/widgets/bottom%20bar/bottombar.dart';
import 'package:web_socket_channel/io.dart';

class ConsultationCallPage
    extends StatefulWidget {

  final String roomId;
  final String websocketUrl;
  final int consultationRequestId;
  final bool isDoctor;
  final String receiverId;

  const ConsultationCallPage({

    super.key,
    required this.roomId,
    required this.websocketUrl,
    required this.consultationRequestId,
    required this.isDoctor,
    required this.receiverId,
  });

  @override
  State<ConsultationCallPage>
  createState() =>
      _ConsultationCallPageState();
}

  class _ConsultationCallPageState
      extends State<ConsultationCallPage> {

        final socketService = ConsultationSocketService();
        bool peerDisconnected = false;
        bool callEnded = false;

          bool isCameraOn = true;
          bool isMicOn = true;
          bool isLocalFullScreen = false;

    IOWebSocketChannel? chatSocket;
    StreamSubscription? _chatSubscription;
    bool isChatConnected = false;

    int userId = 0;

    String mySenderId = "";

    /// Current logged user
    String currentUsername = "User";
    String currentProfileImage = "";

    /// Chat UI
    bool isChatVisible = false;

    bool hasUnreadMessage = false;

    int unreadChatCount = 0;

    /// Chat controller
    final TextEditingController chatController =
        TextEditingController();

    final ScrollController chatScrollController =
        ScrollController();

    /// Chat Messages
    List<Map<String, dynamic>> chatMessages = [];


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("PAGE FIRST FRAME DRAWN");
    });

    print("================================");
    print("CALL PAGE OPENED");
    print("CONSULTATION CALL PAGE INITSTATE");
    print("IS DOCTOR => ${widget.isDoctor}");
    print("ROOM ID => ${widget.roomId}");
    print("WS URL => ${widget.websocketUrl}");
    print("================================");

    print("CONSULTATION PAGE OPENED");

    print(
      "CONNECTED ROOM ID : ${widget.roomId}");

    print(
        "WEBSOCKET URL : ${widget.websocketUrl}");

    print(
        "CONSULTATION ID : ${widget.consultationRequestId}");


    /// CONNECT WEBSOCKET HERE
    Future.microtask(() async {
      try {
        await startCall();
      } catch (e, s) {
        print("START CALL ERROR");
        print(e);
        print(s);
      }
    });
  }

  @override
  void dispose() {

    try {
      _chatSubscription?.cancel();
      chatSocket?.sink.close();
    } catch (_) {}

    isChatConnected = false;

    try {
      socketService.dispose();
    } catch (_) {}

    chatController.dispose();

    chatScrollController.dispose();

    super.dispose();
  }

  String formatTime(String value) {

    final dt =
        DateTime.parse(value).toLocal();

    return "${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}";
  }

    Future startCall() async {

      final box = GetStorage();

      userId = int.parse(
        box.read(LocalStorageConstants.userId)?.toString() ?? "0",
      );

      print("USER ID FROM STORAGE => $userId");

      print("================================");
      print("START CALL");
      print("ROLE : ${widget.isDoctor ? "DOCTOR" : "USER"}");
      print("IS DOCTOR : ${widget.isDoctor}");
      print("ROOM ID : ${widget.roomId}");
      print("WS URL : ${widget.websocketUrl}");
      print("================================");

      try {
         print("STEP 1");
        await socketService.initialize();
        print("STEP 2");

        socketService.onPeerLeft = () {

          print("PEER DISCONNECTED");

          if (mounted) {
            setState(() {
              peerDisconnected = true;
            });
          }
        };

        socketService.onPeerRejoined = () {

          print("PEER REJOINED");

          if (mounted) {
            setState(() {
              peerDisconnected = false;
            });
          }
        };
        print("INITIALIZE SUCCESS");
      } catch (e) {
        print("INITIALIZE ERROR");
        print(e);
      }

      try {
        await Helper.setSpeakerphoneOn(true);
        print("SPEAKER SUCCESS");
      } catch (e) {
        print("SPEAKER ERROR");
        print(e);
      }

      try {
        await socketService.connect(
          widget.websocketUrl,
          widget.isDoctor,
          userId.toString(),
        );
        print("STEP 3");
        print("SOCKET SUCCESS");
      } catch (e) {
        print("SOCKET ERROR");
        print(e);
      }

      try {
        await connectChatSocket();
        print("CHAT SUCCESS");
      } catch (e, s) {
        print("CHAT ERROR");
        print(e);
        print("START CALL ERROR => $e");
        print(s);
      }

      socketService.onCallEnded = () {

        handleCallEnd();
      };

      print("CONNECT DONE");

      if (mounted) {
        setState(() {});
      }
    }

    Future<void> connectChatSocket() async {

      if (isChatConnected) {
        print("⚠️ CHAT ALREADY CONNECTED");
        return;
      }

      final box = GetStorage();

      userId = int.parse(
        box.read(LocalStorageConstants.userId)?.toString() ?? "0",
      );

      final isDoctor =
          box.read(LocalStorageConstants.isDoctor) ?? false;

      mySenderId = userId.toString();

      print("MY SENDER ID => $mySenderId");

      currentUsername =
          box.read(LocalStorageConstants.name) ?? 
              "User";

      currentProfileImage =
          box.read(LocalStorageConstants.profileImage) ??
              "";

      final chatUrl =
          "wss://websocket.pawdli.com/ws/chat/dm/"
          "${widget.roomId}"
          "?user_id=$userId";

      print("================================");
      print("ROOM ID => ${widget.roomId}");
      print("USER ID => $userId");
      print("IS DOCTOR => ${widget.isDoctor}");
      print("================================");

      print("================================");
      print("💬 CONNECTING CHAT");
      print(chatUrl);
      print("================================");

      try {

        await _chatSubscription?.cancel();

        chatSocket?.sink.close();

        chatSocket = IOWebSocketChannel.connect(
          Uri.parse(chatUrl),
        );

        chatSocket!.sink.add(
          jsonEncode({
            "type": "join",
            "room_id": widget.roomId,
            "user_id": userId.toString(),
          }),
        );

        isChatConnected = true;

        _chatSubscription = chatSocket!.stream.listen(

          (event) {

            print("================================");
            print("💬 CHAT RECEIVED");
            print("CHAT EVENT => $event");
            print("================================");

            print("RAW CHAT => $event");

            final data = jsonDecode(event);

            if (data["type"] == "message") {

              print("========== CHAT JSON ==========");
              print(data);
              print("===============================");

              if (mounted) {

                final alreadyExists = chatMessages.any((msg) {
                  return msg["sender_id"] == data["sender_id"] &&
                        msg["text"] == data["text"] &&
                        msg["timestamp"] == data["timestamp"];
                });
                if (alreadyExists) {
                  print("⚠️ Duplicate message ignored");
                  return;
                }

                setState(() {

                  print("SERVER MESSAGE");
                  print(data);

                  chatMessages.add({
                    "sender_id": data["sender_id"].toString().trim(),

                    "text":
                        data["text"],

                    "username":
                        data["metadata"]?["username"] ??
                        data["sender_id"],

                    "profile_pic":

                        data["metadata"]
                                ?["profile_pic"] ??

                            "",

                    "timestamp":
                        data["timestamp"],

                  });

                  if (!isChatVisible &&
                      data["sender_id"] != mySenderId) {

                    unreadChatCount++;

                    hasUnreadMessage = true;
                  }
                });

                WidgetsBinding.instance.addPostFrameCallback((_) {

                  if (chatScrollController.hasClients) {

                    chatScrollController.animateTo(

                      chatScrollController.position.maxScrollExtent,

                      duration: const Duration(milliseconds: 300),

                      curve: Curves.easeOut,

                    );

                  }

                });
              }
            }

            if (data["type"] == "joined") {

              print("👋 USER JOINED");

              print(data);
            }

            if (data["type"] == "left") {

              print("👋 USER LEFT");

              print(data);
            }
          },

          onDone: () async {

            print("❌ CHAT CLOSED");

            isChatConnected = false;

            await Future.delayed(
              const Duration(seconds: 2),
            );

            if (mounted) {

              connectChatSocket();
            }
          },

          onError: (e) async {

            print("❌ CHAT ERROR");

            print(e);

            isChatConnected = false;

            await Future.delayed(
              const Duration(seconds: 2),
            );

            if (mounted) {

              connectChatSocket();
            }
          },
        );

      } catch (e) {

        print("❌ CHAT CONNECT ERROR");

        print(e);

        isChatConnected = false;
      }
    }

    bool _callEnded = false;

      void handleCallEnd() {

        if (_callEnded) return;

        _callEnded = true;

        if (mounted) {
          setState(() {
            callEnded = true;
          });
        }

        Future.delayed(
          const Duration(seconds: 3),
          () async {

            try {
              await chatSocket?.sink.close();
            } catch (_) {}

            isChatConnected = false;

            if (!mounted) return;

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => MainLayout(),
              ),
              (route) => false,
            );
          },
        );
      }

    void sendMessage() {

      final text = chatController.text.trim();

      if (text.isEmpty) return;

      //// Show immediately
      // setState(() {

      //   chatMessages.add({

      //     "sender_id": mySenderId,

      //     "text": text,

      //     "username": currentUsername,

      //     "profile_pic": currentProfileImage,

      //     "timestamp": DateTime.now().toIso8601String(),

      //   });

      // });

      print("================================");
      print("SENDING CHAT");
      print(text);
      print(mySenderId);
      print("================================");
      print("SENDING FROM => $mySenderId");
      // Send to server
      chatSocket?.sink.add(
        jsonEncode({
          "type": "message",
          "receiver_id": widget.receiverId,
          "text": text,
          "metadata": {
            "username": currentUsername,
            "profile_pic": currentProfileImage,
          }
        }),
      );

      chatController.clear();

      Future.delayed(

        const Duration(milliseconds: 100),

        () {

          if (chatScrollController.hasClients) {

            chatScrollController.animateTo(

              chatScrollController.position.maxScrollExtent,

              duration: const Duration(milliseconds: 300),

              curve: Curves.easeOut,

            );

          }

        },

      );
    }

    Widget buildChatUI() {
      return Positioned(
        right: 16,
        bottom: 100,
        child: Container(
          width: 320,
          height: 420,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [

              Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [

                    const Text(
                      "Chat",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        setState(() {
                          isChatVisible = false;
                        });
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(

                  controller:
                      chatScrollController,

                  itemCount:
                      chatMessages.length,

                  itemBuilder: (_, index) {

                    final msg =
                        chatMessages[index];

                    print("------------");
                    print("MESSAGE SENDER : ${msg["sender_id"]}");
                    print("MY SENDER      : $mySenderId");

                    final isMine =
                        msg["sender_id"].toString().trim() ==
                        mySenderId.trim();

                    print("IS MINE : $isMine");
                    print("------------");

                    return Align(

                      alignment:

                          isMine

                              ? Alignment.centerRight

                              : Alignment.centerLeft,

                      child: Container(

                        constraints:
                            const BoxConstraints(
                          maxWidth: 220,
                        ),

                        margin:
                            const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),

                        padding:
                            const EdgeInsets.all(12),

                        decoration: BoxDecoration(

                          color:

                              isMine

                                  ? Colors.green.withValues(alpha: .40)

                                  : Colors.blue.withValues(alpha: .35),

                          borderRadius:
                              BorderRadius.circular(
                                  16),
                        ),

                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(
                              msg["username"] ?? "",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),

                            const SizedBox(height: 4),

                            if (!isMine)
                              const SizedBox(
                                  height: 4),

                            Text(

                              msg["text"],

                              style:
                                  const TextStyle(

                                color: Colors.white,

                                fontSize: 15,
                              ),
                            ),

                            const SizedBox(
                                height: 5),

                            Align(

                              alignment:
                                  Alignment
                                      .bottomRight,

                              child: Text(

                                formatTime(
                                    msg["timestamp"],
                                ),

                                style:
                                    const TextStyle(

                                  color:
                                      Colors.white70,

                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(

                padding:
                    const EdgeInsets.all(10),

                child: Row(

                  children: [

                    Expanded(

                      child: TextField(

                        controller:
                            chatController,

                        textInputAction: TextInputAction.send,

                        onSubmitted: (_) {

                          sendMessage();

                        },

                        style:
                            const TextStyle(
                          color: Colors.white,
                        ),

                        decoration:InputDecoration(

                          hintText:"Type message",

                          hintStyle:
                              const TextStyle(
                            color: Colors.white54,
                          ),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                    20),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    CircleAvatar(

                      child: IconButton(

                        icon: const Icon(
                          Icons.send,
                        ),

                        onPressed:
                            sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildControlButton({
      required IconData icon,
      required VoidCallback onTap,
      Color bgColor = Colors.black54,
    }) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          onPressed: onTap,
          icon: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ),
      );
    }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      Colors.black,

      // appBar: AppBar(

      //   backgroundColor:
      //   Colors.black,

      //   title: const Text(
      //     "Consultation Call",
      //   ),
      // ),

      body: SafeArea(
        child: Stack(
          children: [

            /// REMOTE VIDEO FULL SCREEN
            Positioned.fill(
              child: RTCVideoView(
                isLocalFullScreen
                    ? socketService.localRenderer
                    : socketService.remoteRenderer,
                mirror: isLocalFullScreen,
                objectFit:
                    RTCVideoViewObjectFit
                        .RTCVideoViewObjectFitCover,
              ),
            ),

            /// LOCAL VIDEO SMALL BOX
            Positioned(
              top: 20,
              right: 15,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isLocalFullScreen = !isLocalFullScreen;
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.28,
                  height: MediaQuery.of(context).size.height * 0.22,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius:
                        BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: RTCVideoView(
                    isLocalFullScreen
                        ? socketService.remoteRenderer
                        : socketService.localRenderer,
                    mirror: !isLocalFullScreen,
                    objectFit:
                        RTCVideoViewObjectFit
                            .RTCVideoViewObjectFitCover,
                  ),
                  
                ),
              ),
            ),

            if (peerDisconnected)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        CircularProgressIndicator(),

                        SizedBox(height: 20),

                        Text(
                          "Reconnecting...",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (callEnded)
                Positioned.fill(
                  child: Container(
                    color: Colors.black87,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          Icon(
                            Icons.call_end,
                            color: Colors.red,
                            size: 80,
                          ),

                          SizedBox(height: 20),

                          Text(
                            "Call Ended",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 10),

                          Text(
                            "Returning to Home...",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

            /// BOTTOM CONTROLS
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                children: [

                  buildControlButton(
                    icon: Icons.flip_camera_ios,
                    onTap: () async {
                      final tracks =
                          socketService.localStream
                              ?.getVideoTracks();

                      if (tracks != null &&
                          tracks.isNotEmpty) {
                        await Helper.switchCamera(
                          tracks.first,
                        );
                      }
                    },
                  ),

                  buildControlButton(
                    icon: isMicOn
                        ? Icons.mic
                        : Icons.mic_off,
                    bgColor: isMicOn
                        ? Colors.black54
                        : Colors.red,
                    onTap: () {
                      isMicOn = !isMicOn;

                      socketService.localStream
                          ?.getAudioTracks()
                          .forEach((track) {
                        track.enabled = isMicOn;
                      });

                      setState(() {});
                    },
                  ),

                  buildControlButton(
                    icon: Icons.call_end,
                    bgColor: Colors.red,
                    onTap: () async {

                      if (_callEnded) return;

                      _callEnded = true;

                      print("DOCTOR END BUTTON CLICKED");

                      socketService.socket?.sink.add(
                        jsonEncode({
                          "type": "call_ended",
                        }),
                      );

                      await ApiService.endConsultation(
                        widget.consultationRequestId,
                      );

                      await socketService.dispose();

                      await chatSocket?.sink.close();

                      if (!mounted) return;

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MainLayout(),
                        ),
                        (route) => false,
                      );
                    },
                  ),

                  Stack(
                    children: [

                      buildControlButton(

                        icon: Icons.chat,

                        onTap: () {

                          setState(() {

                            isChatVisible = !isChatVisible;

                            unreadChatCount = 0;

                            hasUnreadMessage = false;

                          });

                        },

                      ),

                      if (hasUnreadMessage)

                        Positioned(

                          right: 0,

                          top: 0,

                          child: Container(

                            padding: const EdgeInsets.all(5),

                            decoration: const BoxDecoration(

                              color: Colors.green,

                              shape: BoxShape.circle,

                            ),

                            child: Text(

                              unreadChatCount.toString(),

                              style: const TextStyle(

                                color: Colors.white,

                                fontWeight: FontWeight.bold,

                                fontSize: 10,

                              ),

                            ),

                          ),

                        ),

                    ],

                  ),

                  buildControlButton(
                    icon: isCameraOn
                        ? Icons.videocam
                        : Icons.videocam_off,
                    bgColor: isCameraOn
                        ? Colors.black54
                        : Colors.red,
                    onTap: () {
                      isCameraOn = !isCameraOn;

                      socketService.localStream
                          ?.getVideoTracks()
                          .forEach((track) {
                        track.enabled = isCameraOn;
                      });

                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            if (isChatVisible)
              buildChatUI(),
          ],
          
        ),
      ),
    );
  }
}