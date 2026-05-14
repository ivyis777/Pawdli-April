import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pawlli/core/storage_manager/LocalStorageConstants.dart';
import 'package:pawlli/data/controller/myreelscontroller.dart';
import 'package:pawlli/data/api service.dart';
import 'package:pawlli/presentation/screens/reelspage/followerslist.dart';
import 'package:pawlli/presentation/screens/reelspage/followingflist.dart';
import 'package:pawlli/presentation/screens/reelspage/reels.dart';

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
    fetchProfileData();
  }

  /// 🔥 FETCH PROFILE (BEST - SINGLE API)
  Future<void> fetchProfileData() async {
    final userId = GetStorage().read("user_id") ?? 0;

    final data = await ApiService.getUserProfile(userId);

    if (data != null) {
      setState(() {
        profileImage = data["user"]["profile_picture"] ?? "";
        followersCount = data["stats"]["followers_count"];
        followingCount = data["stats"]["following_count"];
      });

      print("PROFILE IMAGE: $profileImage"); // debug
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
                      'https://pawlli-podcasts.s3.ap-south-1.amazonaws.com/static_images/topimage.png',
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
          return Center(
            child: Text("No reels found".tr),
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

                  /// PROFILE IMAGE
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
                                    Colors.black.withOpacity(0.35),
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
                                  color: Colors.black.withOpacity(0.4),
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
                                    builder: (_) => AlertDialog(
                                      title: const Text("Delete Reel"),
                                      content: const Text(
                                        "Are you sure you want to delete this reel?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          },
                                          child: const Text("Cancel"),
                                        ),

                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, true);
                                          },
                                          child: const Text(
                                            "Delete",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
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
                                color: Colors.black.withOpacity(0.6),
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