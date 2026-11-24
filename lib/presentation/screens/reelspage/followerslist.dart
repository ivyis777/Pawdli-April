import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:pawlli/core/storage_manager/LocalStorageConstants.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/api service.dart';
import 'package:pawlli/presentation/screens/loginpage/loginpage.dart';
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
      backgroundColor: Colors.white,
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
                      'https://app.pawdli.com/media/static/topimage.png',
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
                print("USER DATA: $user");

                String imageUrl =
                    user["profile_picture"] ?? user["image"] ?? "";

                if (imageUrl.isNotEmpty && !imageUrl.startsWith("http")) {
                  imageUrl = "https://app.pawdli.com$imageUrl";
                }

                print("FINAL IMAGE URL: $imageUrl");
                    // print("IMAGE URL: $imageUrl");

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
                      // ✅ GUEST CHECK
                      if (LocalStorage.isGuest()) {
                        Get.dialog(
                          Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: Colours.primarycolour,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    "assets/images/LoginRequired.png", // Your image
                                    height: 140,
                                    fit: BoxFit.contain,
                                  ),

                                  const SizedBox(height: 15),

                                  // Text(
                                  //   "Login Required".tr,
                                  //   textAlign: TextAlign.center,
                                  //   style: const TextStyle(
                                  //     fontSize: 22,
                                  //     fontWeight: FontWeight.bold,
                                  //   ),
                                  // ),

                                  const SizedBox(height: 10),

                                  Text(
                                    "Please login to continue.".tr,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                              color: Colours.primarycolour,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                          ),
                                          onPressed: () {
                                            Get.back();
                                          },
                                          child: Text(
                                            "Cancel".tr,
                                            style: TextStyle(
                                              color: Colours.primarycolour,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colours.primarycolour,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                          ),
                                          onPressed: () {
                                            Get.back();
                                            Get.offAll(() => LoginPage());
                                          },
                                          child: Text(
                                            "Login".tr,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                        return;
                      }

                      // ✅ EXISTING CODE
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