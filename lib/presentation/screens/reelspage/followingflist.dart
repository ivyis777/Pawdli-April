import 'package:flutter/material.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/presentation/screens/reelspage/userreelspage.dart';

class FollowingScreen extends StatefulWidget {
  final List<Map<String, dynamic>> following;

  const FollowingScreen({super.key, required this.following});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  late List<Map<String, dynamic>> users;


    String fixImage(String? url) {
      if (url == null || url.isEmpty) return "";

      /// Step 1: decode %3A → :
      String decoded = Uri.decodeFull(url);

      /// Step 2: remove wrong prefix
      decoded = decoded.replaceAll("http://app.pawdli.com/", "");

      return decoded;
    }

  @override
  void initState() {
    super.initState();
    users = widget.following;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Stack(
          children: [

            /// 🔥 TOP IMAGE
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.55,
                height: MediaQuery.of(context).size.height * 0.10,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://app.pawdli.com/media/static/topimage.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            /// 🔥 APP BAR
            AppBar(
              title: Text(
                "Pawllowing",
                style: TextStyle(color: Colours.brownColour),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];

          String imageUrl =
            user["profile_picture"] ?? user["image"] ?? "";

          if (imageUrl.isNotEmpty && !imageUrl.startsWith("http")) {
            imageUrl = "https://app.pawdli.com$imageUrl";
          }

          print("FOLLOWING IMAGE: $imageUrl");

          return ListTile(
            onTap: () {
              final userId = user["id"];
              final username = user["username"];

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserReelsPage(
                    userId: userId,
                    username: username,
                  ),
                ),
              );
            },
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.transparent,
              child: ClipOval(
                child: (user["profile_picture"] != null &&
                        user["profile_picture"].toString().isNotEmpty)
                    ? Image.network(
                        imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print("❌ IMAGE URL: $imageUrl");
                          print("❌ IMAGE ERROR: $error");

                          return Image.asset(
                            "assets/images/profile_avatar1.png",
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        "assets/images/profile_avatar1.png",
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            title: Text(user["username"] ?? ""),

            trailing: GestureDetector(
              onTap: () async {
                final userId = users[index]["id"];

                final newState = await ApiService.toggleFollow(
                  userId,
                  users[index]["is_following"] ?? false,
                );

                setState(() {
                  users[index]["is_following"] = newState;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: (user["is_following"] ?? false)
                      ? Colours.brownColour
                      : Colours.primarycolour,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (user["is_following"] ?? false)
                      ? "Pawllowing"
                      : "Pawllow",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
