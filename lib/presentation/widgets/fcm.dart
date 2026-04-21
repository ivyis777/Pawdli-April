import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

Future<void> setupFCM() async {
  try {
    debugPrint('================ FCM SETUP START ================');

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('🔔 Authorization status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      debugPrint('🚫 Notification permission denied.');
      return;
    }

    debugPrint('🔔 Notification permission granted.');

    final box = GetStorage();

    // 🔥 STEP 1: ALWAYS GET FCM TOKEN (DON'T BLOCK)
    String? fcmToken;
    try {
      fcmToken = await messaging.getToken();
      debugPrint("🚀 FCM Token: $fcmToken");

      if (fcmToken != null && fcmToken.isNotEmpty) {
        box.write('fcm_token', fcmToken);
      }
    } catch (e) {
      debugPrint("❌ FCM TOKEN ERROR: $e");
    }

    // 🔥 STEP 2: TRY APNS TOKEN (OPTIONAL)
    try {
      String? apnsToken;

      for (int i = 0; i < 5; i++) {
        apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null) break;
        await Future.delayed(const Duration(seconds: 1));
      }

      debugPrint('🍎 APNs Token (iOS): $apnsToken');

      if (apnsToken != null && apnsToken.isNotEmpty) {
        box.write('apns_token', apnsToken);
      } else {
        debugPrint('⚠️ APNS still not available (normal on first run)');
      }
    } catch (e) {
      debugPrint("❌ APNS TOKEN ERROR: $e");
    }

    // 🔄 TOKEN REFRESH
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 Token refreshed: $newToken');
      box.write('fcm_token', newToken);
    });

  } catch (e) {
    debugPrint('❌ FCM ERROR (handled safely): $e');
  }

  // 🔔 FOREGROUND LISTENER
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('📥 FOREGROUND MESSAGE RECEIVED');
  });

  // 🔔 BACKGROUND CLICK LISTENER
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('📨 APP OPENED FROM NOTIFICATION');
  });

  debugPrint('================ FCM SETUP END ================');
}