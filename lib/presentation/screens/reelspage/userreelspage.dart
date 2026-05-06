import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
// import 'package:pawlli/core/storage_manager/LocalStorageConstants.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/reelitemmodel.dart';
import 'package:pawlli/presentation/screens/reelspage/followerslist.dart';
import 'package:pawlli/presentation/screens/reelspage/followingflist.dart';
import 'package:pawlli/presentation/screens/reelspage/reels.dart';
import 'package:pawlli/presentation/screens/reelspage/savereel.dart';

class UserReelsPage extends StatefulWidget {
  final String username;
  final int userId;   

  const UserReelsPage({super.key, required this.username, required this.userId,});

  @override
  State<UserReelsPage> createState() => _UserReelsPageState();
}

class _UserReelsPageState extends State<UserReelsPage> {
  bool isLoading = true;
  List<ReelItem> reels = [];

  int followersCount = 0;
  int followingCount = 0;
  int postsCount = 0;
  List<Map<String, dynamic>> followersList = [];
  List<Map<String, dynamic>> followingList = [];

  /// 👉 TEMP PROFILE IMAGE (replace with API later)
  
  String? profileImage;
  // String profileImage =
  //     "https://i.pravatar.cc/150?img=3";

  bool isFollowing = false;

  String fixImage(String? url) {
  if (url == null || url.isEmpty) return "";

  // ✅ ONLY decode, do NOT modify URL
  return Uri.decodeFull(url);
}

  String formatDuration(double seconds) {
    final d = Duration(seconds: seconds.round());
    final minutes = d.inMinutes;
    final secs = d.inSeconds % 60;
    return "$minutes:${secs.toString().padLeft(2, '0')}";
  }

  @override
    void initState() {
      super.initState();
      initData();
    }

    Future<void> initData() async {
      await fetchUserProfile(); 
      await fetchUserReels();    
      await fetchFollowers();
      await fetchFollowing();


      print("STORED IMAGE: $profileImage");

    }

