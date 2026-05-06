class UserProfile {
  final int id;
  final String username;
  final String profilePicture;
  final int followersCount;
  final int followingCount;
  bool isFollowing;

  UserProfile({
    required this.id,
    required this.username,
    required this.profilePicture,
    required this.followersCount,
    required this.followingCount,
    required this.isFollowing,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json["user"]["id"],
      username: json["user"]["username"],
      profilePicture: json["user"]["profile_picture"] ?? "",
      followersCount: json["stats"]["followers_count"] ?? 0,
      followingCount: json["stats"]["following_count"] ?? 0,
      isFollowing: json["user"]["is_following"] ?? false,
    );
  }
}