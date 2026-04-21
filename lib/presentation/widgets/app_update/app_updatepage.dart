import 'package:flutter/material.dart';
import 'package:pawlli/services/app_update.dart';

class UpdateWrapper extends StatefulWidget {
  final Widget child;
  const UpdateWrapper({required this.child});

  @override
  State<UpdateWrapper> createState() => _UpdateWrapperState();
}

class _UpdateWrapperState extends State<UpdateWrapper> {
  @override
  void initState() {
    super.initState();
    checkUpdate();
  }

  void checkUpdate() async {
    bool updateAvailable = await AppUpdateService.isUpdateAvailable();

    if (!updateAvailable) return;

    int skipCount = AppUpdateService.getSkipCount();

    // 🚨 If skipped 3 times → open store directly
    if (skipCount >= 3) {
      AppUpdateService.openStore();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text("Update Available"),
        content: Text("Please update the app for best experience"),
        actions: [
          TextButton(
            onPressed: () {
              AppUpdateService.incrementSkip();
              Navigator.pop(context);
            },
            child: Text("Skip"),
          ),
          ElevatedButton(
            onPressed: () {
              AppUpdateService.resetSkip();
              AppUpdateService.openStore();
            },
            child: Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}