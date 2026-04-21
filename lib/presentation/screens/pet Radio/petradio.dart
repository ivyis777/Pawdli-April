import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/allpetradiocontroller.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/pawlli%20radio/pawlli_radio.dart';

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

class Petradio extends StatefulWidget {
  const Petradio({super.key});

  @override
  State<Petradio> createState() => _PetradioState();
}

class _PetradioState extends State<Petradio> {
  final AllPetRadioController _petRadioController =
      Get.put(AllPetRadioController());
  final TextEditingController _searchController = TextEditingController();
  bool isBrownBackground = false;
  bool isBrownRadio = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _petRadioController.fetchRadioStations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
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
          Column(
            children: [
              PreferredSize(
                preferredSize: Size.fromHeight(screenHeight * 0.12),
                child: AppBar(
                  title: Text(
                    'PAWdLI Radio Stations'.tr,
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
              Expanded(
                child: Obx(() {
                  if (_petRadioController.isLoading.value) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (_petRadioController.petRadioList.isEmpty) {
                    return Center(
                      child: Text(
                        "No Pet Radios Available".tr,
                        style: TextStyle(
                          fontSize: getResponsiveFont(context, 14),
                          fontFamily: FontFamily.Cairo,
                          color: Colours.black,
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _petRadioController.petRadioList.length,
                          itemBuilder: (context, index) {
                            final radioData =
                                _petRadioController.petRadioList[index];
                            String backgroundImage = isBrownBackground
                                ? 'https://pawlli-podcasts.s3.ap-south-1.amazonaws.com/static_images/yellowcard.png'
                                : 'https://pawlli-podcasts.s3.ap-south-1.amazonaws.com/static_images/browncard.png';

                            String radioImage = isBrownRadio
                                ? 'https://pawlli-podcasts.s3.ap-south-1.amazonaws.com/static_images/brownradio.png'
                                : 'https://pawlli-podcasts.s3.ap-south-1.amazonaws.com/static_images/radio.png';

                            isBrownBackground = !isBrownBackground;
                            isBrownRadio = !isBrownRadio;

                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.001,
                                vertical: screenHeight * 0.01,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PawlliRadio(
                                        radioid: radioData.radiostationId,
                                        radioname: radioData.name.toString(),
                                      ),
                                    ),
                                  );
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      width: screenWidth,
                                      height: screenHeight * 0.20,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(backgroundImage),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: screenWidth * 0.65,
                                      bottom: screenHeight * 0.01,
                                      child: Image.network(
                                        radioImage,
                                        width: screenWidth * 0.3,
                                        height: screenHeight * 0.2,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    Positioned(
                                      left: screenWidth * 0.4,
                                      top: screenHeight * 0.025,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: screenWidth * 0.5,
                                            child: Text(
                                              radioData.name ?? "Default Name".tr,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: FontFamily.Cairo,
                                                fontSize: getResponsiveFont(context, 16),
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap:
                                                  true,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          SizedBox(
                                            width: screenWidth * 0.5,
                                            child: Text(
                                              radioData.description ??
                                                  "Default Description".tr,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: FontFamily.Cairo,
                                                fontSize: getResponsiveFont(context, 13),
                                                fontWeight: FontWeight.w400,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          // Row(
                                          //   children: [
                                          //     Icon(Icons.public, color: Colors.white, size: screenWidth * 0.05),
                                          //     SizedBox(width: 5),
                                          //     Text(
                                          //      radioData.language ?? "Default Laugauage" ,
                                          //       style: TextStyle(
                                          //         color: Colors.white,
                                          //         fontFamily: FontFamily.Cairo,
                                          //         fontSize: screenWidth * 0.04,
                                          //         fontWeight: FontWeight.w500,
                                          //       ),
                                          //     ),

                                          //   ],
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: screenHeight * 0.2),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
