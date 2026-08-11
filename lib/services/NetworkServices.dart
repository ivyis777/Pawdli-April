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
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// 📶 Offline Icon
              Icon(
                Icons.wifi_off_rounded,
                size: 90,
                color: Colors.grey.shade300,
              ),

              const SizedBox(height: 20),

              /// Title
              const Text(
                "You're offline",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              /// Subtitle
              const Text(
                "Check your connection and try again.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 12),

              /// Network Status
              // FutureBuilder<bool>(
              //   future: InternetConnection().hasInternetAccess,
              //   builder: (context, snapshot) {
              //     final connected = snapshot.data ?? false;

              //     return Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Icon(
              //           connected ? Icons.wifi : Icons.wifi_off,
              //           color: connected ? Colors.green : Colors.red,
              //           size: 20,
              //         ),
              //         const SizedBox(width: 6),
              //         Text(
              //           connected ? "Network Connected" : "No Network",
              //           style: TextStyle(
              //             color: connected ? Colors.green : Colors.red,
              //             fontWeight: FontWeight.w600,
              //           ),
              //         ),
              //       ],
              //     );
              //   },
              // ),

              // const SizedBox(height: 28),

              /// Try Again Button
              SizedBox(
                width: double.infinity,
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
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