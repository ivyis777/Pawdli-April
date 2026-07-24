import 'package:flutter/widgets.dart';

class AppState with WidgetsBindingObserver {
  AppState._();

  static final AppState instance = AppState._();

  bool isForeground = true;

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    isForeground = state == AppLifecycleState.resumed;

    print("APP STATE => $state");
    print("IS FOREGROUND => $isForeground");
  }
}