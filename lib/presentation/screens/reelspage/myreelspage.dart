import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawlli/core/storage_manager/LocalStorageConstants.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/myreelscontroller.dart';
import 'package:pawlli/data/api service.dart';
import 'package:pawlli/presentation/screens/reelspage/followerslist.dart';
import 'package:pawlli/presentation/screens/reelspage/followingflist.dart';
import 'package:pawlli/presentation/screens/reelspage/reels.dart';
import 'package:pawlli/presentation/screens/reelspage/uploadreel.dart';

class MyReelsPage extends StatefulWidget {
  const MyReelsPage({super.key});

  @override
  State<MyReelsPage> createState() => _MyReelsPageState();
}

class _MyReelsPageState extends State<MyReelsPage> {
  final MyReelsController controller = Get.find<MyReelsController>();

  List<Map<String, dynamic>> followersList = [];
  List<Map<String, dynamic>> followingList = [];

  int followersCount = 0;
  int followingCount = 0;

  String profileImage = "";

  @override
  void initState() {
    super.initState();
    controller.fetchMyReels();
    fetchProfileData();
  }

  /// 🔥 FETCH PROFILE (BEST - SINGLE API)
  Future<void> fetchProfileData() async {
    final userId = GetStorage().read("user_id") ?? 0;

    final data = await ApiService.getUserProfile(userId);

    if (data != null) {
      setState(() {
        final image = data["user"]["profile_picture"] ?? "";

        profileImage = image.startsWith("http")
            ? image
            : "https://app.pawdli.com$image";

        print("PROFILE IMAGE URL: $profileImage");
        followersCount = data["stats"]["followers_count"];
        followingCount = data["stats"]["following_count"];
      });

      print("PROFILE IMAGE: $profileImage"); // debug
      print("USER PROFILE RESPONSE: $data");
      print("PROFILE IMAGE: ${data["user"]["profile_picture"]}");
    }

    /// also fetch full lists
    await fetchFollowers();
    await fetchFollowing();
  }

  Future<void> fetchFollowers() async {
    final userId = GetStorage().read("user_id") ?? 0;

    final data = await ApiService.getFollowers(userId);

    setState(() {
      followersList = data;
    });
  }

  Future<void> fetchFollowing() async {
    final userId = GetStorage().read("user_id") ?? 0;

    final data = await ApiService.getFollowing(userId);

    setState(() {
      followingList = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? username = LocalStorage.getUserName();

    return Scaffold(
      backgroundColor: Colors.white,

      /// 🔥 APP BAR
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Stack(
          children: [
            AppBar(
              centerTitle: true,
              title: Text(
                username ?? "User",
                style: const TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.white,
            ),

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
          ],
        ),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.myReels.isEmpty) {
          return GestureDetector(
            onTap: () async {
              final picker = ImagePicker();
              final pickedFile =
                  await picker.pickVideo(source: ImageSource.gallery);

              if (pickedFile == null) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddDetailsPage(videoFile: File(pickedFile.path)),
                ),
              );
            },
            child: SizedBox.expand(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Image.asset(
                  'assets/images/NoReels.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {

            /// REFRESH REELS
            await controller.fetchMyReels();

            /// REFRESH PROFILE
            await fetchProfileData();
          },

          child: Column(
          children: [

            /// 🔥 PROFILE HEADER
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                children: [

                  /// PROFILE 
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.transparent,
                    child: ClipOval(
                      child: profileImage.isNotEmpty
                          ? Image.network(
                              profileImage,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                print("❌ IMAGE ERROR: $profileImage");
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

                  /// STATS
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [

                        /// POSTS
                        Column(
                          children: [
                            Text(
                              controller.myReels.length.toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            const Text("Posts"),
                          ],
                        ),

                        /// FOLLOWERS
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FollowersScreen(
                                  followers: followersList,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Text(
                                followersCount.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const Text("Pawllowers"),
                            ],
                          ),
                        ),

                        /// FOLLOWING
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FollowingScreen(
                                  following: followingList,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Text(
                                followingCount.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const Text("Pawllowing"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// 🔥 REELS GRID
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(6),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.65,
                ),
                itemCount: controller.myReels.length,
                itemBuilder: (_, i) {
                  final reel = controller.myReels[i];

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => ReelsPage(
                            reels: controller.myReels,
                            startIndex: i,
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        children: [

                          Positioned.fill(
                            child: FadeInImage.assetNetwork(
                              placeholder:
                                  "assets/images/profile_avatar1.png",
                              image: reel.thumbnailUrl,
                              fit: BoxFit.cover,
                            ),
                          ),

                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.35),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),

                          /// 🔴 DELETE MENU
                          Positioned(
                            top: 8,
                            right: 8,
                            child: PopupMenuButton<String>(
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.more_vert,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),

                              onSelected: (value) async {
                                if (value == "delete") {

                                  /// CONFIRM DIALOG
                                  final confirm = await showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      return Dialog(
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          side: BorderSide(
                                            color: Colours.primarycolour,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.asset(
                                                "assets/images/DeleteReel.png", // Your delete image
                                                height: 140,
                                                fit: BoxFit.contain,
                                              ),

                                              const SizedBox(height: 15),

                                              Text(
                                                "Are you sure you want to delete this reel?".tr,
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
                                                        Navigator.pop(context, false);
                                                      },
                                                      child: Text(
                                                        "Close".tr,
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
                                                        Navigator.pop(context, true);
                                                      },
                                                      child: Text(
                                                        "Delete".tr,
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
                                      );
                                    },
                                  );

                                  if (confirm == true) {
                                    controller.deleteReel(reel.id.toString());
                                  }
                                }
                              },

                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: "delete",
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text("Delete"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _formatDuration(reel.duration),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 11),
                              ),
                            ),
                          ),

                          if (reel.likesCount > 0)
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Row(
                                children: [
                                  const Icon(Icons.favorite,
                                      color: Colors.red, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    reel.likesCount.toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          ),
        );
      }),
    );
  }
}

/// ✅ KEEP THIS
String _formatDuration(double seconds) {
  final int s = seconds.toInt();
  final int min = s ~/ 60;
  final int sec = s % 60;
  return "$min:${sec.toString().padLeft(2, '0')}";
}