import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pawlli/core/storage_manager/LocalStorageConstants.dart';
import 'dart:convert';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/app%20url.dart';
import 'package:pawlli/data/controller/ConsultationController.dart';
import 'package:pawlli/data/controller/DoctorconsultationController.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/homepage/homepage.dart';
import 'package:pawlli/presentation/screens/meet%20a%20vet/meetvetdoctor.dart';
import 'package:pawlli/presentation/screens/meet%20a%20vet/quick_appointment.dart/DoctorConsultationDetailsPage.dart';
import 'package:pawlli/presentation/screens/meet%20a%20vet/quick_appointment.dart/DoctorLiveConsultationPage.dart';
import 'package:pawlli/presentation/screens/meet%20a%20vet/quick_appointment.dart/PrescriptionPage.dart';
import 'package:pawlli/presentation/screens/meet%20a%20vet/quick_appointment.dart/UserConsultationDetailsPage.dart';
import 'package:pawlli/presentation/screens/meet%20a%20vet/quick_appointment.dart/petdetailspage.dart';
import 'package:url_launcher/url_launcher.dart';


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

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({Key? key}) : super(key: key);

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  final box = GetStorage();

  bool isDoctor = false;

  bool isOnline = false;

  bool isLoading = false;

  String selectedFilter = "all";

  // =========================================================
  // DOCTOR DATA
  // =========================================================

  int userId = 0;

  String doctorName = "";

  String doctorImage = "";

  String designation = "";

  String speciality = "";

  String clinicAddress = "";

  String consultationFee = "";

  List consultations = [];

  bool consultationLoading = false;

  final ConsultationController
    consultationController =
        Get.put(
          ConsultationController(),
        );


  @override
    void initState() {
      super.initState();

      print("APPOINTMENT PAGE OPENED");

      isDoctor =
          box.read(LocalStorageConstants.isDoctor) ?? false;

      print("IS DOCTOR : $isDoctor");

      _tabController = TabController(
        length: 2,
        vsync: this,
      );

      _tabController.addListener(() {
          setState(() {});
        });

      userId =
          LocalStorage.getUserId() ?? 0;

      print("DOCTOR UNIQUE ID : $userId");

      if (isDoctor == true) {

        print("CALLING DOCTOR PROFILE");

        getDoctorProfile();

        print("CALLING CONSULTATION API");

        getConsultationList();
      } else {
        
            consultationController.fetchConsultations();

      }
    }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get appBarTitle {

  if (isDoctor) {
    return "Doctor Dashboard";
  }

  return _tabController.index == 0
      ? "Appointment Mode"
      : "My Consultations";
}

    Future<void> downloadPrescription(
      String prescriptionUrl,
    ) async {

      try {

        print(
          "DOWNLOAD PRESCRIPTION STARTED",
        );

        String? token =
            await LocalStorage.getAccessToken();

        print("TOKEN => $token");

        final response =
            await http.get(

          Uri.parse(
            "${AppUrl.mainURL}$prescriptionUrl",
          ),

          headers: {
            "Authorization":
                "Bearer $token",
          },
        );

        print(
          "PDF STATUS => ${response.statusCode}",
        );

        if (response.statusCode == 200) {

          final dir =
              await getTemporaryDirectory();

          final file = File(
            "${dir.path}/prescription.pdf",
          );

          await file.writeAsBytes(
            response.bodyBytes,
          );

          print(
            "PDF SAVED => ${file.path}",
          );

          await OpenFilex.open(
            file.path,
          );

        } else {

          print(
            "PDF DOWNLOAD FAILED",
          );

          Get.snackbar(
            "Error",
            "Unable to download prescription",
          );
        }

      } catch (e) {

        print(
          "PRESCRIPTION ERROR => $e",
        );
      }
    }

  // =========================================================
  // GET ACCESS TOKEN
  // =========================================================

  Future<String?> getAccessToken() async {
    return await LocalStorage.getAccessToken();
  }

  // =========================================================
  // GET DOCTOR PROFILE API
  // =========================================================

  Future<void> getDoctorProfile() async {

    try {

      setState(() {
        isLoading = true;
      });

      String? accessToken = await getAccessToken();

      // print("ACCESS TOKEN : $accessToken");

      final url =
          "${AppUrl.mainURL}/user/doctor/profile/$userId/";

      print("PROFILE URL : $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      print("PROFILE STATUS CODE : ${response.statusCode}");

      print("PROFILE RESPONSE : ${response.body}");

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        final doctorData = data["data"];

        setState(() {

          doctorName =
              doctorData["full_name"] ?? "";

          doctorImage =
              doctorData["profile_image"] ?? "";

          designation =
              doctorData["designation"] ?? "";

          speciality =
              doctorData["speciality"] ?? "";

          clinicAddress =
              doctorData["clinic_address"] ?? "";

          consultationFee =
              doctorData["consultation_fee"].toString();

          isOnline =
              doctorData["active_status"] ?? false;
        });
      }

    } catch (e) {

      print("GET PROFILE ERROR : $e");

    } finally {

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getConsultationList() async {

    print("GET CONSULTATION STARTED");

    try {

      consultationLoading = true;

      setState(() {});

      String? accessToken =
          await getAccessToken();

      print("TOKEN : $accessToken");

      final url =
          "${AppUrl.mainURL}/user/consultation-list/";

      print("CONSULTATION URL : $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization":
              "Bearer $accessToken",
          "Content-Type":
              "application/json",
        },
      );

      print(
        "CONSULTATION STATUS : ${response.statusCode}",
      );

      print(
        "CONSULTATION BODY : ${response.body}",
      );

      if (response.statusCode == 200) {

        final data =
            jsonDecode(response.body);

        consultations =
            data["data"] ?? [];

        print(
          "TOTAL CONSULTATIONS : ${consultations.length}",
        );
      }

    } catch (e) {

      print(
        "CONSULTATION ERROR : $e",
      );

    } finally {

      consultationLoading = false;

      setState(() {});
    }
  }

  // =========================================================
  // TOGGLE API
  // =========================================================

  Future<void> toggleDoctorStatus() async {
    try {
      String? accessToken = await getAccessToken();

      final url =
          "${AppUrl.mainURL}/user/doctor/toggle-active/$userId/";

      print("TOGGLE URL : $url");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      print("TOGGLE STATUS CODE : ${response.statusCode}");
      print("TOGGLE RESPONSE : ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          isOnline = data["data"]["active_status"] ?? false;
        });

        final controller = Get.find<DoctorConsultationController>();

        if (isOnline) {
          print("🟢 Doctor is ONLINE");

          // Start listening for new consultation requests
          controller.startPolling();
        } else {
          print("🔴 Doctor is OFFLINE");

          // Stop listening for consultation requests
          controller.stopPolling();
        }
      }
    } catch (e) {
      print("TOGGLE ERROR : $e");
    }
  }

  Future<void>
    doctorAcceptConsultation(
        int consultationId) async {

      try {

        String? accessToken =
            await getAccessToken();

        final response =
            await http.post(

          Uri.parse(
            "${AppUrl.mainURL}/user/doctor-accept-consultation/",
          ),

          headers: {
            "Authorization":
                "Bearer $accessToken",
            "Content-Type":
                "application/json",
          },

          body: jsonEncode({
            "consultation_request_id":
                consultationId,
          }),
        );

        print(
          "ACCEPT RESPONSE : ${response.body}",
        );

        if (response.statusCode == 200) {

          final data =
              jsonDecode(response.body);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorLiveConsultationPage(),
            ),
          );
        }

      } catch (e) {

        print(
          "ACCEPT ERROR : $e",
        );
      }
    }

  // =========================================================
  // FILTERED APPOINTMENTS
  // =========================================================

  List get filteredAppointments {

    if (consultations.isEmpty) {
      return [];
    }

    List pending = consultations
        .where(
          (e) =>
              e["consultation_status"] ==
              "pending",
        )
        .toList();

    List completed = consultations
        .where(
          (e) =>
              e["consultation_status"] ==
              "completed",
        )
        .toList();

    List sortedList = [
      ...pending,
      ...completed,
    ];

    if (selectedFilter == "pending") {
      return sortedList
          .where(
            (e) =>
                e["consultation_status"] ==
                "pending",
          )
          .toList();
    }

    if (selectedFilter == "completed") {
      return sortedList
          .where(
            (e) =>
                e["consultation_status"] ==
                "completed",
          )
          .toList();
    }

    if (selectedFilter == "quick") {
      return sortedList
          .where(
            (e) =>
                e["consultation_type"] == 1,
          )
          .toList();
    }

    if (selectedFilter == "schedule") {
      return sortedList
          .where(
            (e) =>
                e["consultation_type"] == 2,
          )
          .toList();
    }

    return sortedList;
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colours.secondarycolour,
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colours.brownColour,
          ),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
              (route) => false,
            );
          },
        ),

        flexibleSpace: Stack(
          children: [
            SizedBox(
              height: 100,
              width: 250,
              child: Image.network(
                'https://app.pawdli.com/media/static/topimage.png',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),

        title: Text(
          appBarTitle.tr,
          style: TextStyle(
            fontSize: getResponsiveFont(context, 18),
            fontWeight: FontWeight.w600,
            fontFamily: FontFamily.Cairo,
            color: Colours.brownColour,
          ),
        ),

        foregroundColor: Colours.brownColour,

        actions: [
          if (isDoctor)
            Row(
              children: [
                Text(
                  isOnline ? "Online" : "Offline",
                  style: TextStyle(
                    color: isOnline
                        ? Colours.primarycolour
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: isOnline,
                  activeThumbColor: Colours.primarycolour,
                  onChanged: (value) {
                    toggleDoctorStatus();
                  },
                ),
              ],
            ),
        ],

        bottom: TabBar(
          controller: _tabController,
          labelColor: Colours.primarycolour,
          unselectedLabelColor: Colors.black,
          indicatorColor: Colours.primarycolour,
          tabs: isDoctor
              ? [
                  Tab(text: "Consultations"),
                  Tab(text: "Doctor"),
                ]
              : [
                  Tab(text: "Appointment Mode"),
                  Tab(text: "My Consultations"),
                ],
        ),
      ),

      body: Stack(
        children: [

          Column(
            children: [

              Expanded(

                child: isDoctor

                    // =====================================================
                    // DOCTOR UI
                    // =====================================================

                    ? TabBarView(

                        controller: _tabController,

                        children: [

                          Column(
                            children: [

                              Padding(
                                padding:
                                    const EdgeInsets.only(
                                  top: 12,
                                  right: 14,
                                ),

                                child: Row(

                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .end,

                                  children: [

                                    PopupMenuButton<String>(

                                      icon: Container(

                                        padding:
                                            const EdgeInsets
                                                .all(8),

                                        decoration:
                                            BoxDecoration(
                                          color:
                                              Colors.white,
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                                      12),
                                        ),

                                        child: const Icon(
                                          Icons.filter_list,
                                        ),
                                      ),

                                      onSelected: (value) {

                                        setState(() {
                                          selectedFilter =
                                              value;
                                        });
                                      },

                                      itemBuilder:
                                          (context) => [

                                        const PopupMenuItem(
                                          value: "all",
                                          child:
                                              Text("All"),
                                        ),

                                        const PopupMenuItem(
                                          value:
                                              "pending",
                                          child: Text(
                                              "Pending"),
                                        ),

                                        const PopupMenuItem(
                                          value:
                                              "completed",
                                          child: Text(
                                              "Completed"),
                                        ),

                                        const PopupMenuItem(
                                          value: "quick",
                                          child: Text(
                                              "Quick Consult"),
                                        ),

                                        const PopupMenuItem(
                                          value:
                                              "schedule",
                                          child: Text(
                                              "Schedule Consult"),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // =============================================
                              // consultations LIST
                              // =============================================

                              Expanded(

                                child: ListView.builder(

                                  padding:
                                      const EdgeInsets
                                          .all(14),

                                  itemCount:
                                    filteredAppointments.length,

                                  itemBuilder:
                                      (context, index) {


                                    print(
                                      "FILTERED LENGTH : ${filteredAppointments.length}",
                                    );

                                    print(
                                      "CURRENT INDEX : $index",
                                    );


                                    final appointment =
                                        filteredAppointments[index];

                                    final utcDate = DateTime.parse(
                                      appointment["created_at"],
                                    );

                                    final indianDate = utcDate.toLocal();

                                    final scheduleDate =
                                        DateFormat("dd-MM-yyyy")
                                            .format(indianDate);

                                    final scheduleTime =
                                        DateFormat("hh:mm a")
                                            .format(indianDate);
                                            

                                    bool isPending =
                                      appointment[
                                          "consultation_status"] ==
                                      "pending";

                                    return GestureDetector(

                                      onTap: () {

                                        if (appointment["prescription"] != null) {

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ConsultationDetailsPage(
                                                consultationData: appointment,
                                              ),
                                            ),
                                          );
                                        }
                                      },

                                      child: Container(

                                      margin:
                                          const EdgeInsets
                                              .only(
                                        bottom: 16,
                                      ),

                                      padding:
                                          const EdgeInsets
                                              .all(16),

                                      decoration:BoxDecoration(
                                        color:Colors.white,
                                        borderRadius:BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colours.brownColour,
                                          width: 1,
                                        ),
                                        // boxShadow: [
                                        //   BoxShadow(
                                        //     blurRadius: 8,
                                        //     color: Colors.black12,
                                        //   ),
                                        // ],
                                      ),

                                      child: Column(

                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,

                                        children: [

                                                Text(
                                                  "Appointment ID : ${appointment["consultation_request_id"]}",
                                                ),

                                                const SizedBox(
                                                    height:
                                                        8),

                                                Text(
                                                  "Appointment Type : ${appointment[
                                                      "consultation_type"
                                                      ] == 1
                                                          ? "Quick Consultation"
                                                          : "Scheduled Consultation"}",
                                                ),

                                                const SizedBox(
                                                    height:
                                                        8),

                                                Text(
                                                  "Pet Name : ${appointment["pet_name"]}",
                                                ),

                                                const SizedBox(
                                                    height:
                                                        8),

                                                Text(
                                                  "Consultation Date : $scheduleDate",
                                                ),

                                                const SizedBox(height: 8),

                                                Text(
                                                  "Consultation Time : $scheduleTime",
                                                ),

                                                const SizedBox(
                                                    height:
                                                        8),

                                                Text(
                                                  "Call Status : ${appointment["consultation_status"]}",
                                                  style:
                                                      TextStyle(
                                                    color:
                                                        isPending
                                                            ? Colors.orange
                                                            : Colors.black,

                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),

                                                const SizedBox(height: 20),

                                                  Align(
                                                    alignment: Alignment.center,
                                                    child: isPending

                                                        ? ElevatedButton(

                                                            style:
                                                                ElevatedButton.styleFrom(

                                                              backgroundColor:
                                                                  Colours.primarycolour,

                                                              foregroundColor:
                                                                  Colors.white,
                                                            ),

                                                            onPressed: () async {

                                                              await doctorAcceptConsultation(

                                                                appointment[
                                                                  "consultation_request_id"
                                                                ],
                                                              );
                                                            },

                                                            child: const Text(
                                                              "Join",
                                                            ),
                                                          )

                                                        : appointment["prescription"] == null

                                                            ? ElevatedButton(

                                                                style:
                                                                    ElevatedButton.styleFrom(

                                                                  backgroundColor:
                                                                      Colours.primarycolour,

                                                                  foregroundColor:
                                                                      Colors.white,
                                                                ),

                                                                onPressed: () async {

                                                                  final result = await Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (context) => PrescriptionPage(
                                                                        consultationRequestId:
                                                                            appointment["consultation_request_id"],
                                                                      ),
                                                                    ),
                                                                  );

                                                                  if (result == true) {
                                                                    getConsultationList();
                                                                  }
                                                                },

                                                                child: const Text(
                                                                  "Add Prescription",
                                                                ),
                                                              )

                                                            : ElevatedButton(

                                                                style:
                                                                    ElevatedButton.styleFrom(

                                                                  backgroundColor:
                                                                      Colours.primarycolour,

                                                                  foregroundColor:
                                                                      Colors.white,
                                                                ),

                                                                onPressed: () {

                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (context) => ConsultationDetailsPage(
                                                                        consultationData: appointment,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },

                                                                child: const Text(
                                                                  "View Details",
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

                          // =================================================
                          // DOCTOR TAB
                          // =================================================

                          isLoading

                              ? const Center(
                                  child:
                                      CircularProgressIndicator(),
                                )

                              : SingleChildScrollView(

                                  padding:
                                      const EdgeInsets
                                          .all(20),

                                  child: Column(
                                    children: [

                                      // =====================================
                                      // PROFILE CARD
                                      // =====================================

                                      Container(

                                        padding:
                                            const EdgeInsets
                                                .all(20),

                                        decoration:
                                            BoxDecoration(

                                          color:
                                              Colors.white,

                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                                      20),

                                          boxShadow: [

                                            BoxShadow(
                                              blurRadius:
                                                  10,

                                              color: Colors
                                                  .black12,
                                            ),
                                          ],
                                        ),

                                        child: Row(
                                          children: [

                                            CircleAvatar(

                                              radius: 35,

                                              backgroundImage:
                                                  doctorImage
                                                          .isNotEmpty
                                                      ? NetworkImage(
                                                          doctorImage,
                                                        )
                                                      : null,

                                              child: doctorImage
                                                      .isEmpty
                                                  ? const Icon(
                                                      Icons.person,
                                                      size:
                                                          40,
                                                    )
                                                  : null,
                                            ),

                                            const SizedBox(
                                                width: 16),

                                            Expanded(

                                              child: Column(

                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,

                                                children: [

                                                  Text(

                                                    doctorName
                                                            .isNotEmpty
                                                        ? doctorName
                                                        : "Doctor Name",

                                                    style:
                                                        TextStyle(
                                                      fontSize:
                                                          getResponsiveFont(
                                                              context,
                                                              16),

                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                      height:
                                                          6),

                                                  Text(
                                                    designation,
                                                    style:
                                                        TextStyle(
                                                      color: Colors
                                                              .grey[
                                                          700],
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                      height:
                                                          6),

                                                  Text(
                                                    speciality,
                                                    style:
                                                        TextStyle(
                                                      color: Colors
                                                              .grey[
                                                          700],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(
                                          height: 20),

                                    ],
                                  ),
                                ),
                        ],
                      )

                    // =====================================================
                    // NORMAL USER UI
                    // =====================================================

                    : TabBarView(
                      controller: _tabController,
                      children: [

                        // =====================================
                        // TAB 1 - APPOINTMENT MODE
                        // =====================================

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                          ),
                          child: Column(
                            children: [

                              const SizedBox(height: 100),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colours.primarycolour,
                                    padding:
                                        const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  onPressed: () {

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PetDetailsPage(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Quick Appointment", style: TextStyle(
                                      color: Colors.white,
                                      fontSize: getResponsiveFont(context, 16),

                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colours.brownColour,
                                    padding:
                                        const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  // onPressed: () {

                                  //   Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //       builder: (context) => MeetVetDoctorList(),
                                  //     ),
                                  //   );
                                  // },
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          title: const Text(
                                            "Coming Soon",
                                            textAlign: TextAlign.center,
                                          ),
                                          content: const Text(
                                            "Schedule Appointment feature is coming soon.",
                                            textAlign: TextAlign.center,
                                          ),
                                          actionsAlignment: MainAxisAlignment.center,
                                          actions: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colours.primarycolour,
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text("OK"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    "Schedule Appointment", style: TextStyle(
                                      color: Colors.white,
                                      fontSize: getResponsiveFont(context, 16),

                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // =====================================
                        // TAB 2 - MY CONSULTATIONS
                        // =====================================

                        Obx(() {

                          final consultationData =
                              consultationController.consultations;

                          if (consultationController.isLoading.value) {

                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (consultationData.isEmpty) {

                            return const Center(
                              child: Text(
                                "No Consultations Found",
                              ),
                            );
                          }

                          return ListView.builder(

                            padding: const EdgeInsets.all(14),

                            itemCount: consultationData.length,

                            itemBuilder: (context, index) {

                              final item =
                                  consultationData[index];

                              final consultationDate =
                                  item.createdAt != null
                                      ? DateTime.parse(
                                          item.createdAt!,
                                        ).toLocal()
                                      : DateTime.now();

                              final scheduleDate =
                                  DateFormat(
                                    "dd-MM-yyyy",
                                  ).format(
                                    consultationDate,
                                  );

                              final scheduleTime =
                                  DateFormat(
                                    "hh:mm a",
                                  ).format(
                                    consultationDate,
                                  );

                              bool isPending =
                                  item.consultationStatus ==
                                  "pending";

                              return Container(

                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colours.brownColour,
                                    width: 1,
                                  ),
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     blurRadius: 8,
                                  //     color: Colors.black12,
                                  //   ),
                                  // ],
                                ),

                                child: Column(

                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,

                                  children: [

                                    Text(
                                      "Appointment ID : ${item.consultationRequestId}",
                                    ),

                                    const SizedBox(
                                      height: 8,
                                    ),

                                    Text(
                                      "Appointment Type : ${item.consultationType == 1 ? "Quick Consultation" : "Scheduled Consultation"}",
                                    ),

                                    const SizedBox(
                                      height: 8,
                                    ),

                                    Text(
                                      "Pet Name : ${item.petName ?? ""}",
                                    ),

                                    const SizedBox(
                                      height: 8,
                                    ),

                                    Text(
                                      "Doctor : ${item.doctorName ?? ""}",
                                    ),

                                    const SizedBox(
                                      height: 8,
                                    ),

                                    Text(
                                      "Consultation Date : $scheduleDate",
                                    ),

                                    const SizedBox(
                                      height: 8,
                                    ),

                                    Text(
                                      "Consultation Time : $scheduleTime",
                                    ),

                                    const SizedBox(
                                      height: 8,
                                    ),

                                    Text(
                                      "Call Status : ${item.consultationStatus}",
                                      style: TextStyle(
                                        color: isPending
                                            ? Colors.orange
                                            : Colors.black,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 20,
                                    ),

                                    Row(

                                      children: [

                                        // Prescription Button

                                        Expanded(

                                          child: ElevatedButton.icon(

                                            style:
                                                ElevatedButton.styleFrom(

                                              backgroundColor:
                                                  Colors.green,

                                              foregroundColor:
                                                  Colors.white,
                                            ),

                                            onPressed:
                                              item.prescriptionDownloadUrl == null

                                                  ? null

                                                  : () async {

                                                      await downloadPrescription(

                                                        item.prescriptionDownloadUrl!,
                                                      );
                                                    },

                                            icon: const Icon(
                                              Icons.picture_as_pdf,
                                              color: Colors.white,
                                            ),

                                            label: const Text(
                                              "Prescription",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        // View Details Button

                                        Expanded(

                                          child: ElevatedButton(

                                            style:
                                                ElevatedButton.styleFrom(

                                              backgroundColor:
                                                  Colours.primarycolour,

                                              foregroundColor:
                                                  Colors.white,
                                            ),

                                            onPressed: () {

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => UserConsultationDetailsPage(
                                                    consultationData: item.toJson(),
                                                  ),
                                                ),
                                              );
                                            },

                                            child: const Text(
                                              "View Details",
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        })
                      ],
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}