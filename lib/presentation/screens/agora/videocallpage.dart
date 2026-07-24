import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pawlli/data/api service.dart';

class VideoCallPage extends StatefulWidget {
  final int userId;
  final int bookingId;
  final int sessionId;
  final String websocketUrl;
  final bool isCaller;
  final String programType;

  const VideoCallPage({
    super.key,
    required this.userId,
    required this.bookingId,
    required this.sessionId,
    required this.websocketUrl,
    required this.isCaller,
    required this.programType,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  Map<String, RTCPeerConnection> _peerConnections = {};
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  IOWebSocketChannel? _socket;

  IOWebSocketChannel? _chatSocket;

    List<Map<String, dynamic>>
      chatMessages = [];

  String myPeerId = "";
  String hostPeerId = "";
  String currentSocketUrl = "";

  bool _isReconnecting = false;
  bool _callEndedByHost = false;

  int participantCount = 1;
  List<Map<String, dynamic>>
    participants = [];
  bool muted = false;
  bool cameraOff = false;
  bool isConnected = false;
  bool frontCamera = true;
  bool speakerOn = true;
  bool _isDisposing = false;
  bool showParticipants = false;
  bool isSpeakerAllowed = false;
  bool _socketConnected = false;
  bool _chatConnected = false;
  String currentUsername = "User";

  String currentProfileImage = "";

  bool showTopMessage = false;

  String topMessage = "";

  List<dynamic> _iceServers = [];

  bool isChatVisible = false;
  int unreadChatCount = 0;

  bool hasUnreadMessage = false;

  TextEditingController chatController =
      TextEditingController();

      final ScrollController
    _chatScrollController =
        ScrollController();

  List<String> messages = [];
  // bool _offerSent = false;
  bool ignoreFirstConnectivityEvent = true;

  StreamSubscription? connectivitySubscription;

  @override
  void initState() {
    currentSocketUrl =
      widget.websocketUrl;
    super.initState();
    initRenderers();
    startCall();
  }

  void showJoinLeaveMessage(
      String text,
    ) {

      setState(() {

        topMessage = text;

        showTopMessage = true;
      });

      Future.delayed(
        const Duration(seconds: 2),
        () {

          if (mounted) {

            setState(() {

              showTopMessage = false;
            });
          }
        },
      );
    }

    Color getUserColor(
      String username,
    ) {

      final colors = [

        Colors.blue,
        Colors.purple,
        Colors.orange,
        Colors.teal,
        Colors.pink,
        Colors.cyan,
        Colors.amber,
      ];

      return colors[
        username.hashCode %
            colors.length
      ];
    }

  Future<void> initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> startCall() async {

    print("========================================");
    print("📞 STARTING WEBRTC CALL");
    print("📌 IS CALLER: ${widget.isCaller}");
    print("📌 BOOKING ID: ${widget.bookingId}");
    print("📌 SESSION ID: ${widget.sessionId}");
    print("📌 PROGRAM TYPE: ${widget.programType}");
    print("📌 WEBSOCKET URL: ${widget.websocketUrl}");
    print("========================================");

    await WakelockPlus.enable();
    
    await _requestPermissions();

    // ✅ GET TURN/STUN FROM BACKEND
    _iceServers =
        await ApiService.getIceServers();

    print("🧊 ICE SERVERS: $_iceServers");

    if (!widget.isCaller) {

      await _createPeerConnection();
    }

    await _openUserMedia();

    await _connectSocket();

    // await _connectChatSocket();

    participantCount = 1;

connectivitySubscription =
    Connectivity()
        .onConnectivityChanged
        .listen((event) async {

  // ✅ IGNORE FIRST EVENT
  if (ignoreFirstConnectivityEvent) {

    ignoreFirstConnectivityEvent = false;

    print("✅ IGNORING FIRST CONNECTIVITY EVENT");

    return;
  }

  // ✅ DO NOT RECONNECT IF SOCKET ACTIVE
  if (_socketConnected ||
    _isReconnecting) {

    print("✅ SOCKET ALREADY CONNECTED");

    return;
  }

  print("🌐 NETWORK CHANGED: $event");

  // ✅ INTERNET LOST
  if (event.isEmpty ||
    event.first == ConnectivityResult.none) {

  print("❌ NO INTERNET");

  return;
}

  print("🔄 RECONNECTING SOCKET");

  try {

    await _restartAndReconnect();

//   // ✅ CLOSE LISTENER CONNECTION
//   await _peerConnection?.close();

//   // ✅ CLOSE ALL HOST PEERS
//   for (var pc in _peerConnections.values) {

//     await pc.close();
//   }

//   _peerConnections.clear();

// await _createPeerConnection();

// if (_localStream != null) {

//   for (var track
//       in _localStream!.getTracks()) {

//     _peerConnection!.addTrack(
//       track,
//       _localStream!,
//     );
//   }
// }

// await _connectSocket();  

  } catch (e) {

    print("❌ RECONNECT ERROR: $e");
  }
});
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
    ].request();
  }

  Future<void> _connectSocket() async {

    print("🔌 WEBSOCKET CONNECTED");
    print("🌐 SOCKET URL: $currentSocketUrl");


    _socket = IOWebSocketChannel.connect(
      Uri.parse(currentSocketUrl),
    );

    _socketConnected = true;
    _isReconnecting = false;

    _socket!.stream.listen(
      (message) {

        print("==================================");
        print("📩 RAW SOCKET MESSAGE");
        print(message);
        print("==================================");

        _handleSocketMessage(message);
      },
      onDone: () async {

        _socketConnected = false;

        debugPrint('socket closed');

        if (!_callEndedByHost &&
            !_isDisposing) {

          await Future.delayed(
            const Duration(seconds: 2),
          );

          _restartAndReconnect();
        }
      },
      onError: (e) async {

        _socketConnected = false;

        debugPrint('socket error $e');

        if (!_callEndedByHost &&
            !_isDisposing) {

          await Future.delayed(
            const Duration(seconds: 2),
          );

          _restartAndReconnect();
        }
      },
    );

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    _sendMessage({

      "type": "register",

      "user_id": widget.userId,
    });

    print("================================");
    print("✅ REGISTER SENT");
    print({
      "type": "register",
      "user_id": widget.userId,
    });
    print("================================");

    // ✅ CONNECT CHAT AFTER REGISTER

    if (!_chatConnected) {

      await Future.delayed(
        const Duration(seconds: 1),
      );

      await _connectChatSocket();
    }
  }
  

  Future<void> _connectChatSocket() async {

    if (_chatConnected) {

        print("⚠️ CHAT ALREADY CONNECTED");

        return;
      }

      if (_chatSocket != null) {

        await _chatSocket?.sink.close();

        _chatSocket = null;
      }

    try {

      final chatUrl =

        "wss://websocket.pawdli.com"
        "/ws/chat/group/"
        "${widget.bookingId}"
        "?user_id=${widget.userId}";

      print("================================");
      print("💬 CONNECTING CHAT SOCKET");
      print(chatUrl);
      print("================================");

      _chatSocket = IOWebSocketChannel.connect(
        Uri(
          scheme: 'wss',
          host: 'websocket.pawdli.com',
          path: '/ws/chat/group/${widget.bookingId}',
          queryParameters: {
            'user_id': widget.userId.toString(),
          },
        ),
      );

      _chatConnected = true;

      _chatSocket!.stream.listen(

        (message) {

          print("================================");
          print("💬 CHAT MESSAGE RECEIVED");
          print(message);
          print("================================");

          final data =
              jsonDecode(message);

          // =========================
          // NEW CHAT MESSAGE
          // =========================

          if (data['type'] == 'message') {

            if (mounted) {

              setState(() {

                chatMessages.add({

                  "text":
                      data['text'],

                  "sender_id":
                      data['sender_id'],

                  "username":
                      data['metadata']
                              ?['username'] ??
                          'User',

                  "profile_pic":
                      data['metadata']
                              ?['profile_pic'] ??
                          '',

                  "timestamp":
                      data['timestamp'],
                });

                Future.delayed(

                  const Duration(milliseconds: 100),

                  () {

                    if (_chatScrollController
                        .hasClients) {

                      _chatScrollController.animateTo(

                        _chatScrollController
                            .position
                            .maxScrollExtent,

                        duration: const Duration(
                          milliseconds: 300,
                        ),

                        curve: Curves.easeOut,
                      );
                    }
                  },
                );

                // ✅ UNREAD MESSAGE COUNT
                if (!isChatVisible &&
                    data['sender_id'] != widget.userId) {

                  unreadChatCount++;

                  hasUnreadMessage = true;
                }
              });
            }
          }

          // =========================
          // USER JOINED
          // =========================

          if (data['type'] == 'joined') {

            print(
              "👋 USER JOINED CHAT",
            );

            print(data);
          }

          // =========================
          // USER LEFT
          // =========================

          if (data['type'] == 'left') {

            print(
              "👋 USER LEFT CHAT",
            );

            print(data);
          }
        },

        onError: (e) {

          _chatConnected = false;

          print(
            "❌ CHAT SOCKET ERROR",
          );

          print(e);
        },

        onDone: () {

          _chatConnected = false;

          print(
            "❌ CHAT SOCKET CLOSED",
          );
        },
      );

    } catch (e) {

      print("❌ CHAT CONNECT ERROR");
      print(e);
    }
  }

    Future<void> _restartAndReconnect() async {

    if (_isReconnecting || _isDisposing) {

      print("⚠️ RECONNECT ALREADY RUNNING");

      return;
    }

    _isReconnecting = true;

    try {

      print("==================================");
      print("🔄 RESTARTING SESSION");
      print("==================================");

      // ✅ CLOSE OLD SOCKET
      await _socket?.sink.close();
      _socket = null;

      // ✅ CLOSE OLD PEER
      await _peerConnection?.close();

      // ✅ CLOSE HOST PEERS
      for (var pc in _peerConnections.values) {
        await pc.close();
      }

      _peerConnections.clear();

      // ✅ CLEAR REMOTE
      _remoteRenderer.srcObject = null;

      setState(() {
        isConnected = false;
      });

      Map<String, dynamic>? response;

      // ==============================
      // HOST RESTART
      // ==============================

      if (widget.isCaller) {

        response =
            await ApiService.websocketRestartRoom(
          bookingId: widget.bookingId,
        );
      }

      // ==============================
      // LISTENER REJOIN
      // ==============================

      else {

        response =
            await ApiService.websocketRejoinRoom(
          bookingId: widget.bookingId,
        );
      }

      if (response == null) {

        print("❌ REJOIN API FAILED");

        _isReconnecting = false;

        return;
      }

      print("✅ REJOIN API SUCCESS");

      // ✅ GET WEBSOCKET URL
      String? newSocketUrl =
          response['websocket_url'];

      // ✅ FALLBACK USING CHANNEL NAME
      if (newSocketUrl == null ||
          newSocketUrl.isEmpty) {

        print(
          "⚠️ websocket_url missing "
          "from API response",
        );

        final channelName =
            response['channel_name'];

        print(
          "📡 CHANNEL NAME: "
          "$channelName",
        );

        if (channelName != null &&
            channelName
                .toString()
                .isNotEmpty) {

          newSocketUrl =
              "wss://websocket.pawdli.com/ws/"
              "$channelName"
              "?peer_type="
              "${widget.isCaller ? 'host' : 'listener'}";

          print(
            "✅ GENERATED SOCKET URL",
          );

          print(newSocketUrl);
        }
      }

      // ✅ STILL NULL
      if (newSocketUrl == null ||
          newSocketUrl.isEmpty) {

        print("❌ NO ACTIVE ROOM");

        await Future.delayed(
          const Duration(seconds: 5),
        );

        if (!_callEndedByHost &&
            !_isDisposing) {

          _restartAndReconnect();
        }

        return;
      }

      // ✅ SAVE CURRENT SOCKET URL
      currentSocketUrl =
          newSocketUrl;

          _iceServers =
      await ApiService.getIceServers();

      // ✅ CREATE NEW PEER
      if (!widget.isCaller) {
        await _createPeerConnection();

        print("✅ NEW PEER CONNECTION CREATED");
      }

      // ✅ READD TRACKS
        if (_localStream != null &&
            _peerConnection != null) {

          for (var track
              in _localStream!.getTracks()) {

            _peerConnection!.addTrack(
              track,
              _localStream!,
            );

            print(
              "✅ TRACK RE-ADDED: "
              "${track.kind}",
            );
          }
        }

      // ✅ CONNECT NEW SOCKET
      _socket = IOWebSocketChannel.connect(
        Uri.parse(newSocketUrl),
      );

      _socket!.stream.listen(
        (message) {

          print("📩 RECONNECTED SOCKET MESSAGE");

          _handleSocketMessage(message);
        },
        onDone: () {

          _socketConnected = false;

          print("❌ SOCKET CLOSED");

          if (!_callEndedByHost &&
              !_isDisposing) {

            _restartAndReconnect();
          }
        },
        onError: (e) {

          _socketConnected = false;

          print("❌ SOCKET ERROR: $e");

          if (!_callEndedByHost &&
              !_isDisposing) {

            _restartAndReconnect();
          }
        },
      );

      await Future.delayed(
          const Duration(milliseconds: 500),
        );

        _sendMessage({

          "type": "register",

          "user_id": widget.userId,
        });

        print("================================");
        print("✅ RECONNECT REGISTER SENT");
        print({
          "type": "register",
          "user_id": widget.userId,
        });
        print("================================");

        // ================================
        // ✅ RECONNECT CHAT SOCKET
        // ================================

        // await _chatSocket?.sink.close();

        // _chatSocket = null;

        // _chatConnected = false;

        // print("💬 RECONNECTING CHAT SOCKET");

        // await _connectChatSocket();

        // print("✅ CHAT SOCKET RECONNECTED");

        print("✅ SESSION RECONNECTED");

    } catch (e) {

      print("❌ RECONNECT ERROR: $e");

    } finally {

      _isReconnecting = false;
    }
  }

  Future<void> _createPeerConnection() async {
    Map<String, dynamic> configuration = {
      'sdpSemantics': 'unified-plan',
      'iceServers':
    _iceServers.isNotEmpty
        ? _iceServers
        : [
            {
              'urls': [
                'stun:stun.l.google.com:19302',
              ],
            },
          ],
    };

    _peerConnection = await createPeerConnection(configuration);

    _peerConnection!.onIceCandidate = (candidate) {
      print("🧊 ICE CANDIDATE GENERATED");
      print(candidate.toMap());
      if (candidate.candidate != null) {
        _sendMessage({
          'type': 'ice_candidate',
          'target': hostPeerId,
          'from': myPeerId,
          'candidate': candidate.toMap(),
        });
      }
    };

    _peerConnection!.onTrack = (event) async {

      print("🎥 REMOTE TRACK RECEIVED");

      print("TRACK KIND: ${event.track.kind}");

      print("STREAMS: ${event.streams.length}");

      if (event.streams.isNotEmpty) {

        _remoteRenderer.srcObject =
            event.streams[0];

            await Helper.setSpeakerphoneOn(true);

            // await Helper.setMicrophoneMute(false);

            for (var track
                in event.streams[0].getAudioTracks()) {

              track.enabled = true;
            }

            print("🔊 REMOTE AUDIO ENABLED");

            await Future.delayed(
              const Duration(milliseconds: 500),
            );

            await Helper.setSpeakerphoneOn(
              speakerOn,
            );

        print("🎥 REMOTE STREAM ATTACHED");

        // ✅ FORCE AUDIO TO SPEAKER
        await Helper.setSpeakerphoneOn(true);

        // ✅ UNMUTE REMOTE AUDIO
        _remoteRenderer.audioOutput(
          "speaker",
        );

        print("🔊 REMOTE AUDIO ENABLED");


        await Future.delayed(
          const Duration(milliseconds: 500),
        );

        if (mounted) {

          setState(() {

            isConnected = true;
          });
        }
      }
    };

    _peerConnection!.onConnectionState = (state) {
      debugPrint("📡 CONNECTION STATE: $state");

      if (state ==
          RTCPeerConnectionState.RTCPeerConnectionStateConnected) {

        setState(() {
          isConnected = true;
        });

        debugPrint("✅ CALL CONNECTED");
      }

      if (state ==
          RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {

        debugPrint("❌ CALL DISCONNECTED");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Call disconnected"),
            ),
          );
        }
      }

      if (state ==
          RTCPeerConnectionState.RTCPeerConnectionStateFailed) {

        debugPrint("🚨 CONNECTION FAILED");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Connection failed"),
            ),
          );
        }
      }
    };
  }

  Future<void> _openUserMedia() async {

    final mediaConstraints = {

      'audio': {

        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
        'googEchoCancellation': true,
        'googNoiseSuppression': true,
        'googAutoGainControl': true,
        'googHighpassFilter': true,
      },

      'video':
          widget.programType.toLowerCase() == 'video'
              ? {
                  'facingMode': 'user',
                }
              : false,
    };

    _localStream =
        await navigator.mediaDevices
            .getUserMedia(
      mediaConstraints,
    );

    print(
      "PROGRAM TYPE: ${widget.programType}",
    );

    print(
      "VIDEO ENABLED: "
      "${widget.programType.toLowerCase() == 'video'}",
    );

    await Helper.setSpeakerphoneOn(true);

    _localRenderer.srcObject =
        _localStream;

    print("LOCAL TRACKS:");

    // ✅ FORCE ENABLE AUDIO TRACKS
    for (var track
      in _localStream!
          .getAudioTracks()) {

    // ✅ HOST MIC ENABLED
    if (widget.isCaller) {

      track.enabled = true;
    }

    // ✅ LISTENER START MUTED
    else {

      track.enabled = false;
    }

    print(
      "🎤 AUDIO ENABLED: "
      "${track.enabled}",
    );
  }

    for (var track
        in _localStream!
            .getTracks()) {

      print(track.kind);
    }

    // ✅ ONLY LISTENER USES _peerConnection
    if (!widget.isCaller &&
        _peerConnection != null) {

      for (var track
          in _localStream!
              .getTracks()) {

        _peerConnection!.addTrack(
          track,
          _localStream!,
        );
      }
    }
  }

  Future<void> _createOffer() async {
    print("📤 CREATING OFFER");
    RTCSessionDescription offer =
        await _peerConnection!.createOffer();

    await _peerConnection!.setLocalDescription(offer);

    _sendMessage({
      'type': 'offer',
      'sdp': offer.sdp,
    });
    print("✅ OFFER CREATED");
    print("📄 SDP: ${offer.sdp}");
  }

  Future<void> _createAnswer() async {
    print("📤 CREATING ANSWER");
    RTCSessionDescription answer =
        await _peerConnection!.createAnswer();

    await _peerConnection!.setLocalDescription(answer);

    _sendMessage({
      'type': 'answer',
      'sdp': answer.sdp,
    });
    print("✅ ANSWER CREATED");
    print("📄 SDP: ${answer.sdp}");
  }

  void _handleSocketMessage(dynamic data) async {

    print("📩 RAW SOCKET DATA: $data");

    final message = jsonDecode(data);

    print("📩 SOCKET MESSAGE: $message");

    try {

      switch (message['type']) {

        case 'listener_ready':

          print("📢 LISTENER READY RECEIVED");

          if (!widget.isCaller) return;

          final peerId = message['peer_id'];

          print("👤 NEW PEER: $peerId");

          // ✅ already exists
          if (_peerConnections.containsKey(peerId)) {

            print("⚠️ PEER ALREADY CONNECTED");

            return;
          }

          // ✅ create new peer connection
          RTCPeerConnection pc =
              await createPeerConnection({
            'sdpSemantics': 'unified-plan',

            'iceServers': _iceServers,
          });

          _peerConnections[peerId] = pc;

          // if (mounted) {

          //     setState(() {

          //       participantCount =
          //           _peerConnections.length + 1;
          //     });
          //   }

          //   print(
          //     "👥 PARTICIPANTS: $participantCount",
          //   );

            pc.onConnectionState = (state) {

              print(
                "📡 HOST PEER STATE: $state",
              );

              if (state ==
                  RTCPeerConnectionState
                      .RTCPeerConnectionStateConnected) {

                if (mounted) {

                  setState(() {
                    isConnected = true;
                  });
                }

                print(
                  "✅ HOST CONNECTED TO LISTENER",
                );
              }
            };

          // ✅ add local tracks
          if (_localStream != null) {

            for (var track in _localStream!.getTracks()) {

              pc.addTrack(track, _localStream!);
            }
          }

          // ✅ ice candidate
          pc.onIceCandidate = (candidate) {

            if (candidate.candidate != null) {

              _sendMessage({
                'type': 'ice_candidate',
                'target': peerId,
                'from': myPeerId,
                'candidate': candidate.toMap(),
              });
            }
          };

          // ✅ create offer
          RTCSessionDescription offer =
              await pc.createOffer({
            'offerToReceiveAudio': true,
            'offerToReceiveVideo':
                widget.programType
                        .toLowerCase() ==
                    'video',
          });

          await pc.setLocalDescription(offer);

          _sendMessage({
            'type': 'offer',
            'target': peerId,
            'from': myPeerId,
            'sdp': offer.sdp,
          });

          print("✅ OFFER SENT TO: $peerId");

          break;

        case 'peers':

          final peers = message['peers'] ?? [];

          myPeerId = message['you'];

          // ✅ LISTENER READY AFTER PEER ID
          if (!widget.isCaller) {

            print("📢 LISTENER READY");

            _sendMessage({
              'type': 'listener_ready',
              'peer_id': myPeerId,
            });
          }

          print("👥 PEERS: $peers");

          print("🆔 MY ID: $myPeerId");

          break;

        case 'offer':

          final target = message['target'];

          // ✅ ignore others
          if (target != myPeerId) return;

          print("📥 OFFER RECEIVED");

          hostPeerId = message['from'];

          await _peerConnection!.setRemoteDescription(
            RTCSessionDescription(
              message['sdp'],
              'offer',
            ),
          );

          RTCSessionDescription answer =
              await _peerConnection!.createAnswer();

          await _peerConnection!.setLocalDescription(answer);

          _sendMessage({
            'type': 'answer',
            'target': message['from'],
            'from': myPeerId,
            'sdp': answer.sdp,
          });

          break;

        case 'answer':

          print("📥 ANSWER RECEIVED");

          final fromPeerId =
              message['from'];

          if (fromPeerId == null) {

            print("❌ ANSWER FROM NULL");

            return;
          }

          if (!_peerConnections
              .containsKey(fromPeerId)) {

            print("❌ PEER NOT FOUND");

            return;
          }

          await _peerConnections[fromPeerId]!
              .setRemoteDescription(
            RTCSessionDescription(
              message['sdp'],
              'answer',
            ),
          );

          print("✅ ANSWER APPLIED");

          break;

          case 'ice_candidate':

            print("🧊 ICE CANDIDATE RECEIVED");

            final candidate =
                message['candidate'];

            final fromPeerId =
                message['from'];

            if (candidate == null) {

              print("❌ ICE CANDIDATE NULL");

              return;
            }

            // =========================
            // HOST SIDE
            // =========================

            if (widget.isCaller) {

              if (!_peerConnections
                  .containsKey(fromPeerId)) {

                print(
                  "❌ HOST PEER NOT FOUND",
                );

                return;
              }

              await _peerConnections[fromPeerId]!
                  .addCandidate(

                RTCIceCandidate(
                  candidate['candidate'],
                  candidate['sdpMid'],
                  candidate['sdpMLineIndex'],
                ),
              );

              print(
                "✅ HOST ICE ADDED",
              );
            }

            // =========================
            // LISTENER SIDE
            // =========================

            else {

              await _peerConnection
                  ?.addCandidate(

                RTCIceCandidate(
                  candidate['candidate'],
                  candidate['sdpMid'],
                  candidate['sdpMLineIndex'],
                ),
              );

              print(
                "✅ LISTENER ICE ADDED",
              );
            }

            break;


        // =======================================
        // 👥 PARTICIPANTS EVENT
        // =======================================

        case 'participants':

          print("================================");
          print("👥 PARTICIPANTS EVENT");
          print(message);
          print("================================");

          final users =
              message['participants'];

          final count =
              message['count'];

          print(
            "👥 ACTIVE COUNT: $count",
          );

          if (users != null) {

            for (var user in users) {

              showJoinLeaveMessage(
                "${user['username']} joined",
              );

              print(
                "👤 USERNAME: "
                "${user['username']}",
              );

              print(
                "🖼 IMAGE: "
                "${user['profile_image']}",
              );

              print(
                "🎤 SPEAKER: "
                "${user['is_speaker']}",
              );

              print(
                "👑 HOST: "
                "${user['is_host']}",
              );

              // ✅ SAVE MY PROFILE DATA
              if (user['user_id'] == widget.userId) {

                currentUsername =
                    user['username'] ?? "User";

                currentProfileImage =
                    user['profile_image'] ?? "";

                print(
                  "✅ MY USERNAME: "
                  "$currentUsername",
                );

                print(
                  "✅ MY PROFILE IMAGE: "
                  "$currentProfileImage",
                );
              }
            }
          }

          // ✅ UPDATE UI
          if (mounted) {

            setState(() {

              participantCount =
                  count ?? 1;

              final uniqueParticipants = <String, Map<String, dynamic>>{};

                for (var user in users ?? []) {

                  final userId =
                      user['user_id'].toString();

                  uniqueParticipants[userId] = user;
                }

                participants =
                    uniqueParticipants.values.toList();

                participantCount =
                    participants.length;
            });
          }

          break;

        // =======================================
        // 👥 PARTICIPANT COUNT
        // =======================================

        // case 'participant_count':

        //   print("================================");
        //   print("👥 PARTICIPANT COUNT EVENT");
        //   print(message);
        //   print("================================");

        //   final count =
        //       message['count'];

        //   print(
        //     "👥 ACTIVE COUNT: $count",
        //   );

        //   if (mounted) {

        //     setState(() {

        //       participantCount =
        //           count ?? 1;
        //     });
        //   }

        //   break;

        // =======================================
        // 🎤 SPEAKER PERMISSION
        // =======================================

        case 'speaker_permission':

          print("================================");
          print("🎤 SPEAKER PERMISSION");
          print(message);
          print("================================");

          final allowed =
              message['allowed'];

          print(
            "🎤 ALLOWED: $allowed",
          );

          if (_localStream != null) {

            for (var track
                in _localStream!
                    .getAudioTracks()) {

              isSpeakerAllowed =
                  allowed == true;

              track.enabled =
                  isSpeakerAllowed && !muted;

              print(
                "🎤 MIC ENABLED: "
                "${track.enabled}",
              );
            }
          }

          break;

        // =======================================
        // 🗣 ACTIVE SPEAKER
        // =======================================

        case 'active_speaker':

          print("================================");
          print("🗣 ACTIVE SPEAKER EVENT");
          print(message);
          print("================================");

          final speakerPeerId =
              message['peer_id'];

          print(
            "🗣 ACTIVE SPEAKER: "
            "$speakerPeerId",
          );

          break;

        // =======================================
        // 👋 PEER LEFT
        // =======================================

        case 'peer_left':

          print("================================");
          print("👋 PEER LEFT EVENT");
          print(message);
          print("================================");

          final peerId =
              message['peer_id'];

          print(
            "👋 LEFT PEER: $peerId",
          );

          // ✅ FIND USERNAME BEFORE REMOVE
          String leftUsername =
              "Participant";

          for (var user in participants) {

            if (user['peer_id']
                    .toString() ==
                peerId.toString()) {

              leftUsername =
                  user['username']
                      ?.toString() ??
                  "Participant";

              break;
            }
          }

          // ✅ SHOW TOP MESSAGE
          showJoinLeaveMessage(
            "$leftUsername left",
          );

          // ✅ REMOVE USER
          participants.removeWhere(

            (user) =>

              user['peer_id']
                  .toString() ==

              peerId.toString(),
          );

          print(
            "👥 UPDATED COUNT: "
            "${participants.length}",
          );

          // ✅ CLOSE HOST PEER
          if (widget.isCaller) {

            if (_peerConnections
                .containsKey(peerId)) {

              await _peerConnections[peerId]
                  ?.close();

              _peerConnections.remove(
                peerId,
              );
            }
          }

          if (mounted) {

            setState(() {

              participantCount =
                  participants.length;
            });
          }

          break;

        case 'call_ended':

          print("📴 CALL ENDED");

          _callEndedByHost = true;

          _remoteRenderer.srcObject = null;

          setState(() {
            isConnected = false;

            participants.clear();

            participantCount = 0;         
          });

          // ✅ LISTENER AUTO REJOIN
          if (!widget.isCaller) {

            print("🎧 LISTENER WAITING REJOIN");

            await Future.delayed(
              const Duration(seconds: 2),
            );

            _callEndedByHost = false;

            await _restartAndReconnect();
          }

          // ✅ HOST WAITING NEXT LISTENER
          else {

            print("🎙 HOST WAITING NEXT LISTENER");

            await _peerConnection?.close();

            await _createPeerConnection();

            if (_localStream != null) {

              for (var track
                  in _localStream!.getTracks()) {

                _peerConnection!.addTrack(
                  track,
                  _localStream!,
                );
              }
            }
          }

          break;
      }

    } catch (e) {

      print("❌ SOCKET HANDLE ERROR: $e");
    }
  }

    void _sendMessage(Map<String, dynamic> data) {

      final encoded = jsonEncode(data);

      print("==================================");
      print("📤 SENDING SOCKET MESSAGE");
      print(encoded);
      print("==================================");

      _socket?.sink.add(encoded);
    }

    void _sendChatMessage() {

    final text =
        chatController.text.trim();

    if (text.isEmpty) return;

    final payload = {

      "type": "message",

      "text": text,

      "metadata": {

        "username":
            currentUsername,

        "profile_pic":
            currentProfileImage,
      }
    };

    print("================================");
    print("💬 SENDING CHAT MESSAGE");
    print(payload);
    print("================================");

    _chatSocket?.sink.add(
      jsonEncode(payload),
    );

    chatController.clear();
  }

  // void showJoinLeaveMessage(
  //   String text,
  // ) {

  //   setState(() {

  //     topMessage = text;

  //     showTopMessage = true;
  //   });

  //   Future.delayed(
  //     const Duration(seconds: 2),
  //     () {

  //       if (mounted) {

  //         setState(() {

  //           showTopMessage = false;
  //         });
  //       }
  //     },
  //   );
  // }

  // Color getUserColor(String username) {

  //   final colors = [

  //     Colors.blue,
  //     Colors.purple,
  //     Colors.orange,
  //     Colors.teal,
  //     Colors.pink,
  //     Colors.cyan,
  //     Colors.amber,
  //   ];

  //   return colors[
  //     username.hashCode %
  //         colors.length
  //   ];
  // }

  Future<void> toggleMute() async {
    muted = !muted;

    _localStream?.getAudioTracks().forEach((track) {
      track.enabled =

        widget.isCaller

            ? !muted

            : (isSpeakerAllowed && !muted);
    });

    setState(() {});
  }

  Future<void> toggleCamera() async {
    cameraOff = !cameraOff;

    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = !cameraOff;
    });

    setState(() {});
  }

  Future<void> switchCamera() async {

    try {

      if (_localStream == null) {
        print("❌ No local stream");
        return;
      }

      final videoTracks = _localStream!.getVideoTracks();

      if (videoTracks.isEmpty) {
        print("❌ No video tracks available");
        return;
      }

      final videoTrack = videoTracks.first;

      await Helper.switchCamera(videoTrack);

      print("🔄 CAMERA SWITCHED");

    } catch (e) {

      print("❌ SWITCH CAMERA ERROR: $e");
    }
  }

    Future<void> toggleSpeaker() async {

      speakerOn = !speakerOn;

      await Helper.setSpeakerphoneOn(
        speakerOn,
      );

      setState(() {});

      print("🔊 SPEAKER: $speakerOn");
    }

  Future<void> endCall() async {
    print("🛑 ENDING CALL");
    print("📌 BOOKING ID: ${widget.bookingId}");

    if (widget.isCaller) {

      await ApiService.websocketEndRoom(
        bookingId: widget.bookingId,
      );
    }

    _callEndedByHost = true;

      // _sendMessage({
      //   'type': 'call_ended',
      // });

    // ✅ LISTENER LEAVES ONLY
    if (!widget.isCaller) {

      await disposeCall();

      if (mounted) {
        Navigator.pop(context);
      }

      return;
    }

    // ✅ HOST ENDS FOR EVERYONE
    await disposeCall();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> disposeCall() async {

    _isDisposing = true;

    await WakelockPlus.disable();

    await _localRenderer.dispose();

    await _remoteRenderer.dispose();

    await _localStream?.dispose();

    // ✅ CLOSE LISTENER CONNECTION
    await _peerConnection?.close();

    // ✅ CLOSE ALL HOST PEERS
    for (var pc in _peerConnections.values) {

      await pc.close();
    }

    _peerConnections.clear();

    await _socket?.sink.close();

    await connectivitySubscription?.cancel();

    await _chatSocket?.sink.close();
  }

  @override
  void dispose() {

    _isDisposing = true;

    connectivitySubscription?.cancel();

    _socket?.sink.close();

    // ✅ CLOSE LISTENER CONNECTION
    _peerConnection?.close();

    // ✅ CLOSE ALL HOST PEERS
    for (var pc in _peerConnections.values) {

      pc.close();
    }

    _peerConnections.clear();

    _localStream?.dispose();

    _localRenderer.dispose();

    _remoteRenderer.dispose();

    _chatSocket?.sink.close();

    WakelockPlus.disable();

    super.dispose();
  }

  Widget buildVideoLayout() {

    // =========================
    // AUDIO CALL UI
    // =========================

    if (widget.programType
            .toLowerCase() ==
        'audio') {

      return Container(

        width: double.infinity,
        height: double.infinity,

        color: Colors.black,

        child: Center(

          child: Column(

            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              const Icon(
                Icons.mic,
                color: Colors.white,
                size: 90,
              ),

              const SizedBox(height: 20),

              Text(

                widget.isCaller
                    ? "Hosting Audio Room"
                    : "Listening Audio Room",

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(

                "Participants: "
                "$participantCount",

                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // =========================
    // HOST SCREEN
    // =========================

    if (widget.isCaller) {

      return SizedBox(

        width: double.infinity,
        height: double.infinity,

        child: RTCVideoView(

          _localRenderer,

          mirror: true,

          objectFit:
              RTCVideoViewObjectFit
                  .RTCVideoViewObjectFitCover,
        ),
      );
    }

    // =========================
    // LISTENER SCREEN
    // =========================

    return SizedBox(

      width: double.infinity,
      height: double.infinity,

      child: _remoteRenderer.srcObject != null

          ? RTCVideoView(

              _remoteRenderer,

              objectFit:
                  RTCVideoViewObjectFit
                      .RTCVideoViewObjectFitCover,
            )

          : Container(

              color: Colors.black,

              child: const Center(

                child:
                    CircularProgressIndicator(),
              ),
            ),
    );
  }

  
  Widget buildControls() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            heroTag: 'mute',
            onPressed: toggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
            ),
          ),
          FloatingActionButton(
            heroTag: 'camera',
            onPressed: toggleCamera,
            child: Icon(
              cameraOff
                  ? Icons.videocam_off
                  : Icons.videocam,
            ),
          ),
          FloatingActionButton(
            heroTag: 'switch',
            onPressed: switchCamera,
            child: const Icon(Icons.cameraswitch),
          ),
          FloatingActionButton(
            heroTag: 'speaker',
            onPressed: toggleSpeaker,
            child: Icon(
              speakerOn
                  ? Icons.volume_up
                  : Icons.hearing,
            ),
          ),
          FloatingActionButton(
            heroTag: 'end',
            backgroundColor: Colors.red,
            onPressed: endCall,
            child: const Icon(Icons.call_end),
          ),
        ],
      ),
    );
  }

  Widget _toolbar() {
  return Align(
    alignment: Alignment.bottomCenter,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceEvenly,
        children: [

          if (widget.isCaller || isSpeakerAllowed)

            _iconButton(
              icon: muted
                  ? Icons.mic_off
                  : Icons.mic,
              color: muted
                  ? Colors.red
                  : Colors.white,
              onPressed: toggleMute,
            ),

          if (widget.isCaller &&
            widget.programType.toLowerCase() !=
                'audio')
            _iconButton(
              icon: cameraOff
                  ? Icons.videocam_off
                  : Icons.videocam,
              color: cameraOff
                  ? Colors.red
                  : Colors.white,
              onPressed: toggleCamera,
            ),

          if (widget.isCaller &&
            widget.programType.toLowerCase() !=
                'audio')
            _iconButton(
              icon: Icons.cameraswitch,
              color: Colors.white,
              onPressed: switchCamera,
            ),

          _iconButton(
            icon: speakerOn
                ? Icons.volume_up
                : Icons.hearing,
            color: Colors.white,
            onPressed: toggleSpeaker,
          ),

          Stack(
            children: [

              _iconButton(

                icon: Icons.chat_bubble_outline,

                color: Colors.white,

                onPressed: () {

                  setState(() {

                    isChatVisible =
                        !isChatVisible;

                    // ✅ CLEAR UNREAD
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

                        color: Colors.black,

                        fontSize: 11,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          Stack(
            children: [

              _iconButton(

                icon: Icons.people,

                color: Colors.white,

                onPressed: () {

                  _showParticipantsDialog();
                },
              ),

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

                    participantCount.toString(),

                    style: const TextStyle(

                      color: Colors.black,

                      fontSize: 11,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          _iconButton(
            icon: Icons.call_end,
            color: Colors.red,
            onPressed: endCall,
          ),
        ],
      ),
    ),
  );
}

Widget _iconButton({
  required IconData icon,
  required Color color,
  required VoidCallback? onPressed,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey.shade800,
      shape: BoxShape.circle,
    ),
    child: IconButton(
      icon: Icon(icon, color: color),
      onPressed: onPressed,
    ),
  );
}

  Widget _participantList() {

    return Positioned(

      top: 50,
      right: 20,

      child: Container(

        width: 230,

        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(

          color: Colors.black54,

          borderRadius:
              BorderRadius.circular(12),
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              "Participants "
              "($participantCount)",

              style: const TextStyle(
                color: Colors.white,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ...participants.map((user) {

              return Padding(

                padding:
                    const EdgeInsets.symmetric(
                  vertical: 5,
                ),

                child: Row(

                  children: [

                    CircleAvatar(
                      radius: 16,

                      backgroundImage:

                        (user['profile_image'] != null &&
                        user['profile_image']
                              .toString()
                              .isNotEmpty)

                            ? NetworkImage(
                                user['profile_image']
                                    .toString(),
                              )

                            : null,
                    ),

                    const SizedBox(width: 10),

                    Expanded(

                      child: Text(

                        user['username']
                                ?.toString() ??
                            'User',

                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),

                    if (user['is_host']
                            == true)

                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),

                    const SizedBox(width: 5),

                    if (user['is_speaker']
                            == true)

                      const Icon(
                        Icons.mic,
                        color: Colors.green,
                        size: 16,
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showParticipantsDialog() {

    showModalBottomSheet(

      context: context,

      backgroundColor:
    Colors.black.withOpacity(0.45),

      builder: (_) {

        return Container(

          height: 400,

          padding: const EdgeInsets.all(16),

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(

                "Active Participants "
                "($participantCount)",

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Expanded(

                child: ListView.builder(

                  itemCount:
                      participants.length,

                  itemBuilder: (_, index) {

                    final user =
                        participants[index];

                    return ListTile(

                      leading: CircleAvatar(

                        backgroundImage:
                      
                          (user['profile_image'] != null &&
                          user['profile_image']
                                .toString()
                                .isNotEmpty)

                              ? NetworkImage(
                                  user['profile_image']
                                      .toString(),
                                )

                              : null,
                      ),

                      title: Text(

                        user['username']
                                ?.toString() ??
                            'User',

                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),

                      subtitle: Text(

                        user['is_host'] == true
                            ? "Host"
                            : user['is_speaker'] == true
                                ? "Speaker"
                                : "Listener",

                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),

                      // ✅ HOST CONTROL
                      trailing:
                          widget.isCaller &&
                                  user['is_host']
                                          !=
                                      true

                              ? IconButton(

                                  icon: Icon(

                                    user['is_speaker'] ==
                                            true

                                        ? Icons.mic

                                        : Icons.mic_off,

                                    color:
                                        Colors.white,
                                  ),

                                  onPressed: () {

                                    final allowed =
                                        !(user['is_speaker'] == true);

                                    // ✅ UPDATE UI INSTANTLY
                                    setState(() {

                                      user['is_speaker'] = allowed;
                                    });

                                    // ✅ SEND SOCKET
                                    _sendMessage({

                                      "type": "speaker_permission",

                                      "peer_id": user['peer_id'],

                                      "allowed": allowed,
                                    });
                                  },
                                )

                              : null,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatUI() {
    return Positioned(
      right: 16,
      bottom: 100,
      child: Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius:
              BorderRadius.circular(12),
        ),
        child: Column(
          children: [

            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [

                  const Text(
                    "Chat",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      setState(() {
                        isChatVisible =
                            false;
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
                  _chatScrollController,

                itemCount:
                    chatMessages.length,

                itemBuilder: (_, index) {

                  final msg =
                      chatMessages[index];

                  final isMe =

                    msg['sender_id']
                        .toString() ==

                    widget.userId
                        .toString();

                  return Align(

                    alignment:

                        isMe

                            ? Alignment.centerRight

                            : Alignment.centerLeft,

                    child: Container(

                      constraints: const BoxConstraints(
                        maxWidth: 220,
                      ),

                      margin:
                          const EdgeInsets.symmetric(
                        vertical: 4,
                      ),

                      padding:
                          const EdgeInsets.all(12),

                      decoration: BoxDecoration(

                        color:

                          isMe

                              ? Colors.green.withOpacity(0.40)

                              : getUserColor(
                                  msg['username']
                                          ?.toString() ??
                                      'User',
                                ).withOpacity(0.40),

                        borderRadius:
                            BorderRadius.circular(16),
                      ),

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          if (!isMe)

                            Text(

                              msg['username']
                                      ?.toString() ??
                                  'User',

                              style: TextStyle(

                                color: getUserColor(

                                  msg['username']
                                          ?.toString() ??
                                      'User',
                                ),

                                fontSize: 11,

                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                          if (!isMe)
                            const SizedBox(height: 4),

                          Text(

                            msg['text']
                                    ?.toString() ??
                                '',

                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),

                            Align(

                              alignment: Alignment.bottomRight,

                              child: Text(

                                msg['timestamp']
                                        ?.toString() ??
                                    '',

                                style: const TextStyle(

                                  color: Colors.white70,

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

              padding: const EdgeInsets.all(8),

              child: Row(

                children: [

                  Expanded(

                    child: TextField(

                      controller: chatController,

                      style: const TextStyle(
                        color: Colors.white,
                      ),

                      decoration: InputDecoration(

                        hintText: "Type message",

                        hintStyle:
                            const TextStyle(
                          color: Colors.white54,
                        ),

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  CircleAvatar(

                    child: IconButton(

                      icon:
                          const Icon(Icons.send),

                      onPressed:
                          _sendChatMessage,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          buildVideoLayout(),

          if (showTopMessage)

            Positioned(

              top: 60,
              left: 20,
              right: 20,

              child: Center(

                child: Container(

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),

                  decoration: BoxDecoration(

                    color: Colors.black87,

                    borderRadius:
                        BorderRadius.circular(30),
                  ),

                  child: Text(

                    topMessage,

                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          _toolbar(),

          // if (showParticipants)
          //   _participantList(),

          if (isChatVisible)
            _buildChatUI(),
        ],
      ),
    );
  }
}


































