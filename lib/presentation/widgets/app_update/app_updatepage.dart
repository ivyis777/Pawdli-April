import 'package:flutter/material.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
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
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
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
                /// Top Image
                Image.asset(
                  "assets/images/UpdateAvailable.png",
                  height: 150,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 12),

                // /// Title
                // const Text(
                //   "Update Available",
                //   textAlign: TextAlign.center,
                //   style: TextStyle(
                //     fontSize: 22,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),

                const SizedBox(height: 10),

                /// Description
                const Text(
                  "A new version of Pawdli is available.\nPlease update the app for the best experience.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                /// Buttons
                Row(
                  children: [
                    /// Skip Button
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colours.primarycolour,
                          ),
                          foregroundColor: Colours.primarycolour,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                        onPressed: () {
                          AppUpdateService.incrementSkip();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Skip",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    /// Update Button
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
                          AppUpdateService.resetSkip();
                          AppUpdateService.openStore();
                        },
                        child: const Text(
                          "Update",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}