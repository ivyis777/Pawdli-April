import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/app%20url.dart';
import 'package:pawlli/presentation/screens/loginpage/loginpage.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

double getResponsiveFont(BuildContext context, double size) {
  double screenWidth = MediaQuery.of(context).size.width;

  if (screenWidth < 360) {
    return size * 0.85;
  } else if (screenWidth < 400) {
    return size;
  } else if (screenWidth < 600) {
    return size * 1.1;
  } else {
    return size * 1.3;
  }
}

class Chat1to1 extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String petProfileImage;
  final int petId;
  final String lastMessage;
  final bool showLastMessage;
  const Chat1to1({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.petProfileImage,
    required this.petId,
    required this.lastMessage,
    required this.showLastMessage,
  });

  @override
  State<Chat1to1> createState() => _Chat1to1State();
}

class _Chat1to1State extends State<Chat1to1> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  late WebSocketChannel _channel;
  bool isUserOnline = false;
  bool isTyping = false;
  String lastSeen = "";
  String? roomUuid;

  @override
  void initState() {
    super.initState();

    if (widget.showLastMessage && widget.lastMessage.isNotEmpty) {
      _messages.add(
        Message(
          id: "last_message",
          text: widget.lastMessage,
          sender: widget.receiverName,
          time: DateTime.now(),
          isMe: false,
        ),
      );
    }

    _initializeChat();
  }

  Future<String?> _createRoom() async {
    try {
      debugPrint("=================================");
      debugPrint("CREATE ROOM API");
      debugPrint("FROM PET : ${widget.petId}");
      debugPrint("TO PET   : ${widget.receiverId}");
      debugPrint("=================================");

      final response = await http.post(
        Uri.parse("https://websocket.pawdli.com/pet-chat/create-room"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "from_pet": widget.petId,
          "to_pet": int.parse(widget.receiverId),
        }),
      );

      debugPrint("ROOM STATUS : ${response.statusCode}");
      debugPrint("ROOM BODY   : ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        roomUuid = data["room_uuid"];

        debugPrint("ROOM UUID : $roomUuid");

        return roomUuid;
      }

      return null;
    } catch (e) {
      debugPrint("CREATE ROOM ERROR : $e");
      return null;
    }
  }

 Future<void> _initializeChat() async {
  String? accessToken = await _getAccessToken();
  if (accessToken == null) {
    print('Access token is null, redirecting or handling token expiration.');
    handleTokenExpiration();
    return;
  }
  roomUuid = await _createRoom();

  if (roomUuid == null) {
    debugPrint("ROOM UUID NOT FOUND");
    return;
  }

  final url =
      "wss://websocket.pawdli.com/ws/pet-chat/$roomUuid/";

  debugPrint("=================================");
  debugPrint("CONNECTING SOCKET");
  debugPrint("ROOM UUID : $roomUuid");
  debugPrint("URL : $url");
  debugPrint("=================================");

  try {
    try {
      _channel.sink.close();
    } catch (_) {}
    debugPrint("=================================");
    debugPrint("🚀 CONNECTING TO CHAT SOCKET");
    debugPrint("Pet ID      : ${widget.petId}");
    debugPrint("Receiver ID : ${widget.receiverId}");
    debugPrint("Token       : $accessToken");
    debugPrint("Socket URL  : $url");
    debugPrint("=================================");

    _channel = IOWebSocketChannel.connect(
        Uri.parse(url),
        headers: {
            "Authorization":"Bearer $accessToken"
        },
    );

    debugPrint("Socket hashCode : ${_channel.hashCode}");

    _channel.stream.handleError((e) {
      debugPrint("STREAM ERROR : $e");
    });
    debugPrint("✅ Socket object created");


    debugPrint("STARTING SOCKET LISTENER");
    _channel.stream.listen(
      (message) {
      debugPrint("🔥 SOCKET EVENT RECEIVED 🔥");
      debugPrint("################################");
      debugPrint("SERVER SENT");
      debugPrint(message.runtimeType.toString());
      debugPrint(message.toString());
      debugPrint("################################");

      _handleIncomingMessage(message);
    },
      onDone: () {
        debugPrint("SOCKET CLOSED BY SERVER");
        debugPrint("=================================");
        debugPrint("❌ SOCKET CLOSED");
        debugPrint("=================================");
        _reconnectWebSocket();
      },
      onError: (error) {
        debugPrint("SOCKET ERROR CALLBACK");
        debugPrint("=================================");
        debugPrint("🔥 SOCKET ERROR");
        debugPrint(error.toString());
        debugPrint("=================================");
        _reconnectWebSocket();
      },
      cancelOnError: true,
    );
  } catch (e) {
    debugPrint('Failed to connect WebSocket: $e');
    _reconnectWebSocket();
  }
}

