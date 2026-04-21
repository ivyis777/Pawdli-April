import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/model/paymentverificationmodel.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/homepage/homepage.dart';

double getResponsiveFont(BuildContext context, double size) {
  double screenWidth = MediaQuery.of(context).size.width;

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

class TherapyPaymentfailure extends StatefulWidget {
  final String orderId;
  final String paymentId;
  final String signature;
  final PaymentVerificationModel? paymentVerifiedModel;

  const TherapyPaymentfailure({
    super.key,
    required this.orderId,
    required this.paymentId,
    required this.signature,
    this.paymentVerifiedModel,
  });

  @override
  State<TherapyPaymentfailure> createState() => _TherapyPaymentfailureState();
}

class _TherapyPaymentfailureState extends State<TherapyPaymentfailure> {
  late String amount;
  late String orderId;
  late String date;
  late String paymentMethod;
  late String message;
  @override
  void initState() {
    super.initState();

    final paymentData = widget.paymentVerifiedModel;
    debugPrint("🔹 Received Payment Data: $paymentData");

    amount = (paymentData?.amount != null && paymentData!.amount! > 0)
        ? "₹ ${paymentData.amount}"
        : '₹ 0.00';

    orderId = paymentData?.orderId ?? widget.orderId;
    date = paymentData?.date ?? 'Date not available';
    paymentMethod = paymentData?.paymentMethod ?? 'Method not available';
    message =
        widget.paymentVerifiedModel?.message ?? 'Payment Verification Failed';

    debugPrint(
        "✅ Final Assigned Values -> Amount: $amount, Order ID: $orderId, Date: $date, Payment Method: $paymentMethod, Message: $message");
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Stack(children: [
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: screenWidth * 0.55,
          height: screenHeight * 0.10,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  'https://pawlli-podcasts.s3.ap-south-1.amazonaws.com/static_images/topimage.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      Column(children: [
        PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.12),
          child: AppBar(
            title: Text(
              'Payment'.tr,
              style: TextStyle(
                fontSize: getResponsiveFont(context, 18),
                fontWeight: FontWeight.w600,
                fontFamily: FontFamily.Cairo,
                color: Colours.black,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.1),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colours.secondarycolour,
                    borderRadius: BorderRadius.circular(36.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8.0,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.red,
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Center(
                          child: Text(
                            message,
                            style: TextStyle(
                              fontSize: getResponsiveFont(context, 14),
                              fontWeight: FontWeight.w300,
                              color: Colours.black,
                              fontFamily: FontFamily.Ubantu,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Center(
                          child: Text(
                            amount, // ✅ Display amount
                            style: TextStyle(
                              fontSize: getResponsiveFont(context, 18),
                              fontWeight: FontWeight.bold,
                              color: Colours.black,
                              fontFamily: FontFamily.Ubantu,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.025),
                        Divider(color: Colours.textColour, thickness: 1.0),
                        SizedBox(height: screenHeight * 0.025),
                        _buildInfoRow('Ref Number:'.tr, orderId, screenHeight),
                        _buildInfoRow('Date:'.tr, date, screenHeight),
                        _buildInfoRow(
                            'Payment Method:'.tr, paymentMethod, screenHeight),
                        SizedBox(height: screenHeight * 0.017),
                        Align(
                          alignment: Alignment
                              .center, // Moves the button towards the right
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomePage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(screenWidth * 0.8, 50),
                              backgroundColor: Colours.primarycolour,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              "Retry".tr,
                              style: TextStyle(
                                fontSize: getResponsiveFont(context, 16),
                                fontWeight: FontWeight.w600,
                                color: Colours.secondarycolour,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.017),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ])
    ]));
  }

  Widget _buildInfoRow(String label, String value, double screenHeight) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenHeight * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: getResponsiveFont(context, 13),
              color: Colours.darkgreyColour,
              fontWeight: FontWeight.w400,
              fontFamily: FontFamily.Ubantu,
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty
                  ? value
                  : 'N/A', // Adding a fallback if value is empty
              style: TextStyle(
                fontSize: getResponsiveFont(context, 13),
                fontWeight: FontWeight.w400,
                color: Colours.textColour,
                fontFamily: FontFamily.Ubantu,
              ),
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
