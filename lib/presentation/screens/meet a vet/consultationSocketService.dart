import 'dart:convert';
import 'dart:ui';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/io.dart';

class ConsultationSocketService {

  IOWebSocketChannel? socket;

  VoidCallback? onCallEnded;

  RTCPeerConnection? peerConnection;

  MediaStream? localStream;

  final RTCVideoRenderer localRenderer =
      RTCVideoRenderer();

  final RTCVideoRenderer remoteRenderer =
      RTCVideoRenderer();

  Future initialize() async {

    await localRenderer.initialize();

    await remoteRenderer.initialize();

    localStream =
        await navigator.mediaDevices
            .getUserMedia({

        

      'audio': true,

      'video': {
        'facingMode': 'user',
      },
    });

    

    localRenderer.srcObject =
        localStream;

        print("================================");
        print("LOCAL STREAM CREATED");
        print("VIDEO TRACK COUNT : ${localStream?.getVideoTracks().length}");
        print("AUDIO TRACK COUNT : ${localStream?.getAudioTracks().length}");
        print("LOCAL RENDERER SET : ${localRenderer.srcObject != null}");
        print("================================");

    peerConnection =
        await createPeerConnection({

      'iceServers': [

        {
          'urls': [
            'stun:stun.l.google.com:19302',
          ]
        }
      ]
    });

    peerConnection!.onConnectionState =
    (state) async {

      print(
          "CONNECTION STATE : $state");

      if (state ==
          RTCPeerConnectionState
              .RTCPeerConnectionStateConnected) {

        print("WEBRTC CONNECTED SUCCESSFULLY");
        await Helper.setSpeakerphoneOn(true);
      }
    };

    peerConnection!.onIceConnectionState =
        (state) {

      print(
          "ICE STATE : $state");
    };

    for (var track
        in localStream!.getTracks()) {

      print("ADDING TRACK : ${track.kind}");

      peerConnection!.addTrack(
        track,
        localStream!,
      );
    }

    peerConnection!.onTrack =
        (RTCTrackEvent event) {

      print("================================");
      print("ON TRACK FIRED");
      print("TRACK KIND : ${event.track.kind}");
      print("STREAM COUNT : ${event.streams.length}");
      print("================================");

      if (event.streams.isNotEmpty) {

        print(
            "REMOTE STREAM RECEIVED");

        remoteRenderer.srcObject =
            event.streams.first;

        print(
          "REMOTE RENDERER SET : "
          "${remoteRenderer.srcObject != null}",
        );

        print(
            "REMOTE VIDEO ATTACHED");
      }
    };

    peerConnection!.onIceCandidate =
        (candidate) {

      print("SENDING ICE");
      print(candidate.toMap());

      socket?.sink.add(
        jsonEncode({

          "type":
          "ice_candidate",

          "candidate":
          candidate.toMap(),
        }),
      );
    };
  }

  Future connect(
      String websocketUrl,
      bool isDoctor,
      ) async {

      print("CONNECT METHOD ENTERED");

      print("================================");
      print("CONNECT METHOD CALLED");
      print("WEBSOCKET URL : $websocketUrl");
      print("IS DOCTOR : $isDoctor");
      print("================================");

    socket =
        IOWebSocketChannel.connect(
      Uri.parse(websocketUrl),
    );

    print("SOCKET CREATED");

    print(
        "SOCKET URL : $websocketUrl");

    print(
        "IS DOCTOR : $isDoctor");

    socket!.stream.listen(

    (message) async {

      print("================================");
      print("RAW SOCKET MESSAGE");
      print(message);
      print("================================");

      final data = jsonDecode(message);

      print("MESSAGE TYPE : ${data['type']}");

        switch (data['type']) {

          case "joined":

            print("JOINED EVENT");
            print(data);

            if (isDoctor &&
                data["peers"] != null &&
                data["peers"].isNotEmpty) {

              print("PATIENT ALREADY IN ROOM");
              print("DOCTOR CREATING OFFER");

              final offer =
                  await peerConnection!.createOffer();

              await peerConnection!
                  .setLocalDescription(offer);

              socket?.sink.add(
                jsonEncode({
                  "type": "offer",
                  "sdp": offer.sdp,
                }),
              );

              print("OFFER SENT FROM JOINED");
            }

            break;

          case "peer_joined":

            print("================================");
            print("PEER JOINED EVENT");
            print(data);
            print("IS DOCTOR => $isDoctor");
            print("================================");

            if (isDoctor) {

              print("DOCTOR CREATING OFFER AFTER PEER JOINED");

              final offer =
                  await peerConnection!.createOffer();

              print("OFFER CREATED");

              await peerConnection!
                  .setLocalDescription(offer);

              socket?.sink.add(
                jsonEncode({
                  "type": "offer",
                  "sdp": offer.sdp,
                }),
              );

              print("OFFER SENT AFTER PEER JOINED");
            }

            break;

          case "offer":

            print("================================");
            print("RECEIVED OFFER");
            print("USER RECEIVED OFFER");
            print(data['sdp']);
            print("================================");

            await peerConnection!
                .setRemoteDescription(

              RTCSessionDescription(
                data['sdp'],
                "offer",
              ),
            );

            final answer =
            await peerConnection!
                .createAnswer();

            await peerConnection!
                .setLocalDescription(
                answer);

            socket?.sink.add(
              jsonEncode({

                "type": "answer",

                "sdp": answer.sdp,
              }),
            );

            break;

          case "answer":

            print("================================");
            print("RECEIVED ANSWER");
            print("DOCTOR RECEIVED ANSWER");
            print(data['sdp']);
            print("================================");

            await peerConnection!
                .setRemoteDescription(

              RTCSessionDescription(
                data['sdp'],
                "answer",
              ),
            );

            break;

          case "ice_candidate":

            print("================================");
            print("RECEIVED ICE");
            print(data['candidate']);
            print("================================");

            await peerConnection!
                .addCandidate(

              RTCIceCandidate(

                data['candidate']['candidate'],

                data['candidate']['sdpMid'],

                data['candidate']['sdpMLineIndex'],
              ),
            );

            break;

            case "call_ended":

              print("CALL ENDED RECEIVED");

              onCallEnded?.call();

              break;
        }
      },
    );

    // if (isDoctor) {

    // print("================================");
    // print("CREATING OFFER");

    // final offer =
    //     await peerConnection!.createOffer();

    // print("OFFER CREATED");
    // print(offer.sdp);

    // print("================================");

    //   await peerConnection!
    //       .setLocalDescription(
    //       offer);

    //   socket?.sink.add(
    //     jsonEncode({

    //       "type": "offer",

    //       "sdp": offer.sdp,
    //     }),
    //   );

    //   print("OFFER SENT TO SERVER");
    // }
  }

  Future dispose() async {

    await peerConnection?.close();

    await localStream?.dispose();

    await localRenderer.dispose();

    await remoteRenderer.dispose();

    await socket?.sink.close();
  }
}