import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart' as storage;
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';

import 'package:pawlli/data/controller/petslistcontroller.dart';
import 'package:pawlli/presentation/screens/chat1to1/chatui.dart';

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

class Petswitch extends StatefulWidget {
  final int receiverId;
  final String receiverImage;
  final String receiverName;
  const Petswitch(
      {super.key,
      required this.receiverId,
      required this.receiverImage,
      required this.receiverName});
  @override
  _PetswitchState createState() => _PetswitchState();
}

class _PetswitchState extends State<Petswitch> {
  int? userId;
  final Petslistcontroller petsController = Get.put(Petslistcontroller());

  @override
  void initState() {
    super.initState();
    final box = storage.GetStorage();
    userId = box.read(LocalStorageConstants.userId);

    if (userId != null) {
      // Defer the loading until after the first frame is rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        petsController.loadUserPets(userId!);
      });
    } else {
      print("User ID is null");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colours.secondarycolour,
      body: Stack(
        children: [
          Container(
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
          Column(
            children: [
              AppBar(
                title: Text(
                  'Select Buddy 🐾'.tr,
                  style: TextStyle(
                    fontSize: getResponsiveFont(context, 18),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                    color: Colors.brown,
                  ),
                ),
                foregroundColor: Colors.brown,
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              SizedBox(height: 30),
              Expanded(
                child: Obx(() {
                  if (petsController.isLoading.value) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (petsController.errorMessage.isNotEmpty) {
                    return Center(
                      child: Text(
                        petsController.errorMessage.value,
                        style:
                            TextStyle(color: Colours.brownColour, fontSize: getResponsiveFont(context, 14)),
                      ),
                    );
                  }
                  if (petsController.userPets.isEmpty) {
                    return Center(
                      child: Text(
                        "No pets found".tr,
                        style: TextStyle(fontSize: getResponsiveFont(context, 14), color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    itemCount: petsController.userPets.length,
                    itemBuilder: (context, index) {
                      final pet = petsController.userPets[index];

                      // Alternating background images
                      String backgroundImage = index.isEven
                          ? 'https://pawlli-podcasts.s3.ap-south-1.amazonaws.com/static_images/yellowcard.png'
                          : 'https://pawlli-podcasts.s3.ap-south-1.amazonaws.com/static_images/browncard.png';

                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              print("Tapped on pet: ${pet.name}");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Chat1to1(
                                    receiverId: widget.receiverId.toString(),
                                    receiverName:
                                        widget.receiverName ?? "Unknown Pet".tr,
                                    petProfileImage: widget.receiverImage ?? "",
                                    petId: pet.petId!,
                                  ),
                                ),
                              );
                            },
                            child: _buildAvatarWithBackground(
                              MediaQuery.of(context).size.width,
                              MediaQuery.of(context).size.height,
                              backgroundImage,
                              (() {
                                String? petImagePath = pet.petProfileImage;
                                String? fullPetImage = (petImagePath != null)
                                    ? '$petImagePath'
                                    : null;
                                return fullPetImage ?? ''; // fallback for null
                              })(),
                              pet.name ?? "Unknown".tr,
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarWithBackground(
    double screenWidth,
    double screenHeight,
    String backgroundImage,
    String petImage,
    String name,
  ) {
    return Container(
      width: screenWidth,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Card background
          Image.network(
            backgroundImage,
            width: screenWidth,
            fit: BoxFit.cover,
          ),

          // Pet avatar + name
          Positioned(
            left: 20,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colours.secondarycolour.withOpacity(0.2),
                  radius: screenWidth * 0.1,
                  backgroundImage:
                      (petImage.isNotEmpty && petImage.startsWith('http'))
                          ? CachedNetworkImageProvider(petImage)
                          : null,
                  child: (petImage.isEmpty || !petImage.startsWith('http'))
                      ? Icon(
                          Icons.pets, // 🐾 fallback
                          size: screenWidth * 0.08,
                          color: Colours.brownColour,
                        )
                      : null,
                ),
                SizedBox(width: 20),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: getResponsiveFont(context, 16),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
