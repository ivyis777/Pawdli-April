import 'package:get_storage/get_storage.dart';

class AppLanguage {
  static String get langCode {
    final box = GetStorage();
    return box.read('lang') ?? 'en';
  }
}