void _handleIncomingMessage(dynamic message) {
  debugPrint("=================================");
  debugPrint("📥 RAW MESSAGE");
  debugPrint(message.toString());
  debugPrint("=================================");

  try {
    final decoded = jsonDecode(message);

    debugPrint("=================================");
    debugPrint("DECODED SOCKET DATA");
    debugPrint(decoded.toString());
    debugPrint("Current Room : $roomUuid");
    debugPrint("Message      : ${decoded["message"]}");
    debugPrint("Timestamp    : ${decoded["timestamp"]}");
    debugPrint("Delivered    : ${decoded["delivered"]}");
    debugPrint("Seen         : ${decoded["seen"]}");
    debugPrint("Room UUID    : ${decoded["room_uuid"]}");
    debugPrint("=================================");

    // Message Delivered
    if (decoded["type"] == "delivered") {
      final index = _messages.indexWhere(
        (m) => m.id == decoded["id"],
      );
      if (index != -1) {
        _messages[index].delivered = true;
        setState(() {});
      }
      return;
    }

    // Message Seen
    if (decoded["type"] == "seen") {
      final index = _messages.indexWhere(
        (m) => m.id == decoded["id"],
      );
      if (index != -1) {
        _messages[index].seen = true;
        setState(() {});
      }
      return;
    }

    debugPrint("Decoded JSON:");
    debugPrint(decoded.toString());

    if (decoded["type"] == "presence") {
      setState(() {
        isUserOnline = decoded["online"];
        if (!isUserOnline) {
          lastSeen = DateFormat(
            'dd MMM hh:mm a',
          ).format(
            DateTime.parse(decoded["last_seen"]),
          );
        }
      });
      return;
    }
    if (decoded["type"] == "typing") {
      setState(() {
        isTyping = decoded["typing"];
      });
      return;
    }
    
    debugPrint("=================================");
    debugPrint("ADDING MESSAGE TO CHAT UI");
    debugPrint("Receiver : ${widget.receiverName}");
    debugPrint("Room UUID : $roomUuid");
    debugPrint("Incoming Room : ${decoded["room_uuid"]}");
    debugPrint("=================================");


    if (decoded["room_uuid"] != null &&
        roomUuid != null &&
        decoded["room_uuid"] != roomUuid) {

      debugPrint("#################################");
      debugPrint("ROOM UUID MISMATCH");
      debugPrint("Current Room : $roomUuid");
      debugPrint("Incoming Room: ${decoded["room_uuid"]}");
      debugPrint("Ignoring this message");
      debugPrint("#################################");

      return;
    }

    setState(() {
      final bool isMyMessage = decoded["from_pet"] == widget.petId;
      if (isMyMessage) {
        debugPrint("Ignoring echoed message from myself");
        return;
      }

      debugPrint("=================================");
      debugPrint("FROM PET : ${decoded["from_pet"]}");
      debugPrint("TO PET   : ${decoded["to_pet"]}");
      debugPrint("MY PET   : ${widget.petId}");
      debugPrint("IS ME    : $isMyMessage");
      debugPrint("=================================");

      if (_messages.length == 1 &&
          _messages.first.id == "last_message") {
        _messages.clear();
      }

      _messages.add(
        Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: decoded["message"] ?? "",
          sender: isMyMessage ? "You" : widget.receiverName,
          time: DateTime.parse(decoded["timestamp"]),
          isMe: isMyMessage,
          delivered: decoded["delivered"] ?? false,
          seen: decoded["seen"] ?? false,
        ),
      );
    });
    debugPrint("✅ Message added successfully");
    debugPrint("Total messages : ${_messages.length}");
  } catch (e) {
    debugPrint('Error decoding message: $e');
  }
}

