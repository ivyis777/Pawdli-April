import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/presentation/widgets/bottom bar/bottombar.dart';

class NetworkService {
  static final NetworkService instance = NetworkService._();

  NetworkService._();

  StreamSubscription? _subscription;
  bool _dialogOpen = false;

  VoidCallback? onRefreshCurrentPage;

  void startMonitoring() {
    _subscription = Connectivity().onConnectivityChanged.listen((_) async {
      bool hasInternet =
          await InternetConnection().hasInternetAccess;

      if (!hasInternet) {
        _showOfflineDialog();
      } else {
        _hideOfflineDialog();

        if (onRefreshCurrentPage != null) {
          onRefreshCurrentPage!();
        }
      }
    });
  }

  void _showOfflineDialog() {
    if (_dialogOpen) return;

    _dialogOpen = true;

    Get.dialog(
      PopScope(
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
                  "assets/images/NoNetwork.png",
                  height: 150,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 12),

                // /// Title
                // const Text(
                //   "You're offline",
                //   textAlign: TextAlign.center,
                //   style: TextStyle(
                //     fontSize: 22,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),

                const SizedBox(height: 10),

                /// Message
                const Text(
                  "Check your connection and try again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 20),

                /// Try Again Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colours.primarycolour,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      bool hasInternet =
                          await InternetConnection().hasInternetAccess;

                      if (hasInternet) {
                        _hideOfflineDialog();

                        if (onRefreshCurrentPage != null) {
                          onRefreshCurrentPage!();
                        }
                      }
                    },
                    child: const Text(
                      "Try again",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _hideOfflineDialog() {
    if (!_dialogOpen) return;

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    _dialogOpen = false;
  }

  void dispose() {
    if (NetworkService.instance.onRefreshCurrentPage != null) {
      NetworkService.instance.onRefreshCurrentPage = null;
    }
    _subscription?.cancel();
  }
}