import Flutter
import UIKit
import AVFoundation
import Firebase
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // ✅ AUDIO SESSION FOR WEBRTC
    do {

      try AVAudioSession.sharedInstance().setCategory(
        .playAndRecord,
        mode: .videoChat,
        options: [
          .defaultToSpeaker,
          .allowBluetooth,
          .allowBluetoothA2DP
        ]
      )

      try AVAudioSession.sharedInstance().setActive(true)

      print("✅ AVAudioSession configured")

      UNUserNotificationCenter.current().delegate = self

      application.registerForRemoteNotifications()

    } catch {

      print("❌ AVAudioSession Error: \(error)")
    }

    return super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
  }

  func didInitializeImplicitFlutterEngine(
    _ engineBridge: FlutterImplicitEngineBridge
  ) {

    GeneratedPluginRegistrant.register(
      with: engineBridge.pluginRegistry
    )
  }
  override func application(
      _ application: UIApplication,
      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
      Messaging.messaging().apnsToken = deviceToken
      print("✅ APNS TOKEN REGISTERED")
  }

  override func application(
      _ application: UIApplication,
      didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
      print("❌ APNS Registration Failed")
      print(error.localizedDescription)
  }
}