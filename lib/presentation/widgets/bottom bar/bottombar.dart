import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/form_validation/form_validation.dart';
import 'package:pawlli/core/storage_manager/LocalStorageConstants.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/cartviewcontroller.dart';
import 'package:pawlli/data/controller/petslistcontroller.dart';
import 'package:pawlli/data/controller/reelitemcontroller.dart';
import 'package:pawlli/presentation/screens/good%20bye%20buddy/goodbyebudddy.dart';
import 'package:pawlli/presentation/screens/homepage/homepage.dart';
import 'package:pawlli/presentation/screens/loginpage/loginpage.dart';
import 'package:pawlli/presentation/screens/mychat/chat.dart';
import 'package:pawlli/presentation/screens/personalinfopage/personalinfopage.dart';
import 'package:pawlli/presentation/screens/pet%20Radio/petradio.dart';
import 'package:pawlli/presentation/screens/pet_store/pet_cart.dart';

class MainLayout extends StatefulWidget {
  MainLayout({super.key});

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final CartController cartController = Get.find<CartController>();

  late List<GlobalKey<NavigatorState>> navigatorKeys;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // ✅ CREATE CONTROLLERS ONCE (AFTER LOGIN / SIGNUP)
    if (!Get.isRegistered<ReelsController>()) {
      Get.put(ReelsController(), permanent: true);
    }

    if (!Get.isRegistered<Petslistcontroller>()) {
      Get.put(Petslistcontroller(), permanent: true);
    }

    navigatorKeys = List.generate(5, (index) => GlobalKey<NavigatorState>());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pages = [
      Navigator(
        key: navigatorKeys[0],
        onGenerateRoute: (routeSettings) =>
            MaterialPageRoute(builder: (context) => const HomePage()),
      ),
      Navigator(
        key: navigatorKeys[1],
        onGenerateRoute: (routeSettings) =>
            MaterialPageRoute(builder: (context) => const Petradio()),
      ),
      Navigator(
        key: navigatorKeys[2],
        onGenerateRoute: (routeSettings) =>
            MaterialPageRoute(builder: (context) => const Goodbyebudddy()),
      ),
      Navigator(
        key: navigatorKeys[3],
        onGenerateRoute: (routeSettings) =>
            MaterialPageRoute(builder: (context) => CartPage()),
      ),
      Navigator(
        key: navigatorKeys[4],
        onGenerateRoute: (routeSettings) =>
            MaterialPageRoute(builder: (context) => ChatPage()),
      ),
    ];
  }

  // void onTabSelected(int index) {
  //   // Validate only Pet Radio (1), Cart (3), and Chat (4).
  //   if (index == 1 || index == 3 || index == 4) {
  //     final isComplete = FormValidation.isProfileComplete(
  //       userId: LocalStorage.getUserId(),
  //       name: LocalStorage.getName(),
  //       username: LocalStorage.getUserName(),
  //       mobile: LocalStorage.getMobile(),
  //     );

  //     if (!isComplete) {
  //       Navigator.of(context, rootNavigator: true).push(
  //         MaterialPageRoute(
  //           builder: (_) => PersonalInfoPage(),
  //         ),
  //       );
  //       return;
  //     }
  //   }

  //   // Keep your existing selected-index update here.
  //   setState(() {
  //     _selectedIndex = index; // Use your actual index variable name
  //   });
  // }

  void _onItemTapped(int index) {
    // ✅ BLOCK CHAT FOR GUEST USERS
    if ((index == 1 || index == 3 || index == 4) &&
        LocalStorage.isGuest()) {
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colours.primarycolour,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/images/LoginRequired.png", 
                  height: 140,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 15),

                // Text(
                //   "Login Required".tr,
                //   textAlign: TextAlign.center,
                //   style: const TextStyle(
                //     fontSize: 22,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),

                const SizedBox(height: 10),

                Text(
                  "Please login to continue.".tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colours.primarycolour,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                        },
                        child: Text(
                          "Cancel".tr,
                          style: TextStyle(
                            color: Colours.primarycolour,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colours.primarycolour,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                          Get.offAll(() => LoginPage());
                        },
                        child: Text(
                          "Login".tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    if (index == _selectedIndex) {
      if (navigatorKeys[index].currentState!.canPop()) {
        navigatorKeys[index]
            .currentState!
            .popUntil((route) => route.isFirst);
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
      // Validation (profile)
    if (index == 1 || index == 3 || index == 4) {
      final isComplete = FormValidation.isProfileComplete(
        userId: LocalStorage.getUserId(),
        name: LocalStorage.getName(),
        username: LocalStorage.getUserName(),
        mobile: LocalStorage.getMobile(),
      );

      if (!isComplete) {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => PersonalInfoPage(),
          ),
        );
        return;
      }
    }
  }

  Future<bool> _onWillPop() async {
    final currentNavigatorState = navigatorKeys[_selectedIndex].currentState;

    if (currentNavigatorState != null && currentNavigatorState.canPop()) {
      currentNavigatorState.pop();
      return false;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (context) => Dialog(
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
              Image.asset(
                "assets/images/ExitApp.png",
                height: 150,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 12),

              // Text(
              //   'Exit App?'.tr,
              //   textAlign: TextAlign.center,
              //   style: const TextStyle(
              //     fontSize: 22,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.black87,
              //   ),
              // ),

              const SizedBox(height: 10),

              Text(
                'Are you sure you want to exit the app?'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colours.primarycolour,
                        ),
                        foregroundColor: Colours.primarycolour,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Text(
                        'No'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colours.primarycolour,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: Text(
                        'Yes'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.white,
          color: Colours.primarycolour,
          buttonBackgroundColor: Colours.brownColour,
          height: 60,
          animationDuration: const Duration(milliseconds: 300),
          items: [
            const FaIcon(FontAwesomeIcons.house, color: Colors.white, size: 24),
            const FaIcon(FontAwesomeIcons.radio, color: Colors.white, size: 24),
            Image.network(
              'https://app.pawdli.com/media/static/goodbyebuddy.png',
              width: 50,
              height: 50,
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                const FaIcon(
                  FontAwesomeIcons.cartArrowDown,
                  color: Colors.white,
                  size: 24,
                ),

                // 🔴 CART BADGE
                Obx(() {
                  final count = cartController.cartItems.length;

                  if (count == 0) {
                    return const SizedBox.shrink();
                  }

                  return Positioned(
                    top: -8,
                    right: -10,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 15,
                        minHeight: 15,
                      ),
                      child: Text(
                        count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            const FaIcon(FontAwesomeIcons.message, color: Colors.white, size: 24),
          ],
          index: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
