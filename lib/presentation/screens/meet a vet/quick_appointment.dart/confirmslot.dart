import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawlli/core/storage_manager/LocalStorageConstants.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/controller/QuickConsultationController.dart';
import 'package:pawlli/data/controller/walletbalancecontroller.dart';
import 'package:pawlli/data/model/ConsultationDetailsModel.dart';
import 'package:pawlli/data/model/VetPaymentModel.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/meet%20a%20vet/DoctorConnectingPage.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'reviewpage.dart';

double getResponsiveFont(
    BuildContext context,
    double size,
    ) {

  double screenWidth =
      MediaQuery.of(context).size.width;

  if (screenWidth < 360) {
    return size * 0.85;
  } else if (screenWidth < 400) {
    return size;
  } else if (screenWidth < 600) {
    return size * 1.1;
  } else {
    return size * 1.3;
  }
}

class ReviewandpayPage extends StatefulWidget {

  final int consultationId;

  const ReviewandpayPage({
    super.key,
    required this.consultationId,
  });

  @override
  State<ReviewandpayPage>
  createState() =>
      _ReviewandpayPageState();
}

class _ReviewandpayPageState
    extends State<ReviewandpayPage> {

  final TextEditingController
  _couponController =
  TextEditingController();

  ConsultationDetailsModel? consultationDetails;

  bool isLoadingDetails = true;

  bool _useWallet = false;

  double totalAmount = 0.0;

  double discountAmount = 0.0;

  double taxAmount = 0.0;

  double consultationFee = 0.0;

  double walletAmount = 0.0;

  String? appliedCouponCode;

  double walletBalance = 0.00;

  bool couponApplied = false;

  String couponCode = "";

  late Razorpay _razorpay;

  String? currentOrderId;

  int? paymentTransactionId;

  // int? consultationId;

  final WalletBalanceController
    walletController =
        Get.put(
          WalletBalanceController(),
        );


  @override
    void initState() {

      super.initState();

      getConsultationDetails();

      loadWalletBalance();

      _razorpay = Razorpay();

      _razorpay.on(
        Razorpay.EVENT_PAYMENT_SUCCESS,
        _handlePaymentSuccess,
      );

      _razorpay.on(
        Razorpay.EVENT_PAYMENT_ERROR,
        _handlePaymentError,
      );

      _razorpay.on(
        Razorpay.EVENT_EXTERNAL_WALLET,
        _handleExternalWallet,
      );
    }

    @override
      void dispose() {

        _razorpay.clear();

        super.dispose();
      }

    Future<void> getConsultationDetails() async {

      setState(() {
        isLoadingDetails = true;
      });

      consultationDetails =
          await ApiService.getConsultationDetails(
        widget.consultationId,
      );

      totalAmount =
          double.tryParse(
            consultationDetails
                    ?.data
                    ?.consultationFee ??
                "0",
          ) ??
          0;

      consultationFee = totalAmount;

      print("TOTAL AMOUNT => $totalAmount");
      print("CONSULTATION FEE => $consultationFee");

      print(
        "PET TYPE => ${consultationDetails?.data?.petType}",
      );

      setState(() {
        isLoadingDetails = false;
      });

      print(
          "DETAILS => ${consultationDetails?.data}");
    }

    Future<void> _applyCoupon() async {
      if (_couponController.text.trim().isEmpty) {
        Fluttertoast.showToast(
          msg: "Enter coupon code",
        );
        return;
      }

      final response =
          await ApiService.applyCoupon(
        consultationRequestId:
            widget.consultationId,
        couponCode:
            _couponController.text.trim(),
      );

      if (response != null &&
          response.status == true) {

        if (!mounted) return;

        setState(() {

          couponApplied = true;

          discountAmount =
              response.discountAmount ?? 0;

          taxAmount =
              response.taxAmount ?? 0;

          consultationFee =
              response.consultationFee ?? 0;

          appliedCouponCode =
              response.couponCode;
        });

        Fluttertoast.showToast(
          msg: response.message ?? "",
        );

      } else {

        /// EXPIRED COUPON
        if (response?.message ==
            "Coupon expired. Please apply again.") {

          await _refreshCouponAmount();

        } else {

          Fluttertoast.showToast(
            msg: response?.message ??
                "Invalid coupon",
          );
        }
      }
    }

    Future<void> _refreshCouponAmount() async {

      Fluttertoast.showToast(
        msg: "Coupon expired. Please apply again.",
      );

      final response =
          await ApiService.applyCoupon(
        consultationRequestId:
            widget.consultationId,
        couponCode: "",
      );

      if (response != null &&
          response.status == true) {

        if (!mounted) return;

        setState(() {

          couponApplied = false;

          consultationFee = totalAmount;

          discountAmount = 0;

          appliedCouponCode = null;

          _couponController.clear();

          consultationFee =
              totalAmount;

          taxAmount =
              response.taxAmount ?? 0;
        });
      }
    }
      

      Future<void> loadWalletBalance() async {

        final userId =
            LocalStorage.getUserId();

        if (userId != null) {

          await walletController
              .fetchWalletBalance(userId);

          setState(() {

            walletBalance =
                double.tryParse(

                  walletController
                      .walletBalanceAmount
                      .value,

                ) ??
                0;
          });
        }
      }

  @override
  Widget build(BuildContext context) {

    double netPayable =
      (consultationFee - walletAmount)
      .clamp(0, double.infinity);

    return GestureDetector(


      onTap: () {
        FocusScope.of(context)
            .unfocus();
      },

      child: Scaffold(

        backgroundColor:
        Colours.secondarycolour,

        appBar: AppBar(
          toolbarHeight: 60,
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,

          flexibleSpace: Stack(
            children: [
              SizedBox(
                height: 100,
                width: 250,
                child: Image.network(
                  'https://app.pawdli.com/media/static/topimage.png',
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),

          foregroundColor: Colours.brownColour,

          title: Text(
            "Review & Pay".tr,
            style: TextStyle(
              fontSize: getResponsiveFont(context, 18),
              fontWeight: FontWeight.w600,
              fontFamily: FontFamily.Cairo,
              color: Colours.brownColour,
            ),
          ),
        ),

        body: SingleChildScrollView(

          child: Padding(
            padding:
            const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [

                /// PET DETAILS
                Container(

                  padding:
                      const EdgeInsets.all(16),

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(15),

                    border: Border.all(
                      color: Colours.primarycolour
                          .withValues(alpha: 0.4),
                    ),
                  ),

                  child: Padding(
                    padding:
                    const EdgeInsets
                        .all(16),

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [

                        _buildRow(
                          "Pet Name",

                          consultationDetails?.data?.petName ?? "-"
                        ),

                        const SizedBox(
                            height: 12),

                        _buildRow(
                          "Age",

                          consultationDetails?.data?.petAge ?? "-"
                        ),

                        const SizedBox(
                            height: 12),

                        _buildRow(
                          "Gender",

                          consultationDetails?.data?.petGender ?? "-"
                        ),

                        const SizedBox(
                            height: 12),

                        _buildRow(
                          "Pet Type",

                          consultationDetails?.data?.petType ?? "-"
                        ),

                        const SizedBox(
                            height: 12),

                        _buildRow(
                          "Pet Breed",

                          consultationDetails?.data?.petBreed ?? "-"
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                    height: 24),

                /// SYMPTOMS
                Text(
                  "Symptoms",
                  style: TextStyle(
                    fontSize: getResponsiveFont(context, 16),
                    fontWeight: FontWeight.w600,
                    color: Colours.black,
                  ),
                ),

                const SizedBox(height: 10),

                Builder(
                  builder: (_) {
                    List<String> symptomNames =
                        (consultationDetails?.data?.symptoms ?? [])
                            .map<String>((e) => e["name"].toString())
                            .toList();

                    String otherSymptom =
                        consultationDetails?.data?.otherSymptom?.trim() ?? "";

                    // Remove duplicate names from other_symptom
                    if (otherSymptom.isNotEmpty) {
                      List<String> others = otherSymptom
                          .split(",")
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();

                      others.removeWhere(
                        (item) => symptomNames.contains(item),
                      );

                      symptomNames.addAll(others);
                    }

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colours.primarycolour.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        symptomNames.join(", "),
                        style: TextStyle(
                          fontSize: getResponsiveFont(context, 14),
                          color: Colors.black,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                const SizedBox(
                    height: 24),

                /// PROBLEM
                Text(
                  "Write Your Problem",

                  style: TextStyle(
                    fontSize:
                    getResponsiveFont(
                        context,
                        16),

                    fontWeight:
                    FontWeight.w600,

                    // fontFamily:
                    // FontFamily.Cairo,

                    color:
                    Colours.black,
                  ),
                ),

                const SizedBox(
                    height: 10),

                Container(

                  width: double.infinity,

                  padding:
                      const EdgeInsets.all(16),

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(15),

                    border: Border.all(
                      color: Colours.primarycolour
                          .withValues(alpha: 0.4),
                    ),
                  ),

                  child: Text(

                    consultationDetails
                          ?.data
                          ?.problemDescription ??
                      "-",

                    style: TextStyle(
                      fontSize:
                      getResponsiveFont(
                          context,
                          14),

                      fontFamily:
                      FontFamily
                          .Cairo,
                    ),
                  ),
                ),

                const SizedBox(
                    height: 24),

                /// IMAGES
                Text(
                  "Pet Images",

                  style: TextStyle(
                    fontSize:
                    getResponsiveFont(
                        context,
                        16),

                    fontWeight:
                    FontWeight.w600,

                    // fontFamily:
                    // FontFamily.Cairo,

                    color:
                    Colours.black,
                  ),
                ),

                const SizedBox(
                    height: 16),

                (consultationDetails?.data?.issueImages ?? [])
                     .isEmpty

                    ? Container(
                        height: 120,
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: const Text(
                          "No Images Selected",
                        ),
                      )

                    : SizedBox(
                        height: 140,

                        child: ListView.builder(

                          scrollDirection: Axis.horizontal,

                          itemCount:
                              consultationDetails
                                  ?.data
                                  ?.issueImages
                                  ?.length ?? 0,

                          itemBuilder: (context, index) {

                            return Padding(

                              padding: const EdgeInsets.only(
                                right: 12,
                              ),

                              child: ClipRRect(

                                borderRadius:
                                    BorderRadius.circular(14),

                                child: Image.network(

                                  consultationDetails!
                                      .data!
                                      .issueImages![index]["image"],

                                  width: 140,

                                  fit: BoxFit.cover,
                                )
                              ),
                            );
                          },
                        ),
                      ),

                const SizedBox(
                    height: 30),

                /// DIVIDER
                Row(
                  children: [

                    Container(
                      width: 12,
                      height: 12,

                      decoration:
                      BoxDecoration(
                        shape:
                        BoxShape
                            .circle,

                        color: Colours
                            .black,
                      ),
                    ),

                    Expanded(
                      child: Divider(
                        thickness: 2,

                        color:
                        Colours.black,
                      ),
                    ),

                    Container(
                      width: 12,
                      height: 12,

                      decoration:
                      BoxDecoration(
                        shape:
                        BoxShape
                            .circle,

                        color: Colours
                            .black,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                    height: 20),

                Text(
                  "Coupon",

                  style: TextStyle(
                    fontSize: getResponsiveFont(
                      context,
                      16,
                    ),

                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                /// COUPON
                Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,

                    children: [

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: .5,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colours.primarycolour.withValues(alpha: 0.4),
                          ),
                        ),

                        child: Row(
                          children: [

                            Expanded(
                              child: TextField(
                                controller: _couponController,
                                decoration: const InputDecoration(
                                  hintText: "Enter Coupon",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),

                            GestureDetector(
                              onTap: () {

                                if (couponApplied) {

                                  _removeCoupon();

                                } else {

                                  _applyCoupon();
                                }
                              },

                              child: Container(

                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 3,
                                  vertical: 6,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),

                                child: Text(
                                  couponApplied
                                      ? "Remove"
                                      : "Apply",
                                  style: TextStyle(
                                    color: couponApplied
                                        ? Colors.red
                                        : Colors.green,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // if (couponApplied)
                      // Padding(
                      //   padding:
                      //       const EdgeInsets.only(top: 8),
                      //   child: Text(
                      //     "Coupon applied: -₹${discountAmount.toStringAsFixed(2)}",
                      //     style: const TextStyle(
                      //       color: Colors.green,
                      //       fontWeight: FontWeight.w600,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),

                const SizedBox(
                    height: 20),

                Text(
                  "Wallet",

                  style: TextStyle(
                    fontSize:
                        getResponsiveFont(
                            context,
                            16),

                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                // const SizedBox(height: 10),

                /// WALLET
                Container(

                  padding:
                      const EdgeInsets.all(10),

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(25),

                    // border: Border.all(
                    //   color: Colours.primarycolour
                    //       .withOpacity(0.4),
                    // ),
                  ),

                  child: Row(
                    children: [

                      Switch(

                        value: _useWallet,

                        activeThumbColor:
                            Colours.primarycolour,

                        inactiveThumbColor:
                            Colors.black,

                        onChanged: (value) {

                          setState(() {

                            _useWallet = value;

                            if (_useWallet) {

                              walletAmount =
                                  walletBalance >
                                          consultationFee
                                      ? consultationFee
                                      : walletBalance;

                            } else {

                              walletAmount = 0;
                            }
                          });
                        },
                      ),

                      Expanded(
                        child: Obx(

                          () => Text(

                            "Use Wallet - ₹${walletController.walletBalanceAmount.value}",

                            style: TextStyle(

                              fontSize:
                              getResponsiveFont(
                                  context,
                                  14),

                              fontWeight:
                              FontWeight.w500,

                              fontFamily:
                              FontFamily.Cairo,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                  Text(
                    "Payment Details",

                    style: TextStyle(
                      fontSize:
                          getResponsiveFont(
                              context,
                              16),

                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                /// TOTAL COST
                Container(

                  padding:
                      const EdgeInsets.all(16),

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(15),

                    border: Border.all(
                      color:
                      Colours.primarycolour
                          .withValues(alpha: 0.4),
                    ),
                  ),

                  child: Column(

                    children: [

                      _amountRow(
                        "Total Amount",
                        " ₹${ totalAmount.toStringAsFixed(2)}",
                      ),

                      if (couponApplied)
                        _amountRow(
                          "Coupon Applied",
                          "- ₹${ discountAmount.toStringAsFixed(2)}",
                        ),

                      // if (couponApplied)
                        _amountRow(
                          "Tax",
                          "₹${ taxAmount.toStringAsFixed(2)}",
                        ),

                      if (_useWallet)
                        _amountRow(
                          "Wallet Used",
                          "- ₹${ walletAmount.toStringAsFixed(2)}",
                        ),

                      const Divider(),

                      _amountRow(
                        "Net Payable",
                        "₹${netPayable.toStringAsFixed(2)}",
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                    height: 40),

                /// PAYMENT
                SizedBox(
                  width:
                  double.infinity,

                  height: 60,

                  child:
                  ElevatedButton(

                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      Colours.primarycolour,

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                            14),
                      ),
                    ),

                    onPressed: () async {

                      await _payNow();
                    },

                    child: Text(
                      "Pay Now",

                      style:
                      TextStyle(
                        fontSize:
                        getResponsiveFont(
                            context,
                            16),

                        fontWeight:
                        FontWeight.w600,

                        fontFamily:
                        FontFamily.Cairo,

                        color:
                        Colours.secondarycolour,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                    height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// DETAILS ROW
  Widget _buildRow(
      String title,
      String value,
      ) {

    return Row(
      children: [

        Expanded(
          child: Text(
            "$title :",

            style: TextStyle(
              fontSize:
              getResponsiveFont(
                  context, 14),

              fontWeight:
              FontWeight.w600,

              // fontFamily:
              // FontFamily.Cairo,

              color: Colors.black54,
            ),
          ),
        ),

        Expanded(
          child: Text(
            value,

            style: TextStyle(
              fontSize:
              getResponsiveFont(
                  context, 14),

              // fontFamily:
              // FontFamily.Cairo,
              color: Colors.black,

              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// AMOUNT ROW
  Widget _amountRow(
      String title,
      String value,
      ) {

    return Row(
      mainAxisAlignment:
      MainAxisAlignment
          .spaceBetween,

      children: [

        Text(
          title,

          style: TextStyle(
            fontSize:
            getResponsiveFont(
                context, 15),

            fontWeight:
            FontWeight.w600,

            // fontFamily:
            // FontFamily.Cairo,
          ),
        ),

        Text(
          value,

          style: TextStyle(
            fontSize:
            getResponsiveFont(
                context, 15),

            fontWeight:
            FontWeight.w600,

            // fontFamily:
            // FontFamily.Cairo,

            color:
            Colors.black,
          ),
        ),
      ],
    );
  }

  /// SUCCESS DIALOG
  void _showPaymentSuccessDialog(
      BuildContext context) {

    showDialog(
      context: context,

      builder: (context) {

        return Dialog(

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
                20),
          ),

          child: Padding(
            padding:
            const EdgeInsets.all(
                20),

            child: Column(
              mainAxisSize:
              MainAxisSize.min,

              children: [

                CircleAvatar(
                  radius: 50,

                  backgroundColor:
                  Colours.primarycolour,

                  child: Icon(
                    Icons.check,

                    size: 50,

                    color: Colours
                        .secondarycolour,
                  ),
                ),

                const SizedBox(
                    height: 20),

                Text(
                  "Payment Successful!",

                  style: TextStyle(
                    fontSize:
                    getResponsiveFont(
                        context,
                        18),

                    fontWeight:
                    FontWeight.w700,

                    fontFamily:
                    FontFamily.Cairo,
                  ),
                ),

                const SizedBox(
                    height: 20),

                SizedBox(
                  width:
                  double.infinity,

                  height: 50,

                  child:
                  ElevatedButton(

                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      Colours.primarycolour,
                    ),

                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Appointmentreviewpage(),
                        ),
                      );
                    },

                    child: Text(
                      "Okay",

                      style: TextStyle(
                        color: Colours
                            .secondarycolour,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

      Future<void> _payNow() async {

      String paymentType = "razorpay";

      if (_useWallet) {

        if (walletAmount >= consultationFee) {

          paymentType = "wallet";

        } else {

          paymentType = "wallet_razorpay";
        }
      }

      final response =
          await ApiService.reviewAndPay(

        consultationRequestId:
            widget.consultationId,

        paymentType:
            paymentType,
      );

      if (response == null) {

        Fluttertoast.showToast(
          msg: "Payment failed",
        );

        return;
      }

      paymentTransactionId =
          response.paymentTransactionId;

      /// WALLET PAYMENT
      if (response.paymentFlow ==
          "wallet") {

        final verifyResponse =
            await ApiService
                .verifyConsultationPayment(

          paymentTransactionId:
              paymentTransactionId!,
        );

        if (verifyResponse != null &&
            verifyResponse.status == true) {

              print("GOING TO DOCTOR PAGE");
              print("CONSULTATION ID => ${widget.consultationId}");

              print("PAYMENT VERIFIED");
              print("OPENING DOCTOR PAGE");


          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorConnectingPage(
                consultationId: widget.consultationId,
              ),
            ),
            (route) => false,
          );
          print("NAVIGATION CALLED");
        }

        return;
      }

      /// RAZORPAY
      openCheckout(response);
    }
  

      void openCheckout(
          VetPaymentModel paymentResponse) {

        currentOrderId =
            paymentResponse.razorpayOrderId;

        var options = {

          'key':
          paymentResponse.razorpayKey,

          'amount':
          paymentResponse.amount,

          'currency':
          paymentResponse.currency,

          'order_id':
          paymentResponse
              .razorpayOrderId,

          'name': 'Pawdli',

          'description':
          'Quick Consultation',

          'prefill': {

            'contact': '',

            'email': '',
          }
        };

        try {

          print(
              "RAZORPAY AMOUNT => ${paymentResponse.amount}"
            );

            print(
              "RAZORPAY ORDER ID => ${paymentResponse.razorpayOrderId}"
            );
          
          _razorpay.open(options);

        } catch (e) {

          Fluttertoast.showToast(
            msg: e.toString(),
          );
        }
      }

      void _handlePaymentSuccess(
            PaymentSuccessResponse response)
        async {

          final verifyResponse =
          await ApiService
              .verifyConsultationPayment(

            paymentTransactionId:
            paymentTransactionId!,

            razorpayOrderId:
            response.orderId,

            razorpayPaymentId:
            response.paymentId,

            razorpaySignature:
            response.signature,
          );

          if (verifyResponse != null &&
              verifyResponse.status == true) {

            print("RAZORPAY VERIFIED SUCCESS");
            print("CONSULTATION ID => ${widget.consultationId}");


            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorConnectingPage(
                  consultationId: widget.consultationId,
                ),
              ),
              (route) => false,
            );

            print("NAVIGATION CALLED");


          } else {

            Fluttertoast.showToast(
              msg: "Payment verification failed",
            );
          }
        }

        void _handlePaymentError(
            PaymentFailureResponse response) {

          Fluttertoast.showToast(

            msg:
            "Payment Failed",
          );
        }

        void _handleExternalWallet(
            ExternalWalletResponse response) {

          Fluttertoast.showToast(

            msg:
            response.walletName ?? "",
          );
        }

        void _removeCoupon() {
          if (!mounted) return;
          setState(() {
            couponApplied = false;

            discountAmount = 0;

            taxAmount = 0;

            consultationFee = totalAmount;

            appliedCouponCode = null;

            _couponController.clear();
          });
        }
}