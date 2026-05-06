import 'package:flutter/material.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/api service.dart';
import 'package:pawlli/presentation/screens/reelspage/userreelspage.dart';

class FollowersScreen extends StatefulWidget {
  final List<Map<String, dynamic>> followers;

  const FollowersScreen({super.key, required this.followers});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  late List<Map<String, dynamic>> users;

  @override
  void initState() {
    super.initState();

    /// ✅ Initialize users list
    users = widget.followers.map((u) {
      u["is_following"] = u["is_following"] ?? false;
      return u;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.55,
                height: MediaQuery.of(context).size.height * 0.10,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://pawlli-podcasts.s3.ap-south-1.amazonaws.com/static_images/topimage.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            AppBar(
              title: Text(
                "Pawllowers",
                style: TextStyle(
                  color: Colours.brownColour,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
            ),
          ],
        ),
      ),

      body: users.isEmpty
          ? const Center(child: Text("No Pawllowers"))
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                final imageUrl =
                    user["profile_picture"] ?? user["image"] ?? "";

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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

                  /// 🔥 PROFILE IMAGE (FIXED)
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.transparent,
                    child: ClipOval(
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                print("❌ IMAGE ERROR: $imageUrl");
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

                  /// 🔥 USERNAME
                  title: Text(
                    user["username"] ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  /// 🔥 FOLLOW BUTTON
                  trailing: GestureDetector(
                    onTap: () async {
                      final userId = user["id"];

                      final newState = await ApiService.toggleFollow(
                        userId,
                        user["is_following"] ?? false,
                      );

                      setState(() {
                        users[index]["is_following"] = newState;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: (user["is_following"] ?? false)
                            ? Colours.brownColour
                            : Colours.primarycolour,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          (user["is_following"] ?? false)
                              ? "Pawllowing"
                              : "Pawllow",
                          key: ValueKey(user["is_following"]),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}