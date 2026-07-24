import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/TherapyBookingController.dart';
import 'package:pawlli/data/controller/pettheraphycontroller.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/pet%20therapy/TherapyBookingListPage.dart';
import 'package:pawlli/presentation/screens/pet%20therapy/TherapyPetDetails.dart';
import 'package:pawlli/presentation/screens/pet%20therapy/pet_therapy_slot.dart';
import 'package:intl/intl.dart';

import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

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

class PetTherapy extends StatefulWidget {
  const PetTherapy({Key? key}) : super(key: key);

  @override
  State<PetTherapy> createState() => _PetTherapyState();
}

class _PetTherapyState extends State<PetTherapy>
    with SingleTickerProviderStateMixin {

  DateTime _selectedDate = DateTime.now();
  late final PetTherapyController controller;
  late TabController _tabController;
  final bookingController =
      Get.put(TherapyBookingController());

  String pageTitle = "Pet Therapy";

  bool _showCalendar = false;

  @override
  void initState() {
    super.initState();

    controller = Get.put(PetTherapyController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPetTherapies(
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      );
    });

    _tabController = TabController(
      length: 2,
      vsync: this,
    );

    _tabController.addListener(() {

      if (_tabController.index == 0) {

        setState(() {
          pageTitle = "Pet Therapy";
        });

      } else {

        setState(() {
          pageTitle = "Booking List";
        });

        bookingController.fetchBookings();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // final controller = Get.put(PetTherapyController());

    return Scaffold(

      backgroundColor: Colours.secondarycolour,

      appBar: PreferredSize(

        preferredSize: const Size.fromHeight(110),

        child: AppBar(

          toolbarHeight: 60,

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
            pageTitle.tr,
            style: TextStyle(
              fontSize: getResponsiveFont(context, 18),
              fontWeight: FontWeight.w600,
              fontFamily: FontFamily.Cairo,
              color: Colours.brownColour,
            ),
          ),

          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              color: Colours.brownColour,
              onPressed: () {

                if (_tabController.index != 0) {

                  _tabController.animateTo(0);

                }

                setState(() {
                  pageTitle = "Pet Therapy";
                  _showCalendar = true;
                });

              },
            ),
          ],

          bottom: TabBar(

            controller: _tabController,

            indicatorColor: Colours.primarycolour,

            labelColor: Colours.primarycolour,

            unselectedLabelColor: Colors.black,

            tabs: const [

              Tab(text: "Pet Therapy"),

              Tab(text: "Booking List"),

            ],

          ),

        ),

      ),

      body: TabBarView(

        controller: _tabController,

        children: [

          _petTherapyTab(),

          TherapyBookingListPage(),

        ],

      ),

    );
    }

    Widget _petTherapyTab() {

      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      return SafeArea(
        top: false,
        child: Column(
        children: [
          // 👇 Show selected date
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Selected Date: ${DateFormat.yMMMMd().format(_selectedDate)}'.tr,
                  style: TextStyle(
                    fontSize: getResponsiveFont(context, 14),
                    fontWeight: FontWeight.w500,
                    fontFamily: FontFamily.Cairo,
                    color: Colours.brownColour,
                  ),
                ),
              ),

          // 👇 Show calendar only when icon is tapped
              if (_showCalendar)
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _selectedDate,
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDate = selectedDay;
                      _showCalendar = false;
                    });

                    // 🔑 Reload pets for this date
                    final formattedDate =
                        DateFormat('yyyy-MM-dd').format(selectedDay);
                    controller.fetchPetTherapies(date: formattedDate);
                  },
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Colours.primarycolour,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colours.brownColour.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                  ),
                ),

              // Pet list (only when calendar is hidden)
              if (!_showCalendar)
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.pets.isEmpty) {
                      return  Center(child: Text(
                        'No pets available'.tr,
                        style: TextStyle(
                          fontSize: getResponsiveFont(context, 14),
                        ),
                      ));
                    }

                    return ListView.builder(
                      itemCount: controller.pets.length,
                      itemBuilder: (context, index) {
                        final pet = controller.pets[index];
                        final backgroundImage = index.isEven
                            ? 'https://app.pawdli.com/media/static/yellowcard.png'
                            : 'https://app.pawdli.com/media/static/browncard.png';

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
      );
    }

  Widget buildPetCard(
    BuildContext context,
    double screenWidth,
    double screenHeight,
    dynamic pet,
    String backgroundImage,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PetTherapySlot(
                petid: pet.id,
                selectedDate: _selectedDate,
              ),
            ),
          );
        },
        child: Stack(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight * 0.20,
              child: Image.network(
                backgroundImage,
                fit: BoxFit.fill,
                loadingBuilder: (
                  context,
                  child,
                  loadingProgress,
                ) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.red,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: screenWidth * 0.07,
              top: screenHeight * 0.010,
              right: screenWidth * 0.30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: FontFamily.Cairo,
                        fontSize: getResponsiveFont(context, 14),
                        color: Colours.secondarycolour,
                      ),
                      children: [
                        const TextSpan(
                          text: "Pet Name : ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: pet.name ?? "-",
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 2),

                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: FontFamily.Cairo,
                        fontSize: getResponsiveFont(context, 13),
                        color: Colours.secondarycolour,
                      ),
                      children: [
                        const TextSpan(
                          text: "Vaccination : ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: pet.vaccinationStatus ?? "-",
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 2),

                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: FontFamily.Cairo,
                        fontSize: getResponsiveFont(context, 13),
                        color: Colours.secondarycolour,
                      ),
                      children: [
                        const TextSpan(
                          text: "Available : ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: "${pet.availableStartDate ?? "-"} to ${pet.availableEndDate ?? "-"}",
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 2),

                  RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: FontFamily.Cairo,
                        fontSize: getResponsiveFont(context, 13),
                        color: Colours.secondarycolour,
                      ),
                      children: [
                        const TextSpan(
                          text: "Location : ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: pet.location ?? "-",
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TherapyPetDetailsPage(
                              pet: pet,
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        "More Details",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: getResponsiveFont(context, 15),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (pet.coverImage != null)
              Positioned(
                right: screenWidth * 0.08,
                bottom: screenHeight * 0.050,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TherapyPetDetailsPage(
                          pet: pet,
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: screenWidth * 0.12,
                    backgroundColor: Colors.transparent,
                    child: CachedNetworkImage(
                      imageUrl: pet.coverImage!,
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        radius: screenWidth * 0.13,
                        backgroundImage: imageProvider,
                      ),
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

class ImageGalleryScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ImageGalleryScreen({
    Key? key,
    required this.images,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  late PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: _currentIndex);
  }

  void _nextPage() {
    if (_currentIndex < widget.images.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title:  Text(
          "Gallery".tr,
          style: TextStyle(
            fontSize: getResponsiveFont(context, 16),
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (_, index) {
              return Center(
                child: InteractiveViewer(
                  child: CachedNetworkImage(
                    imageUrl: widget.images[index],
                    fit: BoxFit.contain,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.broken_image,
                          color: Colors.white, size: 50),
                    ),
                  ),
                ),
              );
            },
          ),

          // ⬅️ Show Back only if not on first image
          if (_currentIndex > 0)
            Positioned(
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 32, color: Colors.white),
                onPressed: _prevPage,
              ),
            ),

          // ➡️ Show Next only if not on last image
          if (_currentIndex < widget.images.length - 1)
            Positioned(
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 32, color: Colors.white),
                onPressed: _nextPage,
              ),
            ),
        ],
      ),
    );
  }
}
