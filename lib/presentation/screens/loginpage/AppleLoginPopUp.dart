import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/api service.dart';
import 'package:pawlli/data/controller/otpcontroller.dart';
import 'package:pawlli/presentation/screens/personalinfopage/personalinfopage.dart';
import 'package:pawlli/presentation/widgets/bottom bar/bottombar.dart';

void showAppleEmailPopup(
  String identityToken,
) {
  final emailController =
      TextEditingController();

  // final otpController =
  //     TextEditingController();

  final otpGet =
      Get.put(OtpController());

  final box = GetStorage();

  List<TextEditingController> otpControllers =
      List.generate(
        4,
        (_) => TextEditingController(),
      );

  List<FocusNode> focusNodes =
      List.generate(
        4,
        (_) => FocusNode(),
      );

  bool otpSent = false;
  

  Get.dialog(
    StatefulBuilder(
      builder: (
        context,
        setState,
      ) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(
              MediaQuery.of(context).size.width * 0.04,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF5A623),
              borderRadius: BorderRadius.circular(25),
            ),
            child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

               Stack(
                children: [

                  Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      "assets/images/Pawlli_logo.png",
                      height: MediaQuery.of(context).size.width * 0.18,
                    ),
                  ),

                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(
                        Icons.close,
                        color: Colours.brownColour,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                "Email is required for Apple Sign In",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: getResponsiveFont(context, 14),
                ),
              ),

                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter your email",
                      prefixIcon: Icon(Icons.email_outlined),
                      contentPadding: EdgeInsets.all(15),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                if (otpSent)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {

                        final result =
                            await otpGet.getOtpUser(
                          email: emailController.text.trim(),
                          purpose: "apple_signup",
                          isResend: true,
                        );

                        Get.snackbar(
                          "Success",
                          result.message,
                        );
                      },
                      child: Text(
                        "Resend OTP",
                        style: TextStyle(
                          color: Colours.brownColour,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                if (!otpSent)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {

                        final result =
                            await otpGet.getOtpUser(
                          email:
                              emailController.text.trim(),
                          purpose: "apple_signup",
                          isResend: false,
                        );

                        if (result.success) {

                          setState(() {
                            otpSent = true;
                          });

                          Get.snackbar(
                            "Success",
                            result.message,
                          );

                        } else {

                          Get.snackbar(
                            "Error",
                            result.message,
                          );
                        }
                      },
                      child: Text(
                        "Get OTP",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: getResponsiveFont(context, 14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                if (otpSent) ...[

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      4,
                      (index) => SizedBox(
                        width: MediaQuery.of(context).size.width * 0.13,
                        height: MediaQuery.of(context).size.width * 0.13,
                        child: TextField(
                          controller:
                              otpControllers[index],
                          focusNode:
                              focusNodes[index],
                          keyboardType: TextInputType.number,
                            // autofillHints: const [
                            //   AutofillHints.oneTimeCode,
                            // ],
                          textAlign:
                              TextAlign.center,
                          maxLength: 4,
                          textInputAction:
                              TextInputAction.next,

                          onChanged: (value) {
                            // 🔥 HANDLE FULL OTP PASTE (MAIN FIX)
                            if (value.length > 1) {
                              String code = value.replaceAll(RegExp(r'[^0-9]'), '');
                              code = code.padLeft(4, '0');

                              for (int i = 0; i < 4; i++) {
                                otpControllers[i].text = code[i];
                              }

                              FocusScope.of(context).unfocus(); // ✅ HIDE KEYBOARD
                              return;
                            }

                            // 🔥 NORMAL TYPING
                              if (value.isNotEmpty) {
                                if (index < 3) {
                                  FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                                } else {
                                  // ✅ LAST BOX → HIDE KEYBOARD
                                  FocusScope.of(context).unfocus();

                                }
                              } else if (value.isEmpty && index > 0) {
                                FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                              }
                          },

                          decoration:
                              InputDecoration(
                            counterText: "",
                            filled: true,
                            fillColor:
                                Colors.white,
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(
                          0xFF8D6B5A,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            15,
                          ),
                        ),
                      ),
                      onPressed: () async {

                        final response =
                            await ApiService.appleCompleteAPI(
                              identityToken: identityToken,
                              email: emailController.text.trim(),
                              otp: otpControllers.map((c) => c.text).join(),
                            );

                        if (response.status ==
                                true &&
                            response.data != null) {

                          final user =
                              response.data!;

                          box.write(
                            LocalStorageConstants
                                .sessionManager,
                            true,
                          );

                          box.write(
                            LocalStorageConstants
                                .userId,
                            user.userId,
                          );

                          box.write(
                            LocalStorageConstants
                                .userEmail,
                            user.email,
                          );

                          box.write(
                            LocalStorageConstants
                                .username,
                            user.username ?? "",
                          );

                          box.write(
                            LocalStorageConstants
                                .name,
                            user.name ?? "",
                          );

                          box.write(
                            LocalStorageConstants
                                .access,
                            user.tokens
                                    ?.access ??
                                "",
                          );

                          box.write(
                            LocalStorageConstants
                                .refresh,
                            user.tokens
                                    ?.refresh ??
                                "",
                          );

                          Get.back();

                          if (user.isNewUser ==
                              true) {

                            Get.offAll(
                              () =>
                                  PersonalInfoPage(),
                            );

                          } else {

                            Get.offAll(
                              () => MainLayout(),
                            );
                          }
                        }
                      },
                      icon: const Icon(
                        Icons.email_outlined,
                        color: Colors.white,
                      ),
                      label: Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: getResponsiveFont(context,22),
                        ),
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
          ),
        ),
        );
      },
    ),
    barrierDismissible: false,
  );
}