  Future<void> fetchUserReels() async {
    try {
      final token = GetStorage().read("access") ?? "";

      final url =
          "https://app.pawdli.com/user/short_video/search?username=${widget.username}";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;

        setState(() {
          reels = data.map((e) {
            final reel = ReelItem.fromJson(e);

            // 🔥 ADD THIS LINE HERE
            print("PROFILE IMAGE BEFORE INJECT: $profileImage");

            // 🔥 inject profile image
            reel.userProfilePic = GetStorage().read("profile_picture") ?? "";

            return reel;
          }).toList();

          postsCount = reels.length;
        

          isLoading = false;
        });
      } else {
        isLoading = false;
      }
    } catch (e) {
      debugPrint("USER REELS ERROR: $e");
      isLoading = false;
    }
  }

    Future<void> fetchFollowers() async {
      followersList = await ApiService.getFollowers(widget.userId);
      setState(() {});
    }

    // Future<void> fetchFollowers() async {
    //   final token = GetStorage().read("access") ?? "";
    //   final userId = widget.userId;

    //   final response = await http.get(
    //     Uri.parse("https://app.pawdli.com/user/followers/$userId/"),
    //     headers: {
    //       "Authorization": "Bearer $token",
    //     },
    //   );

    //   print("FOLLOWERS RESPONSE: ${response.body}");
    //   print("FOLLOWERS USER ID: $userId");

    //   if (response.statusCode == 200) {
    //     followersList = List<Map<String, dynamic>>.from(jsonDecode(response.body));
    //     setState(() {});
    //   }
    // }

    Future<void> fetchFollowing() async {
      followingList = await ApiService.getFollowing(widget.userId);
      setState(() {});
    }



    // Future<void> fetchFollowing() async {
    //   final token = GetStorage().read("access") ?? "";
    //   final userId = widget.userId;

    //   final response = await http.get(
    //     Uri.parse("https://app.pawdli.com/user/following/$userId/"),
    //     headers: {
    //       "Authorization": "Bearer $token",
    //     },
    //   );

    //   print("FOLLOWING USER ID: $userId");

    //   if (response.statusCode == 200) {
    //     followingList = List<Map<String, dynamic>>.from(jsonDecode(response.body));
    //     setState(() {});
    //   }
    // }

  Widget _buildStat(String count, String label) {
  return Column(
    children: [
      Text(
        count,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}

  Future<void> toggleFollow() async {
    final newState = await ApiService.toggleFollow(
      widget.userId,
      isFollowing,
    );

    setState(() {
      isFollowing = newState;
    });

    /// refresh counts
    await fetchUserProfile();
    await fetchFollowers();
    await fetchFollowing();
  }

  // Future<void> toggleFollow() async {
  //   final token = GetStorage().read("access") ?? "";
  //   final Id = widget.userId;// ⚠️ target user id later

  //   final response = await http.post(
  //     Uri.parse("https://app.pawdli.com/user/follow/$Id/"),
  //     headers: {
  //       "Authorization": "Bearer $token",
  //       "Content-Type": "application/json",
  //     },
  //   );

  //   print("FOLLOW RAW RESPONSE: ${response.body}"); 

  //   if (response.statusCode == 200) {

  //     final Map<String, dynamic> data = jsonDecode(response.body);

  //     print("FOLLOW RESPONSE: ${response.body}");

  //     setState(() {
  //       isFollowing = !(isFollowing); // 🔥 toggle manually
  //     });

  //     /// 🔥 refresh profile counts
  //     await fetchUserProfile();
  //     await fetchFollowers();
  //     await fetchFollowing();
  //   }
  // }

  Future<void> fetchUserProfile() async {
  final data = await ApiService.getUserProfile(widget.userId);

  if (data != null) {
    setState(() {
      profileImage = data["user"]["profile_picture"];
      GetStorage().write("profile_picture", profileImage);

      isFollowing = data["user"]["is_following"];

      followersCount = data["stats"]["followers_count"];
      followingCount = data["stats"]["following_count"];
      postsCount = data["stats"]["posts_count"];
    });

    print("PROFILE API RESPONSE IMAGE: ${data["user"]["profile_picture"]}");

  }
}

  /// ✅ REEL ITEM UI
  Widget buildReelItem(ReelItem reel) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          /// THUMBNAIL
          Positioned.fill(
            child: FadeInImage.assetNetwork(
              placeholder: "assets/images/profile_avatar1.png",
              image: reel.thumbnailUrl,
              fit: BoxFit.cover,
            ),
          ),

          /// GRADIENT
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

          /// DURATION
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                formatDuration(reel.duration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          /// SAVE OPTION
          Positioned(
            top: 6,
            right: 6,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) async {
                if (value == 'save'.tr) {
                  await ReelSaveHelper.save(context, reel.videoUrl);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'save'.tr,
                  child: Row(
                    children: [
                      Icon(Icons.download, size: 18),
                      SizedBox(width: 8),
                      Text("Save".tr),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// CAPTION
          if (reel.caption.isNotEmpty)
            Positioned(
              bottom: 36,
              left: 8,
              right: 8,
              child: Text(
                reel.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          /// LIKE COUNT
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
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// APP BAR
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Stack(
          children: [

            /// 🔥 TOP IMAGE (YOUR IMAGE)
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

            /// 🔥 APP BAR ON TOP
            AppBar(
              centerTitle: true,
              title: Text(
                widget.username,
                style: const TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
            ),
          ],
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// ✅ PROFILE HEADER
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Column(
                    children: [

                      /// 🔥 TOP ROW (IMAGE + STATS)
                      Row(
                        children: [
                          /// PROFILE IMAGE
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.transparent,
                            child: ClipOval(
                              child: profileImage != null && profileImage!.isNotEmpty
                                  ? Image.network(
                                      profileImage ?? "",
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) {
                                        print("❌ IMAGE LOAD FAILED: $profileImage");
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
                                _buildStat(postsCount.toString(), "Posts"),
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
                                  child: _buildStat(followersCount.toString(), "Pawllowers"),
                                ),
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
                                  child: _buildStat(followingCount.toString(), "Pawllowing"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // /// USERNAME
                      // Text(
                      //   widget.username,
                      //   style: const TextStyle(
                      //     fontSize: 16,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),

                      // const SizedBox(height: 10),

                      /// FOLLOW BUTTON
                      GestureDetector(
                        onTap: () async {
                          print("BUTTON CLICKED");  
                          await toggleFollow();     
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                          decoration: BoxDecoration(
                            color: isFollowing ? Colours.brownColour : Colours.primarycolour,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: Text(
                              isFollowing ? "Pawllowing" : "Pawllow",
                              key: ValueKey(isFollowing),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// ✅ GRID
                Expanded(
                  child: reels.isEmpty
                      ? Center(
                          child: Text("No reels found".tr),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(6),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 0.65,
                          ),
                          itemCount: reels.length,
                          itemBuilder: (_, i) {
                            final reel = reels[i];

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ReelsPage(
                                      reels: reels,
                                      startIndex: i,
                                    ),
                                  ),
                                );
                              },
                              child: buildReelItem(reel),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}