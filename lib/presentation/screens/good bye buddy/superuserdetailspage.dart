import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/goodbyebuddylistcontroller.dart';
import 'package:pawlli/presentation/screens/good%20bye%20buddy/requestcompletedpage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

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

class SuperUserRequestDetailsPage extends StatefulWidget {
  final int requestId;

  const SuperUserRequestDetailsPage({super.key, required this.requestId});

  @override
  State<SuperUserRequestDetailsPage> createState() =>
      _SuperUserRequestDetailsPageState();
}

class _SuperUserRequestDetailsPageState
    extends State<SuperUserRequestDetailsPage> {
  final controller = Get.put(GoodbyeRequestDetailsController());

  String formatDateTime(String date) {
    try {
      final parsedDate = DateTime.parse(date).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  @override
  void initState() {
    super.initState();
    controller.fetchRequestDetails(widget.requestId);
  }

  Future<void> openMap(double lat, double lng) async {
    final Uri googleMapsUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      print("Could not open map");
    }
  }

  void shareDetails(BuildContext context) {
  final data = controller.requestDetails.value;

  final text = """
Request ID: ${data?.id}

Location: ${data?.location}

Landmark: ${data?.landmark}

Description:
${data?.description}

Map:
https://www.google.com/maps/search/?api=1&query=${data?.latitude},${data?.longitude}
""";

  final box = context.findRenderObject() as RenderBox;

  Share.share(
    text,
    sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60, // 🔥 increase height
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,

        /// 🔥 TOP IMAGE
        flexibleSpace: Stack(
          children: [
            SizedBox(
              height: 100,
              width: 250,
              child: Image.network(
                "https://pawlli-podcasts.s3.ap-south-1.amazonaws.com/static_images/topimage.png", // 🔴 change if your path different
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),

        /// 🔙 BACK BUTTON
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colours.brownColour),
          onPressed: () {
            Get.back();
          },
        ),

        /// 📝 TITLE
        title: Text(
          "Request Details".tr,
          style: TextStyle(
            fontSize: getResponsiveFont(context, 18),
            fontWeight: FontWeight.w600,
            color: Colours.brownColour,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.requestDetails.value;

        if (data == null) {
          return  Center(child: Text("No Data".tr));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// IMAGES
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.images?.length ?? 0,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12),
                itemBuilder: (context, index) {
                  final imagePath = data.images![index];

                  String finalUrl = "";

                  // ✅ CASE 1: Already full URL (WORKING)
                  if (imagePath.startsWith("http")) {
                    finalUrl = imagePath;
                  }

                  // ❌ CASE 2: API gives wrong/private folder
                  else if (imagePath.startsWith("goodbye_buddy_images")) {
                    final fileName = imagePath.split("/").last;

                    // 🔴 TRY BOTH PATHS (fallback logic)
                    finalUrl =
                        "https://pawlli-podcasts.s3.ap-south-1.amazonaws.com/goodbye_buddy/$fileName";
                  }

                  // 🔍 DEBUG
                  print("IMAGE PATH: $imagePath");
                  print("FINAL URL: $finalUrl");

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              backgroundColor: Colors.black,
                              insetPadding: EdgeInsets.zero,
                              child: Stack(
                                children: [
                                  /// FULL IMAGE + ZOOM
                                  InteractiveViewer(
                                    child: Center(
                                      child: Image.network(
                                        finalUrl,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),

                                  /// CLOSE BUTTON
                                  Positioned(
                                    top: 40,
                                    right: 20,
                                    child: IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.white, size: 30),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Image.network(
                          finalUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            print("IMAGE ERROR: $error");

                            if (!imagePath.startsWith("http")) {
                              final fallbackUrl =
                                  "https://pawlli-podcasts.s3.ap-south-1.amazonaws.com/$imagePath";

                              return Image.network(
                                fallbackUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) =>
                                    const Icon(Icons.broken_image, size: 40),
                              );
                            }

                            return const Icon(Icons.broken_image, size: 40);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              /// LOCATION DETAILS
               Text(
                "Location Details".tr,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: getResponsiveFont(context, 16)),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red),
                  const SizedBox(width: 10),
                  Expanded(child: Text(data.location ?? "", 
                  style: TextStyle(
                    fontSize: getResponsiveFont(context, 13),
                  ))),
                ],
              ),

              const SizedBox(height: 20),

              /// LANDMARK
               Text(
                "Landmark".tr,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: getResponsiveFont(context, 16)),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(Icons.location_pin, color: Colors.blue),
                  const SizedBox(width: 10),
                  Text(data.landmark ?? "",
                  style: TextStyle(
                    fontSize: getResponsiveFont(context, 13),
                  ),),
                ],
              ),

              const SizedBox(height: 20),

              /// NAVIGATE BUTTON
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                    backgroundColor: const Color(0xffE8D6B8)),
                onPressed: () {
                  openMap(data.latitude ?? 0, data.longitude ?? 0);
                },
                icon: const Icon(
                  Icons.navigation,
                  color: Colors.blue,
                ),
                label: Text(
                  "Navigate to Location".tr,
                  style: TextStyle(
                    fontSize: getResponsiveFont(context, 15),
                    color: Colours.brownColour,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// DESCRIPTION
               Text(
                "Description".tr,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: getResponsiveFont(context, 16)),
              ),

              const SizedBox(height: 6),

              Text(data.description ?? "",
              style: TextStyle(
                fontSize: getResponsiveFont(context, 13),
              )),

              const SizedBox(height: 20),

              /// CREATED DATE
               Text(
                "Created On".tr,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: getResponsiveFont(context, 16)),
              ),

              const SizedBox(height: 6),

              Text(
                formatDateTime(data.createdAt ?? ""),
                style: TextStyle(
                  fontSize: getResponsiveFont(context, 13),
                ),
              ),

              const SizedBox(height: 30),

              /// SHARE BUTTON
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    fixedSize: Size(MediaQuery.of(context).size.width * 0.6, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () => shareDetails(context),
                  child:  Text(
                    "Share Details".tr,
                    style: TextStyle(
                      fontSize: getResponsiveFont(context, 14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// COMPLETE BUTTON
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colours.primarycolour, // 🔥 your primary color
                    foregroundColor: Colors.white,
                    fixedSize: Size(MediaQuery.of(context).size.width * 0.8, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () {
                    Get.to(() => CompleteRequestPage(
                          requestId: widget.requestId,
                          location: data.location ?? "",
                        ));
                  },
                  child:  Text(
                    "Make Request Completed".tr,
                    style: TextStyle(
                      fontSize: getResponsiveFont(context, 15),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
