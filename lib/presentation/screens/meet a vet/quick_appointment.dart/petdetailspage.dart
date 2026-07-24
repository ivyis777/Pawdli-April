import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/controller/QuickConsultationController.dart';
import 'package:pawlli/data/model/petslistmodel.dart' show Data;
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/add%20pet/addpet.dart';
import 'package:pawlli/presentation/screens/meet%20a%20vet/quick_appointment.dart/confirmslot.dart';
import 'package:pawlli/presentation/screens/meet%20a%20vet/quick_appointment.dart/symptomspage.dart';

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

class PetDetailsPage extends StatefulWidget {
  const PetDetailsPage({super.key});

  @override
  State<PetDetailsPage> createState() =>_PetDetailsPageState();
}

class _PetDetailsPageState extends State<PetDetailsPage> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final QuickConsultationController consultationController =
    Get.put(
      QuickConsultationController(),
      permanent: true,
    );

  /// CONTROLLERS
  final TextEditingController
      _petNameController =
      TextEditingController();

  final TextEditingController
      _ageController =
      TextEditingController();

  final TextEditingController
      _petTypeController =
      TextEditingController();

  final TextEditingController
      _breedController =
      TextEditingController();

  final TextEditingController
      _problemController =
      TextEditingController();

  /// GENDER
  String _selectedGender = 'Male';
  bool showPetDetails = false;

  /// IMAGE PICKER
  final ImagePicker _picker = ImagePicker();

  List<XFile>? _imageFiles;

  /// PET LIST
  List<Data> petsList = [];

  Data? selectedPet;

  bool isLoadingPets = false;

  /// ADD PET MODE
  bool isAddPet = false;

  /// READ ONLY
  bool isReadOnly = false;

  /// SYMPTOMS
  List<String> selectedSymptoms = [];

  List<String> selectedSymptomIds = [];

  @override
  void initState() {
    super.initState();

    getPetsList();
  }

  /// FETCH PETS
  Future<void> getPetsList() async {

    setState(() {
      isLoadingPets = true;
    });

    try {

      final response =
          await ApiService.fetchUserPets(null);

      if (response != null &&
          response.data != null) {

        setState(() {
          petsList = response.data!;
        });
      }

    } catch (e) {

      print("GET PETS ERROR : $e");
    }

    setState(() {
      isLoadingPets = false;
    });
  }

  /// FILL PET DETAILS
  void fillPetDetails(Data pet) {

    _petNameController.text =
        pet.name ?? '';

    if (pet.age != null) {

      final years =
          pet.age!.years ?? 0;

      final months =
          pet.age!.months ?? 0;

      _ageController.text =
          "$years Years $months Months";
    }

    _selectedGender =
        pet.gender ?? 'Male';

    _petTypeController.text =
        pet.categoryName ?? '';

    _breedController.text =
        pet.subcategoryName ?? '';

    isReadOnly = true;

    setState(() {});
  }

  /// CLEAR FIELDS
  void clearFields() {

    _petNameController.clear();

    _ageController.clear();

    _petTypeController.clear();

    _breedController.clear();

    _problemController.clear();

    _selectedGender = 'Male';

    selectedSymptoms.clear();

    _imageFiles = [];

    isReadOnly = false;

    setState(() {});
  }

  /// PICK IMAGES
  Future<void> _pickImage() async {

    final List<XFile>? pickedFiles =
        await _picker.pickMultiImage();

    if (pickedFiles != null &&
        pickedFiles.isNotEmpty) {

      setState(() {

        _imageFiles ??= [];

        _imageFiles!.addAll(
          pickedFiles,
        );
      });
    }
  }

  /// CAMERA
  Future<void> _takePhoto() async {

    final XFile? photo =
        await _picker.pickImage(
      source: ImageSource.camera,
    );

    if (photo != null) {

      setState(() {
        _imageFiles = [...?_imageFiles, photo];
      });
    }
  }

  /// IMAGE OPTIONS
  void _showImageSourceOptions() {

    showModalBottomSheet(
      context: context,

      builder: (context) {

        return Container(
          padding: const EdgeInsets.all(16),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [

              Text(
                "Select Image Source",

                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: FontFamily.Cairo,
                ),
              ),

              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(Icons.image),

                title: const Text("Gallery"),

                onTap: () {

                  Navigator.pop(context);

                  _pickImage();
                },
              ),

              ListTile(
                leading: const Icon(Icons.camera),

                title: const Text("Camera"),

                onTap: () {

                  Navigator.pop(context);

                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// REMOVE IMAGE
  void _removeImage(int index) {

    setState(() {
      _imageFiles!.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {

    final screenHeight =
        MediaQuery.of(context).size.height;

    return GestureDetector(

      onTap: () {
        FocusScope.of(context).unfocus();
      },

      child: Scaffold(

        backgroundColor:
            Colours.secondarycolour,

        appBar: AppBar(
          toolbarHeight: 60,
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,

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

          foregroundColor: Colours.brownColour,

          title: Text(
            "Quick Consultation",
            style: TextStyle(
              fontSize: getResponsiveFont(context, 18),
              fontWeight: FontWeight.w600,
              fontFamily: FontFamily.Cairo,
              color: Colours.brownColour,
            ),
          ),
        ),

        body: SingleChildScrollView(

          child: Padding(
            padding:
                const EdgeInsets.all(16),

          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                /// DROPDOWN
                Text(
                  "Select Pet",

                  style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
                ),

                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(

                  color: Colors.white,
                  
                  borderRadius:
                      BorderRadius.circular(15),

                  border: Border.all(
                    color: Colours.primarycolour
                        .withOpacity(0.4),
                  ),
                ),

                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),

                    child:
                        DropdownButtonHideUnderline(

                      child:
                          DropdownButton<dynamic>(

                        value: selectedPet,

                        isExpanded: true,

                        hint: Text(

                          "Select Existing Pet",

                          style: TextStyle(
                            fontSize:
                                getResponsiveFont(
                                    context,
                                    14),
                            color:
                                Colors.black54,
                          ),
                        ),


                        items: [

                          ...petsList.map((pet) {

                            return DropdownMenuItem<
                                dynamic>(

                              value: pet,

                              child: Text(
                                pet.name ?? '',
                              ),
                            );
                          }),

                          const DropdownMenuItem(
                            value: "add_pet",

                            child: Text(
                              "+ Add Pet",
                            ),
                          ),
                        ],

                        onChanged: (value) {

                          if (value == "add_pet") {

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddPetPage(),
                              ),
                            ).then((_) {
                              // Refresh the pet list when returning
                              getPetsList();
                            });

                            return;
                          }

                          if (value != null) {
                            isAddPet = false;
                            showPetDetails = true;

                            selectedPet = value;

                            fillPetDetails(value);
                          }
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

              if (showPetDetails)
                isAddPet
                    ? Column(
                        children: [

                /// PET NAME
                _buildTextFieldCard(
                  controller:
                      _petNameController,

                  hintText:
                      "Enter Pet Name",

                  label: "Pet Name",

                  readOnly: isReadOnly,
                ),

                const SizedBox(height: 16),

                /// AGE + GENDER
                Row(
                  children: [

                    Expanded(
                      child:
                          _buildTextFieldCard(
                        controller:
                            _ageController,

                        hintText:
                            "Enter Age",

                        label: "Age",

                        readOnly:
                            isReadOnly,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child:
                          _buildDropdownCard(
                        value:
                            _selectedGender,

                        label: "Gender",

                        items: [
                          'Male',
                          'Female',
                          'Other'
                        ],

                        onChanged:
                            isReadOnly
                                ? null
                                : (value) {

                                    setState(() {

                                      _selectedGender =
                                          value!;
                                    });
                                  },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// PET TYPE
                _buildTextFieldCard(
                  controller:
                      _petTypeController,

                  hintText:
                      "Enter Pet Type",

                  label: "Pet Type",

                  readOnly: isReadOnly,
                ),

                const SizedBox(height: 16),

                /// BREED
                _buildTextFieldCard(
                  controller:
                      _breedController,

                  hintText:
                      "Enter Breed",

                  label: "Pet Breed",

                  readOnly: isReadOnly,
                ),
              ],
            )
          : Container(

              padding:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(15),

                border: Border.all(
                  color: Colours.primarycolour
                      .withOpacity(0.4),
                ),
              ),

          
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  _buildPetInfoRow(
                    "Pet Name",
                    _petNameController.text,
                  ),

                  const SizedBox(height: 12),

                  _buildPetInfoRow(
                    "Age",
                    _ageController.text,
                  ),

                  const SizedBox(height: 12),

                  _buildPetInfoRow(
                    "Gender",
                    _selectedGender,
                  ),

                  const SizedBox(height: 12),

                  _buildPetInfoRow(
                    "Pet Type",
                    _petTypeController.text,
                  ),

                  const SizedBox(height: 12),

                  _buildPetInfoRow(
                    "Pet Breed",
                    _breedController.text,
                  ),
                ],
              ),
            ),
        

                const SizedBox(height: 24),

                /// SYMPTOMS
                SymptomWidget(

                  onSymptomsSelected:

                    (symptoms, symptomIds) {

                      setState(() {

                        selectedSymptoms =
                        symptoms;

                        selectedSymptomIds =
                        symptomIds;
                      });

                      print(
                          "SELECTED IDS : $selectedSymptomIds");
                    },
                ),

                const SizedBox(height: 24),

                /// PROBLEM
                Text(
                  "Write Your Problem",

                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Container(

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(15),

                    border: Border.all(
                      color: Colours.primarycolour
                          .withOpacity(0.4),
                    ),
                  ),

                  child: TextFormField(
                    controller: _problemController,
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter your problem";
                      }
                      return null;
                    },
                    style: TextStyle(

                      fontSize:
                          getResponsiveFont(
                              context,
                              14),

                      color:
                          Colors.black87,

                      fontFamily:
                          FontFamily.Cairo,
                    ),

                    decoration:
                        InputDecoration(

                      hintText:
                          "Enter Your Problem",

                      hintStyle:
                          TextStyle(

                        fontSize:
                            getResponsiveFont(
                                context,
                                14),

                        color:
                            Colors.black54,
                      ),

                      border:
                          InputBorder.none,

                      contentPadding:
                          const EdgeInsets.all(
                              16),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// UPLOAD BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton.icon(

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colours.primarycolour,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                125),
                      ),
                    ),

                    onPressed:
                        _showImageSourceOptions,

                    icon: const Icon(
                      Icons.upload,
                      color: Colors.white,
                    ),

                    label: const Text(
                      "Upload Images",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// IMAGE LIST
                if (_imageFiles != null &&
                    _imageFiles!.isNotEmpty)

                  SizedBox(
                    height:
                        screenHeight * 0.22,

                    child: ListView.builder(

                      scrollDirection:
                          Axis.horizontal,

                      itemCount:
                          _imageFiles!.length,

                      itemBuilder:
                          (context, index) {

                        return Stack(

                          children: [

                            Padding(
                              padding:
                                  const EdgeInsets.only(
                                right: 10,
                              ),

                              child:
                                  ClipRRect(

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            14),

                                child:
                                    Image.file(

                                  File(
                                    _imageFiles![
                                            index]
                                        .path,
                                  ),

                                  width: 140,

                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            Positioned(
                              right: 0,
                              top: 0,

                              child:
                                  IconButton(

                                onPressed:
                                    () =>
                                        _removeImage(
                                            index),

                                icon: Icon(
                                  Icons.close,
                                  color: Colours
                                      .brownColour,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 30),

                /// NEXT
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colours.primarycolour,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                18),
                      ),
                    ),

                    onPressed: () async {

                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      if (selectedPet == null) {
                        Get.snackbar(
                          "Required",
                          "Please select a pet",
                          snackPosition: SnackPosition.TOP,
                        );
                        return;
                      }

                      if (selectedSymptomIds.isEmpty) {
                        Get.snackbar(
                          "Required",
                          "Please select at least one symptom",
                          snackPosition: SnackPosition.TOP,
                        );
                        return;
                      }

                      bool success = await consultationController.createConsultation(
                        petId: selectedPet?.petId.toString() ?? "",
                        problemDescription: _problemController.text.trim(),
                        symptomIds: selectedSymptomIds,
                        otherSymptom: selectedSymptoms.join(","),
                        issueImages: (_imageFiles ?? [])
                            .map((e) => File(e.path))
                            .toList(),
                      );

                      if (success) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReviewandpayPage(
                              consultationId: consultationController.consultationId.value,
                            ),
                          ),
                        );
                      }
                    },

                    child: Text(
                      "Next",

                      style: TextStyle(
                        fontSize:
                            getResponsiveFont(
                                context,
                                16),

                        fontWeight:
                            FontWeight.w600,

                        fontFamily:
                            FontFamily.Cairo,

                        color: Colours
                            .secondarycolour,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }

  /// TEXTFIELD
  Widget _buildTextFieldCard({
    required TextEditingController controller,
      required String hintText,
      String? label,
      bool readOnly = false,
      bool requiredField = true,
  }) {

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        if (label != null)

          Text(
            label,

            style: TextStyle(
              fontSize:
                  getResponsiveFont(
                      context, 15),

              fontWeight:
                  FontWeight.w500,

              // fontFamily:
              //     FontFamily.Cairo,

              color: Colors.black
            ),
          ),

        const SizedBox(height: 8),

        SizedBox(
          // height: 50,

       child: Container(

            decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(16),

                border: Border.all(
                  color: Colours.primarycolour
                      .withOpacity(0.4),
                ),
              ),

            child: Padding(
              padding:
                  const EdgeInsets.all(16),

              child: TextFormField(

                controller: controller,
                validator: (value) {
                  if (!requiredField) return null;

                  if (value == null || value.trim().isEmpty) {
                    return "This field is required";
                  }

                  return null;
                },

                readOnly: readOnly,

                style: TextStyle(
                  fontSize:
                      getResponsiveFont(
                          context, 12),

                  // fontFamily:
                  //     FontFamily.Cairo,

                  color: Colors.black,

                ),

                decoration: InputDecoration(

                  border: InputBorder.none,

                  isDense: true,

                  contentPadding:
                      EdgeInsets.zero,

                  hintText: hintText,

                  hintStyle: TextStyle(

                    fontSize:
                        getResponsiveFont(
                            context, 14),

                    // fontFamily:
                    //     FontFamily.Cairo,

                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// DROPDOWN
  Widget _buildDropdownCard({

    required String value,

    required String label,

    required List<String> items,

    required ValueChanged<String?>?
        onChanged,
  }) {

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(
          label,

          style: TextStyle(

            fontSize:
                getResponsiveFont(
                    context,
                    14),

            fontWeight:
                FontWeight.w600,

            color:
                Colors.black,

            // fontFamily:
            //     FontFamily.Cairo,
          ),
        ),

        const SizedBox(height: 8),

        Container(

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius:
                BorderRadius.circular(15),

            border: Border.all(
              color: Colours.primarycolour
                  .withOpacity(0.4),
            ),
          ),

          child: Padding(

            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),

            child:
                DropdownButtonHideUnderline(

              child:
                  DropdownButton<String>(

                value: value,

                isExpanded: true,

                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color:
                      Colors.black54,
                ),

                style: TextStyle(

                  fontSize:
                      getResponsiveFont(
                          context,
                          14),

                  color:
                      Colors.black,

                  fontWeight:
                      FontWeight.w500,
                ),

                onChanged: onChanged,

                items:
                    items.map((item) {

                  return DropdownMenuItem(

                    value: item,

                    child: Text(
                      item,

                      style: TextStyle(

                        fontSize:
                            getResponsiveFont(
                                context,
                                14),

                        color:
                            Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPetInfoRow(
    String title,
    String value,
  ) {
    return Row(
      children: [

        SizedBox(
          width: 120,
          child: Text(
            "$title :",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
              // fontFamily: FontFamily.Cairo,
            ),
          ),
        ),

        Expanded(
          child: Text(
            value.isEmpty ? "-" : value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              // fontFamily: FontFamily.Cairo,
            ),
          ),
        ),
      ],
    );
  }
}