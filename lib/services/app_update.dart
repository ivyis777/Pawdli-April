import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateService {
  static const String skipCountKey = "update_skip_count";

  static Future<bool> isUpdateAvailable() async {
    final newVersion = NewVersionPlus(
      androidId: "com.ivyis.pawlli",
      iOSId: "6747665709",
    );

    final status = await newVersion.getVersionStatus();

    if (status == null) return false;

    print("Current: ${status.localVersion}");
    print("Store: ${status.storeVersion}");

    return status.canUpdate;
  }

  static int getSkipCount() {
    return GetStorage().read(skipCountKey) ?? 0;
  }

  static void incrementSkip() {
    int count = getSkipCount();
    GetStorage().write(skipCountKey, count + 1);
  }

  static void resetSkip() {
    GetStorage().write(skipCountKey, 0);
  }

  static Future<void> openStore() async {
    final url = Platform.isAndroid
        ? "https://play.google.com/store/apps/details?id=com.ivyis.pawlli"
        : "https://apps.apple.com/app/id6747665709";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}