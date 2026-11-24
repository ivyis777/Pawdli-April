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

      FirebaseApp.configure()

    // ✅ AUDIO SESSION FOR WEBRTC
    // ✅ DEFAULT AUDIO SESSION FOR MEDIA PLAYBACK
    do {

      let session = AVAudioSession.sharedInstance()

      try session.setCategory(
        .playback,
        mode: .default
      )

      try session.setActive(true)

      print("✅ AVAudioSession configured for playback")

    } catch {

      print("❌ AVAudioSession Error: \(error)")
    }

    // Notifications
    UNUserNotificationCenter.current().delegate = self
    application.registerForRemoteNotifications()

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