import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pawlli/core/storage_manager/LocalStorageConstants.dart';

import '../../../../core/storage_manager/colors.dart';
import '../../../../data/app url.dart';

class UserConsultationDetailsPage extends StatefulWidget {

  final Map<String, dynamic> consultationData;

  const UserConsultationDetailsPage({
    Key? key,
    required this.consultationData,
  }) : super(key: key);

  @override
  State<UserConsultationDetailsPage> createState() =>
      _UserConsultationDetailsPageState();
}

class _UserConsultationDetailsPageState
    extends State<UserConsultationDetailsPage> {

  String formatIndianDateTime(String? dateTime) {

    if (dateTime == null || dateTime.isEmpty) {
      return "-";
    }

    try {

      final utcTime =
          DateTime.parse(dateTime);

      final indianTime =
          utcTime.add(
        const Duration(
          hours: 5,
          minutes: 30,
        ),
      );

      return DateFormat(
        "dd MMM yyyy, hh:mm a",
      ).format(indianTime);

    } catch (e) {

      return dateTime;
    }
  }

  Future<void> downloadFile(
    String endpoint,
    String fileName,
  ) async {

    try {

      String? token =
          await LocalStorage.getAccessToken();

      final response =
          await http.get(

        Uri.parse(
          "${AppUrl.mainURL}$endpoint",
        ),

        headers: {
          "Authorization":
              "Bearer $token",
        },
      );

      if (response.statusCode == 200) {

        final dir =
            await getTemporaryDirectory();

        final file = File(
          "${dir.path}/$fileName",
        );

        await file.writeAsBytes(
          response.bodyBytes,
        );

        await OpenFilex.open(
          file.path,
        );

      } else {

        Get.snackbar(
          "Error",
          "Unable to download file",
        );
      }

    } catch (e) {

      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {

    final data =
        widget.consultationData;

    return Scaffold(

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
          "Consultation Details",
          style: TextStyle(
            color: Colours.brownColour,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ==================================================
            // PET DETAILS
            // ==================================================

            Container(

              width: double.infinity,

              padding:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(20),

                boxShadow: [

                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black12,
                  ),
                ],
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    "Pet Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Colours.primarycolour,
                    ),
                  ),

                  const Divider(),

                  Text(
                    "Consultation ID : ${data["consultation_request_id"]}",
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Pet Name : ${data["pet_name"]}",
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Pet Age : ${data["pet_age"]}",
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Pet Gender : ${data["pet_gender"]}",
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Breed : ${data["pet_breed"]}",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ==================================================
            // PET PROBLEM DETAILS
            // ==================================================

            Container(

              width: double.infinity,

              padding:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(20),

                boxShadow: [

                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black12,
                  ),
                ],
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    "Pet Problem Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Colours.primarycolour,
                    ),
                  ),

                  const Divider(),

                  Text(
                    "Status : ${data["consultation_status"]}",
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Symptoms : ${(data["symptoms"] ?? []).join(", ")}",
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Other Symptom : ${data["other_symptom"]}",
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Problem Description : ${data["problem_description"]}",
                  ),

                  const SizedBox(height: 15),

                  if ((data["issue_images"] ?? []).isNotEmpty) ...[

                    const Text(
                      "Issue Images",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      height: 100,

                      child: ListView.builder(

                        scrollDirection: Axis.horizontal,

                        itemCount:
                            data["issue_images"].length,

                        itemBuilder: (context, index) {

                          final image =
                              data["issue_images"][index];

                          return Container(

                            width: 100,

                            margin:
                                const EdgeInsets.only(
                              right: 10,
                            ),

                            child: ClipRRect(

                              borderRadius:
                                  BorderRadius.circular(12),

                              child: Image.network(

                                image["image"],

                                fit: BoxFit.cover,

                                errorBuilder:
                                    (context, error, stackTrace) {

                                  return const Icon(
                                    Icons.image_not_supported,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ==================================================
            // DOCTOR DETAILS
            // ==================================================

            Container(

              width: double.infinity,

              padding:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(20),

                boxShadow: [

                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black12,
                  ),
                ],
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    "Doctor Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Colours.primarycolour,
                    ),
                  ),

                  const Divider(),

                  Text(
                    "Doctor Name : ${data["doctor_name"]}",
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Speciality : ${data["doctor_speciality"]}",
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Consultation Fee : ₹${data["consultation_fee"]}",
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Session Start : ${formatIndianDateTime(data["session_start_time"])}",
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Session End : ${formatIndianDateTime(data["session_end_time"])}",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ==================================================
            // PAYMENT DETAILS
            // ==================================================

            Container(

              width: double.infinity,

              padding:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(20),

                boxShadow: [

                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black12,
                  ),
                ],
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    "Payment Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Colours.primarycolour,
                    ),
                  ),

                  const Divider(),

                  Text(
                    "Payment Type : ${data["payment_details"]?["payment_type"]}",
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Transaction Status : ${data["payment_details"]?["transaction_status"]}",
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Amount : ₹${data["payment_details"]?["transaction_amount"]}",
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Wallet Used : ₹${data["payment_details"]?["wallet_amount_used"]}",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==================================================
            // BUTTONS
            // ==================================================

            Row(

              children: [

                Expanded(

                  child: ElevatedButton.icon(

                    style:
                        ElevatedButton.styleFrom(

                      backgroundColor:
                          Colors.green,

                      minimumSize:
                          const Size(
                        double.infinity,
                        55,
                      ),

                      shape:
                          RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(
                          30,
                        ),
                      ),
                    ),

                    onPressed:
                        data["prescription_download_url"] ==
                                null
                            ? null
                            : () {

                                downloadFile(

                                  data[
                                      "prescription_download_url"],

                                  "prescription.pdf",
                                );
                              },

                    icon: const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.white,
                    ),

                    label: const Text(
                      "Prescription",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(

                  child: ElevatedButton.icon(

                    style:
                        ElevatedButton.styleFrom(

                      backgroundColor:
                          Colours.primarycolour,

                      minimumSize:
                          const Size(
                        double.infinity,
                        55,
                      ),

                      shape:
                          RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(
                          30,
                        ),
                      ),
                    ),

                    onPressed:
                        data["receipt_download_url"] ==
                                null
                            ? null
                            : () {

                                downloadFile(

                                  data[
                                      "receipt_download_url"],

                                  "receipt.pdf",
                                );
                              },

                    icon: const Icon(
                      Icons.receipt_long,
                      color: Colors.white,
                    ),

                    label: const Text(
                      "Receipt",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}