import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/TherapyBookingController.dart';
import 'package:pawlli/data/model/therapySuperUsermodel.dart';

class SuperTherapyBookingDetailsPage extends StatefulWidget {
  final SuperTherapyBookingData booking;

  const SuperTherapyBookingDetailsPage({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  State<SuperTherapyBookingDetailsPage> createState() => _SuperTherapyBookingDetailsPageState();
}

class _SuperTherapyBookingDetailsPageState extends State<SuperTherapyBookingDetailsPage> {
  late String selectedStatus;
  final controller = Get.find<TherapyBookingController>();

  @override
    void initState() {
      super.initState();

      final status = widget.booking.bookingStatus ?? "Booked";

      if (status == "Booked" ||
          status == "Completed" ||
          status == "Cancelled") {
        selectedStatus = status;
      } else {
        selectedStatus = "Booked";
      }
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   foregroundColor: Colours.brownColour,
      //   elevation: 0,
      //   title: const Text(
      //     "Booking Details",
      //     style: TextStyle(fontWeight: FontWeight.bold),
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

          title: const Text(
            "Booking Details",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

      ],
    ),

    Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: widget.booking.therapyImage != null &&
                      widget.booking.therapyImage!.isNotEmpty
                  ? Image.network(
                      widget.booking.therapyImage!,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 220,
                          width: double.infinity,
                          color: Colors.grey.shade300,
                          child: const Icon(
                            Icons.pets,
                            size: 70,
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 220,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.pets,
                        size: 70,
                      ),
                    ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Text(
                widget.booking.therapyName ?? "",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            buildCard("Booking ID", "${widget.booking.bookingId}"),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Expanded(
                    flex: 2,
                    child: Text(
                      "Status",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "Payment Pending",
                          child: Text("Payment Pending"),
                        ),

                        DropdownMenuItem(
                          value: "Booked",
                          child: Text("Booked"),
                        ),

                        DropdownMenuItem(
                          value: "Cancelled",
                          child: Text("Cancelled"),
                        ),

                        DropdownMenuItem(
                          value: "Completed",
                          child: Text("Completed"),
                        ),

                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedStatus = value;
                          });
                        }
                      },
                    ),
                    
                  ),
                ],
              ),
            ),

   

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colours.primarycolour,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {

                  if (widget.booking.bookingId == null) {
                    Get.snackbar(
                      "Error",
                      "Invalid booking ID",
                      snackPosition: SnackPosition.TOP,
                    );
                    return;
                  }

                  final success = await controller.updateBookingStatus(
                    bookingId: widget.booking.bookingId!,
                    status: selectedStatus,
                  );

                  if (success) {

                    Get.snackbar(
                      "Success",
                      "Booking status updated successfully.",
                      snackPosition: SnackPosition.TOP,
                    );

                    await controller.fetchBookings();

                    Navigator.pop(context, true);

                  } else {

                    Get.snackbar(
                      "Error",
                      "Failed to update booking status.",
                      snackPosition: SnackPosition.TOP,
                    );

                  }
                },
                child: const Text(
                  "Update Status",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "User Information",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            buildCard("User ID", "${widget.booking.userId}"),
            buildCard("Name", widget.booking.userName ?? "-"),
            buildCard("Username", widget.booking.username ?? "-"),
            buildCard("Email", widget.booking.email ?? "-"),
            buildCard("Mobile", widget.booking.mobile ?? "-"),
            buildCard("Gender", widget.booking.gender ?? "-"),
            buildCard("Age", "${widget.booking.age ?? ""}"),
            buildCard("Address", widget.booking.address ?? "-"),
            buildCard("City", widget.booking.city ?? "-"),
            buildCard("State", widget.booking.state ?? "-"),
            buildCard("Country", widget.booking.country ?? "-"),
            buildCard("Pincode", "${widget.booking.pincode ?? ""}"),

            buildCard(
              "Booking First Name",
              widget.booking.bookingFirstName ?? "-",
            ),

            buildCard(
              "Booking Last Name",
              widget.booking.bookingLastName ?? "-",
            ),

            buildCard(
              "Booking Phone",
              widget.booking.bookingPhoneNumber ?? "-",
            ),

            buildCard(
              "Booking Address",
              widget.booking.bookingAddress ?? "-",
            ),

            const SizedBox(height: 20),

            const Text(
              "Pet Information",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            buildCard("Pet ID", "${widget.booking.pettherapyId}"),
            buildCard("Pet Name", widget.booking.therapyName ?? "-"),
            buildCard("Description", widget.booking.description ?? "-"),
            buildCard("Location", widget.booking.location ?? "-"),
            buildCard("Landmark", widget.booking.landmark ?? "-"),
            buildCard("Age", widget.booking.petAge ?? "-"),
            buildCard("Gender", widget.booking.petGender ?? "-"),
            buildCard(
              "Vaccination",
              widget.booking.vaccinationStatus ?? "-",
            ),
            buildCard(
              "Specialization",
              widget.booking.petSpecialization ?? "-",
            ),

            const SizedBox(height: 20),

            const Text(
              "Slot Information",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            buildCard("Slot ID", "${widget.booking.slot?.slotId ?? ""}"),
            buildCard("Date", widget.booking.slot?.date ?? "-"),
            buildCard("Start Time", widget.booking.slot?.startTime ?? "-"),
            buildCard("End Time", widget.booking.slot?.endTime ?? "-"),
            buildCard("Amount", widget.booking.slot?.amount ?? "-"),
            buildCard(
              "Booked",
              widget.booking.slot?.isBooked == true ? "Yes" : "No",
            ),

            const SizedBox(height: 20),

            const Text(
              "Payment Information",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            buildCard("Amount", widget.booking.paymentAmount ?? "-"),
            buildCard(
              "Paid",
              widget.booking.isPaid == true ? "Yes" : "No",
            ),
            buildCard(
              "Free",
              widget.booking.isFree == true ? "Yes" : "No",
            ),
            buildCard("Payment ID", widget.booking.paymentId ?? "-"),
            buildCard(
              "Razorpay Order ID",
              widget.booking.razorpayOrderId ?? "-",
            ),

            const SizedBox(height: 20),

            const Text(
              "Therapy Information",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            buildCard(
              "Mode",
              widget.booking.therapyMode ?? "-",
            ),

            buildCard(
              "Therapy Type",
              widget.booking.therapyType ?? "-",
            ),

            buildCard(
              "Previous Pet Therapy",
              widget.booking.previousPetTherapy ?? "-",
            ),

            buildCard(
              "Previous Therapy Details",
              widget.booking.previousPetTherapyDetails ?? "-",
            ),

            buildCard(
              "Therapy Description",
              widget.booking.therapyDescription ?? "-",
            ),

            buildCard(
              "Breed / Pet Type",
              widget.booking.breedOrPetType ?? "-",
            ),

            const SizedBox(height: 20),

            const Text(
              "Organization Information",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            buildCard(
              "Organization Name",
              widget.booking.organizationName ?? "-",
            ),

            buildCard(
              "Group Count",
              "${widget.booking.groupCount ?? "-"}",
            ),

            buildCard(
              "Student Count",
              "${widget.booking.studentCount ?? "-"}",
            ),

            buildCard(
              "Employee Count",
              "${widget.booking.employeeCount ?? "-"}",
            ),

            buildCard(
              "Languages",
              widget.booking.languages == null ||
                      widget.booking.languages!.isEmpty
                  ? "-"
                  : widget.booking.languages!.join(", "),
            ),

            buildCard(
              "Created At",
              widget.booking.createdAt ?? "-",
            ),

            const SizedBox(height: 30),

        
                    ],
        ),
      ), // SingleChildScrollView
    ),   // Expanded
  ],     // Column children
),       // Column
);       // Scaffold
}


  Widget buildCard(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),

        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
          )
        ],
      ),

      child: Row(
        children: [

          Expanded(
            flex: 2,

            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            flex: 3,

            child: Text(value),
          ),

        ],
              ),
    );
  }
}