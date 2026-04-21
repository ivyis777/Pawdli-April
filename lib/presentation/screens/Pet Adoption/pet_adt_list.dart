import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart' as storage;
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/useradoptioncontroller.dart';
import 'package:pawlli/data/model/useradoptionmodel.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/Pet%20Adoption/addpetadoption.dart';
import 'package:pawlli/presentation/screens/Pet%20Adoption/editpetadoption.dart';
import 'package:pawlli/presentation/screens/userprofile/userprofile.dart';

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

class AdoptionPets extends StatefulWidget {
  final bool fromUpdateFlow;
  const AdoptionPets({Key? key, this.fromUpdateFlow = false}) : super(key: key);

  @override
  _AdoptionPetsState createState() => _AdoptionPetsState();
}

class _AdoptionPetsState extends State<AdoptionPets> {
  final UserAdoptionController _controller = Get.put(UserAdoptionController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchUserAdoptionPetList();
    }); // Fetch API on load
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
        onWillPop: () async {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (_) => ProfilePage(fromUpdateFlow: true)),
            (route) => true,
          );
          return false;
        },
        child: Scaffold(
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
                      'Adoptions'.tr,
                      style: TextStyle(
                        fontSize: getResponsiveFont(context, 18),
                        fontWeight: FontWeight.w600,
                        fontFamily: FontFamily.Cairo,
                        color: Colours.brownColour,
                      ),
                    ),
                    foregroundColor: Colours.brownColour,
                    centerTitle: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  Expanded(
                    child: Obx(() {
                      if (_controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (_controller.adoptionPets.isEmpty) {
                        return  Center(child: Text(
                          "No pets found.".tr,
                          style: TextStyle(
                            fontSize: getResponsiveFont(context, 14),
                          ),
                        ));
                      }

                      final sortedPets = [..._controller.adoptionPets];
                      sortedPets.sort((a, b) {
                        final aSold = a.isSoldout ?? false;
                        final bSold = b.isSoldout ?? false;
                        if (aSold == bSold) return 0;
                        return aSold ? 1 : -1;
                      });

                      return ListView.builder(
                        itemCount: sortedPets.length,
                        itemBuilder: (context, index) {
                          final pet = sortedPets[index];

                          final backgroundImage = index.isEven
                              ? 'https://pawlli-podcasts.s3.ap-south-1.amazonaws.com/static_images/yellowcard.png'
                              : 'https://pawlli-podcasts.s3.ap-south-1.amazonaws.com/static_images/browncard.png';

                          return buildPetCard(
                            context,
                            screenWidth,
                            screenHeight,
                            pet,
                            backgroundImage,
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddPetAdoption()),
              );
            },
            backgroundColor: Colors.brown[600],
            child: Icon(Icons.add, color: Colours.secondarycolour),
          ),
        ));
  }

  String getPetAge(UserAdoptionModel pet) {
    // ✅ 1. AGE OBJECT FROM API
    if (pet.ageDetails != null) {
      final y = pet.ageDetails!.years ?? 0;
      final m = pet.ageDetails!.months ?? 0;
      final d = pet.ageDetails!.days ?? 0;

      return "Age | ${y}y ${m}m ${d}d".tr;
    }

    // ✅ 2. FALLBACK TO DOB
    if (pet.dateOfBirth != null && pet.dateOfBirth!.isNotEmpty) {
      try {
        final dob = DateTime.parse(pet.dateOfBirth!);
        final now = DateTime.now();

        int years = now.year - dob.year;
        int months = now.month - dob.month;

        if (now.day < dob.day) months--;
        if (months < 0) {
          years--;
          months += 12;
        }

        return "Age | ${years}y ${months}m".tr;
      } catch (_) {
        return "Age | N/A".tr;
      }
    }

    return "Age | N/A".tr;
  }

  Widget buildPetCard(
    BuildContext context,
    double screenWidth,
    double screenHeight,
    UserAdoptionModel pet,
    String backgroundImage,
  ) {
    final bool isSold = pet.isSoldout == true;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: IgnorePointer(
        ignoring: isSold, // Freeze if sold
        child: Opacity(
          opacity: isSold ? 0.6 : 1.0, // Dim if sold
          child: GestureDetector(
            onTap: () {
              final petId = pet.id;
              if (petId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditAdoptionPetPage(Id: petId),
                  ),
                );
              } else {
                Get.snackbar("Error", "Pet ID is missing.".tr);
              }
              print(petId);
            },
            child: Stack(
              children: [
                Container(
                  width: screenWidth,
                  height: screenHeight * 0.20,
                  child: Image.network(
                    backgroundImage,
                    fit: BoxFit.fill,
                  ),
                ),
                if (isSold)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'SOLD OUT'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: getResponsiveFont(context, 12),
                          fontWeight: FontWeight.bold,
                          fontFamily: FontFamily.Cairo,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: screenWidth * 0.07,
                  top: screenHeight * 0.015,
                  right: screenWidth * 0.30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isSold
                                ? "Sold".tr
                                : (pet.mobileNumber ?? "Not Provided".tr),
                            style: TextStyle(
                              color: Colours.secondarycolour,
                              fontFamily: FontFamily.Cairo,
                              fontSize: getResponsiveFont(context, 16),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.04),
                          Text(
                            getPetAge(pet), // ✅ SINGLE AGE
                            style: TextStyle(
                              color: Colours.secondarycolour,
                              fontFamily: FontFamily.Cairo,
                              fontSize: getResponsiveFont(context, 13),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        pet.isFree == true
                            ? "Type: Free".tr
                            : pet.isPaid == true
                                ? "Type: Paid".tr
                                : "Type: Not specified".tr,
                        style: TextStyle(
                          color: Colours.secondarycolour,
                          fontFamily: FontFamily.Cairo,
                          fontSize: getResponsiveFont(context, 13),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pet.description ?? "No description".tr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colours.secondarycolour,
                          fontFamily: FontFamily.Cairo,
                          fontSize: getResponsiveFont(context, 13),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 18,
                              color: Colours.secondarycolour),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              pet.location ?? "Unknown".tr,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colours.secondarycolour,
                                fontFamily: FontFamily.Cairo,
                                fontSize: getResponsiveFont(context, 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (pet.petProfileImage != null &&
                    pet.petProfileImage!.isNotEmpty)
                  Positioned(
                    right: screenWidth * 0.06,
                    bottom: screenHeight * 0.022,
                    child: CircleAvatar(
                      radius: screenWidth * 0.15,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage:
                          CachedNetworkImageProvider(pet.petProfileImage!),
                      onBackgroundImageError: (_, __) {}, // prevent crash
                    ),
                  )
                else
                  Positioned(
                    right: screenWidth * 0.06,
                    bottom: screenHeight * 0.022,
                    child: CircleAvatar(
                      radius: screenWidth * 0.15,
                      backgroundColor: Colors.grey.shade200,
                      child: Icon(
                        Icons.pets, // fallback icon 🐾
                        size: screenWidth * 0.12,
                        color: Colours.brownColour,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
