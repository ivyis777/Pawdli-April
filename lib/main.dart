import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/appstate.dart';
import 'package:pawlli/core/storage_manager/LocalStorageConstants.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/core/translations/translation.dart';
import 'package:pawlli/data/cart%20payment/paymentservice.dart';
import 'package:pawlli/data/controller/DoctorController.dart';
import 'package:pawlli/data/controller/DoctorconsultationController.dart';
import 'package:pawlli/data/controller/cartviewcontroller.dart';
import 'package:pawlli/data/controller/competition_controller.dart';
import 'package:pawlli/data/controller/getuserprofilecontroller.dart';
import 'package:pawlli/data/controller/myordercontroller.dart';
import 'package:pawlli/data/controller/myreelscontroller.dart';
import 'package:pawlli/data/controller/mysubscriptioncontroller.dart';
import 'package:pawlli/data/controller/otpcontroller.dart';
import 'package:pawlli/data/controller/petslistcontroller.dart';
import 'package:pawlli/data/controller/reelitemcontroller.dart';
import 'package:pawlli/data/controller/signcontroller.dart';
import 'package:pawlli/data/controller/storecheckoutcontroller.dart';
import 'package:pawlli/data/controller/storesearchcontroller.dart';
import 'package:pawlli/data/controller/walletbalancecontroller.dart';
import 'package:pawlli/data/controller/transactioncontroller.dart';
import 'package:pawlli/data/controller/addresscontroller.dart';
import 'package:pawlli/data/notification_service.dart';
import 'package:pawlli/presentation/screens/loginpage/loginpage.dart';
import 'package:pawlli/presentation/screens/meet%20a%20vet/quick_appointment.dart/ConsultationRequestsPage.dart';
import 'package:pawlli/presentation/screens/splashcreen/splashscreen.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pawlli/presentation/widgets/app_update/app_updatepage.dart';
import 'package:pawlli/presentation/widgets/bottom%20bar/bottombar.dart';
import 'package:pawlli/presentation/widgets/fcm.dart';
import 'package:pawlli/services/NetworkServices.dart';

@pragma('vm:entry-point')
  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();

    debugPrint('========== BACKGROUND FCM ==========');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint("BODY => ${message.notification?.body}");
    debugPrint('Data: ${message.data}');

    final type = message.data['type'];

    if (type == "consultation_request") {
      await NotificationService.showDoctorRequestNotification(
        title: message.notification?.title ?? "New Consultation",
        body: message.notification?.body ?? "",
      );
    }
  }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppState.instance.initialize();
  await GetStorage.init();
  await Firebase.initializeApp();
  await NotificationService.init();

  await FirebaseMessaging.instance
      .setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await setupFCM();
  final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
  print("🍎 APNS TOKEN => $apnsToken");

  final token = await FirebaseMessaging.instance.getToken();
  print("================================");
  print("FULL IOS TOKEN");
  print(token);
  print("================================");


  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 🟢 Your existing controllers
  Get.put(SubscriptionController(), permanent: true);
  Get.put(OtpController(), permanent: true);
  Get.put(UserProfileController(), permanent: true);
  Get.put(DoctorController(), permanent: true);
  Get.put(DoctorConsultationController(), permanent: true,);

  final isDoctor =
      GetStorage().read(
        LocalStorageConstants.isDoctor,
      ) ??
      false;

  if (isDoctor) {
    Get.find<DoctorConsultationController>()
        .startPolling();
  }
  // ✅ LOAD USER PROFILE AT APP START
  final userProfileController = Get.find<UserProfileController>();

  final userId = int.tryParse(
    GetStorage().read(LocalStorageConstants.userId)?.toString() ?? '',
  );

  if (userId != null) {
    userProfileController.loadUserProfile(userId);
  }

  Get.put(Petslistcontroller(), permanent: true);
  Get.put(CartController(), permanent: true);
  Get.put(MyReelsController(), permanent: true);
  Get.put(ReelsController(), permanent: true);
  Get.lazyPut<MyOrdersController>(() => MyOrdersController(), fenix: true);

  // 🟢 REQUIRED for wallet + payment + address + orders
  Get.put(WalletBalanceController(), permanent: true);
  Get.put(TransactionController(), permanent: true);
  Get.put(SignupController(), permanent: true);
  Get.put(AddressController(), permanent: true);

  // This must come AFTER all the controllers above
  Get.putAsync(() => PaymentService().init(), permanent: true);
  Get.put(CompetitionController(), permanent: true);
  Get.put(StoreCheckoutController(), permanent: true);
  Get.put(StoreSearchController(), permanent: true);

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('📲 OPENED FROM NOTIFICATION');
    debugPrint('🧾 message.data = ${message.data}');
    debugPrint('🧾 message.notification = ${message.notification}');
  });

  FirebaseMessaging.onMessage.listen(
    (RemoteMessage message) async {

      print("📩 onMessage CALLED");

      print("================================");
      print("FCM RECEIVED");
      print("TITLE => ${message.notification?.title}");
      print("BODY => ${message.notification?.body}");
      print("DATA => ${message.data}");
      print("================================");

      final isDoctor =
          GetStorage().read(
            LocalStorageConstants.isDoctor,
          ) ?? false;

      final type = message.data['type'];

      print("NOTIFICATION TYPE => $type");

      // Only consultation requests should play ringtone
      if (!isDoctor || type != "consultation_request") {
        print("NORMAL NOTIFICATION - NO CUSTOM RINGTONE");
        return;
      }

      final controller =
          Get.find<DoctorConsultationController>();

      await controller.fetchLiveConsultations();

      if (controller.liveConsultations.isEmpty) {
        print("NO LIVE CONSULTATIONS");
        return;
      }

      await NotificationService.showDoctorRequestNotification(
        title: message.notification?.title ?? "New Consultation",
        body: message.notification?.body ?? "",
      );

      if (!controller.isIncomingRequestPageOpen) {

        controller.isIncomingRequestPageOpen = true;

        Get.to(
          () => const IncomingConsultationRequestsPage(),
        );
      }
    },
  );

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  runApp(const MyApp());

  NetworkService.instance.startMonitoring();

  Future.delayed(const Duration(seconds: 2), () {
    setupFCM();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkUserLoggedIn() async {
  return LocalStorage.getAccessToken() != null;
}

    Locale getSavedLocale() {
      final box = GetStorage();
      String? langCode = box.read('lang');

      if (langCode == null) {
        return const Locale('en'); 
      }

      return Locale(langCode);
    }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
          child: child!,
        );
      },

      translations: Messages(),
      locale: getSavedLocale(),
      fallbackLocale: const Locale('en'),
      title: 'PAWdLI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        future: _checkUserLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data == true) {
            return UpdateWrapper(child: MainLayout());
          }
          return LoginPage();
        },
      ),
      routes: {
        '/splash': (context) => const SplashPage(),
      },
    );
  }
}
