import 'package:flutter/material.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/pettheraphycontroller.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:pawlli/presentation/screens/meet%20a%20vet/meetvetslot.dart';
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

class MeetVetDoctorList extends StatefulWidget {
  const MeetVetDoctorList({Key? key}) : super(key: key);

  @override
  State<MeetVetDoctorList> createState() => _MeetVetDoctorListState();
}

class _MeetVetDoctorListState extends State<MeetVetDoctorList> {
  DateTime _selectedDate = DateTime.now();
  late final PetTherapyController controller;
  bool _showCalendar = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(PetTherapyController());
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final controller = Get.put(PetTherapyController());

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
                  'Meet Vet Doctors'.tr,
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
                actions: [
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    color: Colours.brownColour,
                    onPressed: () {
                      setState(() {
                        _showCalendar = !_showCalendar;
                      });
                    },
                  ),
                ],
              ),

              // Selected date text
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

              // Calendar toggle
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
                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                  ),
                ),

              // Doctor list
              if (!_showCalendar)
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.pets.isEmpty) {
                      return  Center(child: Text('No doctors available'.tr, style: TextStyle(
                        fontSize: getResponsiveFont(context, 14),
                      )));
                    }

                    return ListView.builder(
                      itemCount: controller.pets.length,
                      itemBuilder: (context, index) {
                        final pet = controller.pets[index];
                        final backgroundImage = index.isEven
                            ? 'https://pawlli-podcasts.s3.ap-south-1.amazonaws.com/static_images/yellowcard.png'
                            : 'https://pawlli-podcasts.s3.ap-south-1.amazonaws.com/static_images/browncard.png';

                        return buildDoctorCard(
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
    );
  }

  Widget buildDoctorCard(
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
              builder: (context) => Meetvetslot(
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
              child: Image.network(backgroundImage, fit: BoxFit.fill),
            ),
            Positioned(
              left: screenWidth * 0.07,
              top: screenHeight * 0.010,
              right: screenWidth * 0.30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name ?? "Unknown".tr,
                    style: TextStyle(
                      color: Colours.secondarycolour,
                      fontFamily: FontFamily.Cairo,
                      fontSize: getResponsiveFont(context, 16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
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
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: screenWidth * 0.06,
                          color: Colours.secondarycolour),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          pet.location ?? "Clinic".tr,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colours.secondarycolour,
                            fontFamily: FontFamily.Cairo,
                            fontSize: getResponsiveFont(context, 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    "Tap to book a session with this doctor!".tr,
                    style: TextStyle(
                      color: Colours.secondarycolour,
                      fontFamily: FontFamily.Cairo,
                      fontSize: getResponsiveFont(context, 12),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            if (pet.image != null)
              Positioned(
                right: screenWidth * 0.08,
                bottom: screenHeight * 0.010,
                child: CircleAvatar(
                  radius: screenWidth * 0.13,
                  backgroundColor: Colors.transparent,
                  backgroundImage: NetworkImage(pet.image!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
