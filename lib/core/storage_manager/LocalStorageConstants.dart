import 'package:get_storage/get_storage.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';

class LocalStorage {
  static final GetStorage _box = GetStorage();

  // ================= AUTH TOKENS =================

  static void saveTokens(String access, String refresh) {
    _box.write(LocalStorageConstants.access, access);
    _box.write(LocalStorageConstants.refresh, refresh);
  }

  static String? getAccessToken() {
    return _box.read(LocalStorageConstants.access);
  }

  static String? getRefreshToken() {
    return _box.read(LocalStorageConstants.refresh);
  }

  static bool hasTokens() {
    return getAccessToken() != null &&
        getRefreshToken() != null;
  }

  static void clearTokens() {
    _box.remove(LocalStorageConstants.access);
    _box.remove(LocalStorageConstants.refresh);
  }

  // ================= SAVE PROFILE DETAILS =================

  static Future<void> saveProfileDetails({
    required int userId,
    required String name,
    required String username,
    required String mobile,
  }) async {
    await _box.write(LocalStorageConstants.userId, userId);
    await _box.write(LocalStorageConstants.name, name);
    await _box.write(LocalStorageConstants.username, username);
    await _box.write(LocalStorageConstants.mobile, mobile);

    print("========== PROFILE SAVED ==========");
    print("User ID: ${getUserId()}");
    print("Name: ${getName()}");
    print("Username: ${getUserName()}");
    print("Mobile: ${getMobile()}");
    print("===================================");
  }

  // ================= GUEST USER =================

  static void saveGuestStatus(bool isGuest) {
    _box.write(
      LocalStorageConstants.isGuest,
      isGuest,
    );
  }

  static bool isGuest() {
    return _box.read(
          LocalStorageConstants.isGuest,
        ) ??
        false;
  }

  static void clearGuestStatus() {
    _box.remove(LocalStorageConstants.isGuest);
  }

  // ================= USER DATA =================

  static void saveUserId(int id) {
    _box.write(LocalStorageConstants.userId, id);
  }

  static int? getUserId() {
    return _box.read(LocalStorageConstants.userId);
  }

  static void clearUserData() {
    _box.remove(LocalStorageConstants.userId);
    _box.remove(LocalStorageConstants.username);
    _box.remove(LocalStorageConstants.userEmail);
    _box.remove(LocalStorageConstants.mobile);
  }

   // ================= GUEST USER ID =================

  static void saveGuestUserId(int id) {
    _box.write(
      LocalStorageConstants.guestCartBackup,
      id,
    );
  }

  static int? getGuestUserId() {
    return _box.read(
      LocalStorageConstants.guestCartBackup,
    );
  }

  static void clearGuestUserId() {
    _box.remove(
      LocalStorageConstants.guestCartBackup,
    );
  }

  // ================= USERNAME =================

  static void saveUserName(String name) {
    _box.write(LocalStorageConstants.username, name);
  }

  static String? getUserName() {
    return _box.read(LocalStorageConstants.username);
  }

  // ================= NAME =================

  static void saveName(String name) {
    _box.write(LocalStorageConstants.name, name);
  }

  static String? getName() {
    return _box.read(LocalStorageConstants.name);
  }

  // ================= MOBILE =================

  static void saveMobile(String mobile) {
    _box.write(LocalStorageConstants.mobile, mobile);
  }

  static String? getMobile() {
    return _box.read(LocalStorageConstants.mobile);
  }

  // ================= PROFILE IMAGE =================

  static void saveProfileImage(String imageUrl) {
    _box.write(
      LocalStorageConstants.profileImage,
      imageUrl,
    );
  }

  static String? getProfileImage() {
    return _box.read(
      LocalStorageConstants.profileImage,
    );
  }

  static void clearProfileImage() {
    _box.remove(
      LocalStorageConstants.profileImage,
    );
  }

  // ================= FULL LOGOUT =================

  static void clearAll() {
    clearTokens();
    clearUserData();
    clearGuestStatus();
  }
}