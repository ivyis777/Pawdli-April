import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/model/pettheraphymodel.dart';
import 'package:pawlli/gen/fonts.gen.dart';

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

class TherapyPetDetailsPage extends StatefulWidget {
  final PetTherapy pet;

  const TherapyPetDetailsPage({
    Key? key,
    required this.pet,
  }) : super(key: key);

  @override
  State<TherapyPetDetailsPage> createState() => _TherapyPetDetailsPageState();
}

class _TherapyPetDetailsPageState extends State<TherapyPetDetailsPage> {
  
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
    void initState() {
      super.initState();

      _pageController = PageController();

      _timer = Timer.periodic(
        const Duration(seconds: 2),
        (timer) {
          if (!mounted) return;

          if (widget.pet.images == null ||
              widget.pet.images!.isEmpty) {
            return;
          }

          if (_currentIndex < widget.pet.images!.length - 1) {
            _currentIndex++;
          } else {
            _currentIndex = 0;
          }

          _pageController.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        },
      );
    }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(

      backgroundColor: Colors.white,

      // appBar: AppBar(

      //   backgroundColor: Colors.white,

      //   elevation: 0,

      //   foregroundColor: Colours.brownColour,

      //   centerTitle: true,

      //   title: Text(
      //     widget.pet.name ?? "Pet Details",
      //     style: TextStyle(
      //       color: Colours.brownColour,
      //       fontWeight: FontWeight.bold,
      //       fontFamily: FontFamily.Cairo,
      //       fontSize: getResponsiveFont(context, 18),
      //     ),
      //   ),
      // ),

      body: Column(
        children: [

          Stack(
            children: [

              Container(
                width: MediaQuery.of(context).size.width * 0.55,
                height: MediaQuery.of(context).size.height * 0.10,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      "https://app.pawdli.com/media/static/topimage.png",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                foregroundColor: Colours.brownColour,

                title: Text(
                  widget.pet.name ?? "Pet Details",
                  style: TextStyle(
                    color: Colours.brownColour,
                    fontWeight: FontWeight.bold,
                    fontFamily: FontFamily.Cairo,
                    fontSize: getResponsiveFont(context, 18),
                  ),
                ),
              ),

            ],
          ),

          Expanded(
            child: SingleChildScrollView(

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 15),

            /// IMAGE SLIDER
            SizedBox(

              height: 250,

              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.pet.images?.length ?? 0,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(

                    padding: const EdgeInsets.symmetric(horizontal: 15),

                    child: ClipRRect(

                      borderRadius: BorderRadius.circular(18),

                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierColor: Colors.black,
                            builder: (dialogContext) {
                              return Dialog(
                                backgroundColor: Colors.black,
                                insetPadding: EdgeInsets.zero,
                                child: Stack(
                                  children: [
                                    Center(
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: double.infinity,
                                        child: PageView.builder(
                                          controller: PageController(initialPage: index),
                                          itemCount: widget.pet.images!.length,
                                          itemBuilder: (context, pageIndex) {
                                            return InteractiveViewer(
                                              minScale: 1,
                                              maxScale: 5,
                                              child: CachedNetworkImage(
                                                imageUrl: widget.pet.images![pageIndex],
                                                fit: BoxFit.contain,
                                                placeholder: (context, url) =>
                                                    const Center(child: CircularProgressIndicator()),
                                                errorWidget: (context, url, error) =>
                                                    const Icon(Icons.error, color: Colors.white),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 40,
                                      right: 20,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                        onPressed: () {
                                          Navigator.of(dialogContext).pop(); 
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: CachedNetworkImage(
                          imageUrl: widget.pet.images![index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) =>
                              const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.pets),
                        ),
                      )
                    ),
                  );

                },
              ),
            ),

            const SizedBox(height: 15),

            /// PAGE INDICATOR

            Row(

              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: List.generate(

                widget.pet.images?.length ?? 0,

                (index) {

                  return AnimatedContainer(

                    duration: const Duration(
                        milliseconds: 250),

                    margin:
                        const EdgeInsets.symmetric(
                            horizontal: 4),

                    height: 10,

                    width:
                        _currentIndex == index
                            ? 22
                            : 10,

                    decoration: BoxDecoration(

                      color:
                          _currentIndex == index
                              ? Colours.primarycolour
                              : Colors.grey.shade400,

                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

                        Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                widget.pet.name ?? "",
                style: TextStyle(
                  fontSize: getResponsiveFont(context, 24),
                  fontWeight: FontWeight.bold,
                  color: Colours.brownColour,
                  fontFamily: FontFamily.Cairo,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                widget.pet.description ?? "",
                style: TextStyle(
                  fontSize: getResponsiveFont(context, 15),
                  height: 1.6,
                  color: Colors.black87,
                  fontFamily: FontFamily.Cairo,
                ),
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                "Pet Information",
                style: TextStyle(
                  fontSize: getResponsiveFont(context, 20),
                  fontWeight: FontWeight.bold,
                  color: Colours.brownColour,
                ),
              ),
            ),

            const SizedBox(height: 15),

            buildInfoCard(
              Icons.location_on,
              "Location",
              widget.pet.location ?? "-",
            ),

            buildInfoCard(
              Icons.cake,
              "Age",
              "${widget.pet.age ?? "-"} Years",
            ),

            buildInfoCard(
              Icons.pets,
              "Gender",
              widget.pet.gender ?? "-",
            ),

            buildInfoCard(
              Icons.health_and_safety,
              "Vaccination",
              widget.pet.vaccinationStatus ?? "-",
            ),

            buildInfoCard(
              Icons.favorite,
              "Specialization",
              widget.pet.petSpecialization ?? "-",
            ),

            buildInfoCard(
              Icons.emoji_events,
              "Therapy Sessions",
              "${widget.pet.therapySessionsCompleted ?? 0}",
            ),

            buildInfoCard(
              Icons.calendar_month,
              "Available From",
              widget.pet.availableStartDate ?? "-",
            ),

            buildInfoCard(
              Icons.event_available,
              "Available To",
              widget.pet.availableEndDate ?? "-",
            ),

            const SizedBox(height: 30),

            //             Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 18),
            //   child: SizedBox(
            //     width: double.infinity,
            //     height: 55,
            //     child: ElevatedButton.icon(
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: Colours.primarycolour,
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(14),
            //         ),
            //       ),
            //       icon: const Icon(
            //         Icons.calendar_today,
            //         color: Colors.white,
            //       ),
            //       label: Text(
            //         "Book Therapy",
            //         style: TextStyle(
            //           fontSize: getResponsiveFont(context, 16),
            //           color: Colors.white,
            //           fontWeight: FontWeight.bold,
            //           fontFamily: FontFamily.Cairo,
            //         ),
            //       ),
            //       onPressed: () {
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //             builder: (_) => PetTherapySlot(
            //               petid: widget.pet.id,
            //               selectedDate: DateTime.now(),
            //             ),
            //           ),
            //         );
            //       },
            //     ),
            //   ),
            // ),

            const SizedBox(height: 30),
          ],
        ),
      ), 
    ),  
  ],    
),     
); 
  }

  Widget buildInfoCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 7,
      ),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colours.primarycolour.withOpacity(.15),
            child: Icon(
              icon,
              color: Colours.primarycolour,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: TextStyle(
                    fontSize: getResponsiveFont(context, 14),
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: TextStyle(
                    fontSize: getResponsiveFont(context, 16),
                    fontWeight: FontWeight.bold,
                    color: Colours.brownColour,
                    fontFamily: FontFamily.Cairo,
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