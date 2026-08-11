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
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Update Icon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colours.primarycolour.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.system_update_alt_rounded,
                  size: 50,
                  color: Colours.primarycolour,
                ),
              ),

              const SizedBox(height: 24),

              /// Title
              const Text(
                "Update Available",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              /// Description
              const Text(
                "A new version of Pawdli is available.\nPlease update the app for the best experience.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              /// Update Button
              Row(
                children: [
                  /// Skip Button
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colours.primarycolour),
                          foregroundColor: Colours.primarycolour,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          AppUpdateService.incrementSkip();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Skip",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// Update Button
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colours.primarycolour,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          AppUpdateService.resetSkip();
                          AppUpdateService.openStore();
                        },
                        child: const Text(
                          "Update",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}