// Reconnect logic with delay
void _reconnectWebSocket() {
  debugPrint("Reconnecting after 3 seconds...");
  Future.delayed(const Duration(seconds: 3), () {
    if (mounted) _initializeChat();
  });
}

  static void handleTokenExpiration() {
    final box = GetStorage();
    box.remove(LocalStorageConstants.access);
    box.remove(LocalStorageConstants.refresh);

    print("User must re-login. Redirecting to LoginPage...");
    Get.offAll(LoginPage()); // Replace with actual login page
  }

  @override
  void dispose() {
    debugPrint("Closing Chat Socket");
    _channel.sink.close();
    super.dispose();
  }

 Future<void> _sendMessage() async {
  if (_messageController.text.trim().isEmpty) return;

  final message = _messageController.text;
  final messageId =
      DateTime.now().millisecondsSinceEpoch.toString();

  final payload = {
    "from_pet": widget.petId,
    "to_pet": int.parse(widget.receiverId),
    "message": message,
    "token": await _getAccessToken(),
  };

  final messageJson = jsonEncode(payload);

  debugPrint("=================================");
  debugPrint("📤 SENDING MESSAGE");
  debugPrint("ROOM UUID : $roomUuid");
  debugPrint("FROM PET  : ${widget.petId}");
  debugPrint("TO PET    : ${widget.receiverId}");
  debugPrint("PAYLOAD   : $messageJson");
  debugPrint("=================================");
  
  try {
    debugPrint("➡️ Writing message to socket...");
    _channel.sink.add(messageJson);
    debugPrint("✅ Message written successfully");
  } catch (e) {
    debugPrint("Socket write failed : $e");
  }
  debugPrint("✅ Message sent to socket");

  setState(() {
    debugPrint("Adding MY message to UI");
    _messages.add(
      Message(
        id:messageId,
        text: message,
        sender: 'You',
        time: DateTime.now(),
        isMe: true,  
      ),
    );
    _messageController.clear();
  });
  debugPrint("Total messages : ${_messages.length}");
}

  Future<String?> _getAccessToken() async {
    final box = GetStorage();
    var accessToken = box.read(LocalStorageConstants.access);
    debugPrint("Access Token : $accessToken");

    if (accessToken == null) {
      print("Access token missing, attempting refresh...");
      accessToken = await refreshToken();

      if (accessToken == null) {
        handleTokenExpiration();
      }
    }

    return accessToken;
  }

  static Future<String?> refreshToken() async {
    final box = GetStorage();
    var refreshToken = box.read(LocalStorageConstants.refresh);

    if (refreshToken == null) {
      print("No refresh token found. Logging out user.");
      handleTokenExpiration();
      return null;
    }

    try {
      debugPrint("Refreshing Access Token...");
      var response = await http.post(
        Uri.parse(AppUrl.RefershTokenURL),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"refresh": refreshToken}),
      );

      print('Refresh token response status: ${response.statusCode}');
      print('Refresh token response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey('access') && jsonResponse.containsKey('refresh')) {
          String newAccessToken = jsonResponse['access'];
          String newRefreshToken = jsonResponse['refresh'];

          // Save the new tokens
          box.write(LocalStorageConstants.access, newAccessToken);
          box.write(LocalStorageConstants.refresh, newRefreshToken);

          return newAccessToken;
        }
      } else {
        // Explicitly check for token blacklist or invalid token errors
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('error') && jsonResponse['error'] == "Invalid token") {
          print("Refresh token is blacklisted or invalid. Logging out user.");
          handleTokenExpiration();
        } else {
          print("Failed to refresh token. Server response: ${response.body}");
        }
      }
    } catch (e) {
      print('Error while refreshing token: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
      String imageUrl = '${widget.petProfileImage}';
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
          Center(
            child:CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey[200],
              backgroundImage: widget.petProfileImage.isNotEmpty
                  ? CachedNetworkImageProvider(widget.petProfileImage)
                  : null,
              child: widget.petProfileImage.isEmpty
                  ? const Icon(Icons.pets, color: Colors.brown, size: 28)
                  : null,
            )
           ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverName,
                  style: TextStyle(
                    fontSize: getResponsiveFont(context, 15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isTyping
                      ? "Typing..."
                      : isUserOnline
                          ? "Online"
                          : "Last seen $lastSeen",
                  style: TextStyle(
                    fontSize: getResponsiveFont(context, 11),
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ],
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.more_vert),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return MessageBubble(message: message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          // IconButton(
          //   icon: const Icon(Icons.add),
          //   onPressed: () {},
          // ),
          Expanded(
            child: TextField(
              controller: _messageController,
              onChanged: (value) {
                  _channel.sink.add(jsonEncode({
                    "type":"typing",
                    "to":widget.receiverId,
                    "typing":value.isNotEmpty
                  }));
                },
              style: TextStyle(
                fontSize: getResponsiveFont(context, 14),
              ),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(
                  fontSize: getResponsiveFont(context, 13),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: Theme.of(context).primaryColor,
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class Message {
  final String id;
  final String text;
  final String sender;
  final DateTime time;
  final bool isMe;
  bool delivered;
  bool seen;
  Message({
    required this.id,
    required this.text,
    required this.sender,
    required this.time,
    required this.isMe,
    this.delivered = false,
    this.seen = false,
  });
}
class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    Widget statusWidget() {
      if (!message.isMe) {
        return const SizedBox();
      }
      if (message.seen) {
        return const Icon(
          Icons.done_all,
          color: Colors.blue,
          size: 16,
        );
      }
      if (message.delivered) {
        return const Icon(
          Icons.done_all,
          color: Colors.grey,
          size: 16,
        );
      }
      return const Icon(
        Icons.done,
        color: Colors.grey,
        size: 16,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!message.isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.sender,
                  style: TextStyle(
                    fontSize: getResponsiveFont(context, 11),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isMe
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: message.isMe
                      ? const Radius.circular(20)
                      : const Radius.circular(0),
                  bottomRight: message.isMe
                      ? const Radius.circular(0)
                      : const Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: getResponsiveFont(context, 14),
                      color: message.isMe ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('h:mm a').format(message.time),
                        style: TextStyle(
                          fontSize: getResponsiveFont(context, 10),
                          color: Colors.grey,
                        ),
                      ),
                      if (message.isMe) ...[
                        const SizedBox(width: 8),
                        statusWidget()
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
