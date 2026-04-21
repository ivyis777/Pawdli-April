import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pawlli/data/controller/otpcontroller.dart';
import 'package:pawlli/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pathProviderChannel = MethodChannel(
    'plugins.flutter.io/path_provider',
  );

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (methodCall) async {
      return '.';
    });
    await GetStorage.init();
  });

  setUp(() async {
    Get.testMode = true;
    Get.reset();

    final box = GetStorage();
    await box.erase();
    await box.write('lang', 'en');

    Get.put(OtpController(), permanent: true);
  });

  tearDown(Get.reset);

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
  });

  testWidgets('MyApp builds the initial startup frame', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(GetMaterialApp), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
