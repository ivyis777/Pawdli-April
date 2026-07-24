import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pawlli/core/appstate.dart';
import 'package:vibration/vibration.dart';

class NotificationService {
  static final _fcm = FirebaseMessaging.instance;
  static final AudioPlayer _player = AudioPlayer();

static bool _isPlaying = false;

  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel doctorChannel =
      AndroidNotificationChannel(
    'doctor_request_channel',
    'Doctor Consultation Requests',
    description: 'Incoming consultation requests',
    importance: Importance.max,
    playSound: true,
  );

  static Future<void> startDoctorRingtone() async {

    print("========== START RINGTONE ==========");

    if (_isPlaying) {
      print("RINGTONE ALREADY PLAYING");
      return;
    }

    _isPlaying = true;

    try {

      await _player.setReleaseMode(
        ReleaseMode.loop,
      );

      print("PLAYING ringtone.mp3");

      await _player.play(
        AssetSource("ringtone.mp3"),
      );

      print("RINGTONE STARTED");

    } catch (e) {

      print("RINGTONE ERROR => $e");
    }
  }

  static Future<void> stopDoctorRingtone() async {

    _isPlaying = false;

    await _player.stop();
  }

  static Future<void> init() async {

    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print("================================");
    print("NOTIFICATION PERMISSION");
    print("Authorization Status => ${settings.authorizationStatus}");
    print("================================");


    const android =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const ios =
        DarwinInitializationSettings();

    const settingsInit = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _local.initialize(settingsInit);

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
            doctorChannel);

  }

  static Future<void>showDoctorRequestNotification({

    required String title,

    required String body,

  }) async {

  print("========== SHOW LOCAL NOTIFICATION ==========");
  print("TITLE => $title");
  print("BODY => $body");

    const androidDetails =
        AndroidNotificationDetails(

      'doctor_request_channel',

      'Doctor Consultation Requests',

      channelDescription:
          'Incoming consultation requests',

      importance: Importance.max,

      priority: Priority.max,

      fullScreenIntent: true,

      category:
          AndroidNotificationCategory.call,

      visibility:
          NotificationVisibility.public,

      playSound: true,

      enableVibration: true,

      autoCancel: false,

      ongoing: true,

    );

    const iosDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _local.show(

      DateTime.now()
          .millisecondsSinceEpoch ~/ 1000,

      title,

      body,

      const NotificationDetails(

        android: androidDetails,

        iOS: iosDetails,
      ),
    );
    // Play ringtone ONLY if app is not in foreground
    await startDoctorRingtone();

    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 1500);
    }
  }

  static Future<String?> getToken() async {

    return await _fcm.getToken();
  }
}


class NotificationTopicService {

  static Future<void> subscribeAllUsers() async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic("all_users");
      print("✅ Subscribed to topic: all_users");
    } catch (e) {
      print("❌ Topic subscription failed: $e");
    }
  }
}
