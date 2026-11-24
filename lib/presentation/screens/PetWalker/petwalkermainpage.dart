import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/PetWalker/walkerDetailsPage.dart';

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

class PetWalkerPage extends StatefulWidget {
  const PetWalkerPage({super.key});

  @override
  State<PetWalkerPage> createState() => _PetWalkerPageState();
}

class _PetWalkerPageState extends State<PetWalkerPage> {
  final List<Map<String, dynamic>> walkers = [
    {
      "name": "Kumar",
      "experience": "5 Years",
      "price": "₹299",
      "rating": "4.8",
      "location": "Bangalore",
      "image":
          "assets/images/applogo.png"
    },
    {
      "name": "Mouni",
      "experience": "3 Years",
      "price": "₹249",
      "rating": "4.7",
      "location": "Hyderabad",
      "image":
          "assets/images/applogo.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colours.secondarycolour,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          foregroundColor: Colours.brownColour,

          flexibleSpace: Stack(
            children: [
              SizedBox(
                width: 250,
                height: 100,
                child: Image.network(
                  "https://app.pawdli.com/media/static/topimage.png",
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),

          title: Text(
            "Pet Walker",
            style: TextStyle(
              fontSize: getResponsiveFont(context, 18),
              fontFamily: FontFamily.Cairo,
              fontWeight: FontWeight.w600,
              color: Colours.brownColour,
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search Location",
                  hintStyle: TextStyle(
                    fontFamily: FontFamily.Cairo,
                    color: Colours.brownColour,
                  ),
                  prefixIcon: Icon(
                    Icons.location_on,
                    color: Colours.primarycolour,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              children: [
                serviceChip("Daily Walk"),
                serviceChip("Exercise Walk"),
                serviceChip("Training Walk"),
                serviceChip("Senior Walk"),
              ],
            ),
          ),

          const SizedBox(height: 15),

          Expanded(
            child: ListView.builder(
              itemCount: walkers.length,
              itemBuilder: (context, index) {
                final walker = walkers[index];

                final backgroundImage = index.isEven
                    ? "https://app.pawdli.com/media/static/yellowcard.png"
                    : "https://app.pawdli.com/media/static/browncard.png";

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => WalkerDetailsPage());
                    },
                    child: Stack(
                      children: [
                        SizedBox(
                          width: screenWidth,
                          height: screenHeight * 0.22,
                          child: Image.network(
                            backgroundImage,
                            fit: BoxFit.fill,
                          ),
                        ),

                        Positioned(
                          left: screenWidth * 0.07,
                          top: screenHeight * 0.02,
                          right: screenWidth * 0.35,
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                walker["name"],
                                style: TextStyle(
                                  fontFamily:
                                      FontFamily.Cairo,
                                  color: Colours
                                      .secondarycolour,
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize:
                                      getResponsiveFont(
                                          context, 16),
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "⭐ ${walker["rating"]}",
                                style: TextStyle(
                                  fontFamily:
                                      FontFamily.Cairo,
                                  color: Colours
                                      .secondarycolour,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "Experience : ${walker["experience"]}",
                                style: TextStyle(
                                  fontFamily:
                                      FontFamily.Cairo,
                                  color: Colours
                                      .secondarycolour,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "Location : ${walker["location"]}",
                                style: TextStyle(
                                  fontFamily:
                                      FontFamily.Cairo,
                                  color: Colours
                                      .secondarycolour,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colours
                                      .primarycolour,
                                  borderRadius:
                                      BorderRadius.circular(
                                          20),
                                ),
                                child: Text(
                                  walker["price"],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextButton(
                                onPressed: () {
                                  Get.to(() => WalkerDetailsPage());
                                },
                                child: Text(
                                  "More Details",
                                  style: TextStyle(
                                    fontFamily:
                                        FontFamily.Cairo,
                                    fontSize:
                                        getResponsiveFont(
                                            context, 14),
                                    fontWeight:
                                        FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Positioned(
                          right: screenWidth * 0.06,
                          bottom: screenHeight * 0.04,
                          child: CircleAvatar(
                            radius: screenWidth * 0.12,
                            backgroundColor:
                                Colors.transparent,
                            backgroundImage:
                                NetworkImage(
                              walker["image"],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget serviceChip(String title) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: Chip(
        backgroundColor: Colours.primarycolour,
        label: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: FontFamily.Cairo,
          ),
        ),
      ),
    );
  }
}