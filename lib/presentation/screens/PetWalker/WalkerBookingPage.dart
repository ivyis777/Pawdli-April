import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/PetWalker/WalkerBookingSuccessPage.dart';

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

class WalkerBookingPage extends StatefulWidget {
  const WalkerBookingPage({super.key});

  @override
  State<WalkerBookingPage> createState() => _WalkerBookingPageState();
}

class _WalkerBookingPageState extends State<WalkerBookingPage> {
  String selectedPet = "Bruno";
  String selectedDuration = "30 Min";
  String selectedTime = "09:00 AM";

  DateTime selectedDate = DateTime.now();

  final addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colours.secondarycolour,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
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
            "Book Pet Walk",
            style: TextStyle(
              fontFamily: FontFamily.Cairo,
              color: Colours.brownColour,
              fontSize: getResponsiveFont(context, 18),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// Walker Card
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [

                  CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage(
                      "https://images.unsplash.com/photo-1500648767791-00dcc994a43",
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(
                          "John Walker",
                          style: TextStyle(
                            fontFamily: FontFamily.Cairo,
                            fontWeight: FontWeight.bold,
                            color: Colours.brownColour,
                            fontSize:
                                getResponsiveFont(context, 16),
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text("⭐ 4.8"),

                        const SizedBox(height: 4),

                        Text(
                          "₹299 Per Walk",
                          style: TextStyle(
                            color: Colours.primarycolour,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            buildSectionTitle(
              context,
              "Select Pet",
            ),

            buildDropdown(
              value: selectedPet,
              items: const [
                "Bruno",
                "Rocky",
                "Tommy",
              ],
              onChanged: (value) {
                setState(() {
                  selectedPet = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            buildSectionTitle(
              context,
              "Select Date",
            ),

            buildDateCard(),

            const SizedBox(height: 20),

            buildSectionTitle(
              context,
              "Select Time",
            ),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                timeChip("09:00 AM"),
                timeChip("11:00 AM"),
                timeChip("02:00 PM"),
                timeChip("04:00 PM"),
                timeChip("06:00 PM"),
              ],
            ),

            const SizedBox(height: 20),

            buildSectionTitle(
              context,
              "Walk Duration",
            ),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                durationChip("30 Min"),
                durationChip("60 Min"),
                durationChip("90 Min"),
              ],
            ),

            const SizedBox(height: 20),

            buildSectionTitle(
              context,
              "Pickup Address",
            ),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(15),
              ),
              child: TextField(
                controller: addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.all(15),
                  hintText: "Enter Address",
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// Booking Summary

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(18),
              ),
              child: Column(
                children: [

                  buildSummaryRow(
                    "Walker",
                    "Kumar",
                  ),

                  buildSummaryRow(
                    "Pet",
                    selectedPet,
                  ),

                  buildSummaryRow(
                    "Duration",
                    selectedDuration,
                  ),

                  buildSummaryRow(
                    "Date",
                    "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
                  ),

                  const Divider(),

                  buildSummaryRow(
                    "Total Amount",
                    "₹299",
                    isBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colours.primarycolour,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  Get.to(() => WalkerBookingSuccessPage());
                },
                child: Text(
                  "Confirm Booking",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: FontFamily.Cairo,
                    fontWeight: FontWeight.bold,
                    fontSize:
                        getResponsiveFont(context, 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(
      BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding:
            const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: FontFamily.Cairo,
            color: Colours.brownColour,
            fontWeight: FontWeight.bold,
            fontSize:
                getResponsiveFont(context, 16),
          ),
        ),
      ),
    );
  }

  Widget buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget buildDateCard() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
        );

        if (picked != null) {
          setState(() {
            selectedDate = picked;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month,
              color: Colours.primarycolour,
            ),
            const SizedBox(width: 10),
            Text(
              "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
            ),
          ],
        ),
      ),
    );
  }

  Widget timeChip(String value) {
    bool selected = selectedTime == value;

    return ChoiceChip(
      label: Text(value),
      selected: selected,
      selectedColor:
          Colours.primarycolour,
      labelStyle: TextStyle(
        color: selected
            ? Colors.white
            : Colours.brownColour,
      ),
      onSelected: (_) {
        setState(() {
          selectedTime = value;
        });
      },
    );
  }

  Widget durationChip(String value) {
    bool selected = selectedDuration == value;

    return ChoiceChip(
      label: Text(value),
      selected: selected,
      selectedColor:
          Colours.primarycolour,
      labelStyle: TextStyle(
        color: selected
            ? Colors.white
            : Colours.brownColour,
      ),
      onSelected: (_) {
        setState(() {
          selectedDuration = value;
        });
      },
    );
  }

  Widget buildSummaryRow(
    String title,
    String value, {
    bool isBold = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight:
                  isBold ? FontWeight.bold : null,
              color: isBold
                  ? Colours.primarycolour
                  : Colours.brownColour,
            ),
          ),
        ],
      ),
    );
  }
}