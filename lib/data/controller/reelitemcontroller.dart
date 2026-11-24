import 'package:get/get.dart';
import 'package:pawlli/core/auth/authservice.dart';
import 'package:pawlli/data/api service.dart';
import 'package:pawlli/data/model/reelitemmodel.dart';


class ReelsController extends GetxController {
  var reels = <ReelItem>[].obs;
  var isLoading = false.obs;
  var page = 1;
  var hasMore = true.obs;

  @override
  void onReady() {
    super.onReady();
    fetchReels(limit: 15);
  }

  Future<void> fetchReels({
    bool loadMore = false,
    int limit = 15,
  }) async {
    if (isLoading.value || !hasMore.value) return;

    try {
      isLoading.value = true;

      final ok = await AuthService.refreshTokenIfNeeded();
      if (!ok) return;

      final newReels = await ApiService.fetchReels(
        limit: limit,
        page: page,
      );

      // Fetch profile details in parallel instead of sequentially.
      await Future.wait(
        newReels.map((reel) async {
          try {
            final profileData =
                await ApiService.getUserProfile(reel.userId);

            if (profileData != null) {
              final user = profileData["user"];

              reel.username =
                  user["username"] ?? reel.username;

              final pic = user["profile_picture"] ?? "";

              reel.userProfilePic = pic.startsWith("http")
                  ? pic
                  : "https://app.pawdli.com$pic";
            }
          } catch (e) {
            print("Profile fetch error: $e");
          }
        }),
      );

      if (newReels.isEmpty) {
        hasMore.value = false;
      } else {
        if (loadMore) {
          reels.addAll(newReels);
        } else {
          reels.assignAll(newReels);
        }

        page++;

        // If API returned fewer records than requested,
        // there may be no more pages.
        if (newReels.length < limit) {
          hasMore.value = false;
        }
      }

      print("FETCHED REELS: ${newReels.length}");
      print("TOTAL REELS: ${reels.length}");
    } catch (e) {
      print("FETCH REELS ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void removeReelById(String videoId) {
    reels.removeWhere((e) => e.id == videoId);
  }

  Future<void> refreshReels() async {
    page = 1;
    hasMore.value = true;
    reels.clear();

    await fetchReels(limit: 15);
  }

  // Call this when the user opens the full Reels page.
  Future<void> loadMoreReels() async {
    await fetchReels(
      loadMore: true,
      limit: 20,
    );
  }
}

