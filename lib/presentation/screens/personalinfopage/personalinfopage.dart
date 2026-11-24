import 'package:camera/camera.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get_storage/get_storage.dart' as storage;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pawlli/core/storage_manager/LocalStorageConstants.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/controller/getuserprofilecontroller.dart';
import 'package:pawlli/data/controller/updateuserprofilecontroller.dart';
import 'package:pawlli/data/model/updateprofilemodel.dart';
// import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/gen/fonts.gen.dart';
// import 'package:pawlli/presentation/screens/homepage/homepage.dart';
import 'package:pawlli/presentation/widgets/bottom%20bar/bottombar.dart';
// import 'package:pawlli/presentation/screens/userprofile/userprofile.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:get/get.dart';

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

class PersonalInfoPage extends StatefulWidget {
  @override
  _PersonalInfoPageState createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final userDetailsController =
      Get.put<UserProfileController>(UserProfileController());
  final UpdateProfileController updateProfileController =
      Get.put(UpdateProfileController());
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  PhoneNumber _phoneNumber = PhoneNumber(
    isoCode: 'IN',
    dialCode: '+91',
  );
  ImagePicker _picker = ImagePicker();
  File? _imageFile;
  int? _selectedGenderIndex;
  File? _profileImage;
  int? userId;
  String? _networkImageUrl;
  bool _isPhoneNumberValid = false;

  @override
  void initState() {
    super.initState();

    fetchUserDetails();
  }

  String sanitizePhoneNumber(String input) {
    // Remove all non-digit and non-plus characters
    String cleaned = input.replaceAll(RegExp(r'[^\d+]'), '');

    // Fix multiple pluses like +93+987654567 → +93987654567
    if (cleaned.startsWith('+') && cleaned.substring(1).contains('+')) {
      cleaned = '+' + cleaned.substring(1).replaceAll('+', '');
    }

    // Remove '+' to make checking easier
    String digitsOnly = cleaned.replaceAll('+', '');

    // Fix known bad data: Afghan country code used for Indian number
    if (digitsOnly.startsWith('93') && digitsOnly.length == 12) {
      digitsOnly = digitsOnly.replaceFirst('93', '91');
    }

    return '+$digitsOnly';
  }

  Future<File?> _cropImage(File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image'.tr,
          toolbarColor: Colours.primarycolour,
          toolbarWidgetColor: Colors.white,
          cropStyle: CropStyle.circle, // ✅ CIRCLE CROP (Android)
          hideBottomControls: true,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Image'.tr,
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (croppedFile == null) return null;
    return File(croppedFile.path);
  }

  Future<File?> _compressImage(XFile image) async {
    try {
      final filePath = image.path;
      final lastIndex = filePath.lastIndexOf('.');

      final split = lastIndex != -1
          ? filePath.substring(0, lastIndex)
          : filePath;

      final outPath = "${split}_compressed.jpg";

      debugPrint('📸 Original image: $filePath');

      final compressedXFile =
          await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        quality: 70,
      );

      if (compressedXFile == null) {
        debugPrint('❌ Compression returned null');
        return null;
      }

      final compressedFile = File(compressedXFile.path);

      debugPrint('✅ Compressed image: ${compressedFile.path}');
      debugPrint('✅ File exists: ${compressedFile.existsSync()}');

      return compressedFile;
    } catch (e, stackTrace) {
      debugPrint('❌ PROFILE IMAGE COMPRESSION ERROR: $e');
      debugPrint('$stackTrace');
      return null;
    }
  }

  Future<void> fetchUserDetails() async {
    final box = storage.GetStorage();
    userId ??= box.read(LocalStorageConstants.userId);

    if (userId == null) {
      print("Error: userId is null. Cannot fetch wallet balance.");
      return;
    }

    try {
      await userDetailsController.loadUserProfile(userId);
      final userDetails = userDetailsController.userProfile.value;

      if (userDetails != null && mounted) {
        final userData = userDetails;

        setState(() {
          _usernameController.text = userData.username ?? '';
          _nameController.text = userData.name ?? '';
          _ageController.text = userData.age?.toString() ?? '';
          _emailController.text = userData.email ?? '';
          _address1Controller.text = userData.address ?? '';
          _address2Controller.text = userData.address ?? '';
          _cityController.text = userData.city ?? '';
          _stateController.text = userData.state ?? '';
          _countryController.text = userData.country ?? '';
          _pincodeController.text = userData.pincode?.toString() ?? '';

          print("PROFILE IMAGE FROM API: ${userData.profilePicture}");

          String? rawImage = userData.profilePicture;

          if (rawImage != null && rawImage.isNotEmpty) {
            /// ✅ REMOVE FIRST "/"  →  "/https..." → "https..."
            if (rawImage.startsWith('/')) {
              rawImage = rawImage.substring(1);
            }

            /// ✅ DECODE URL → https%3A → https:
            rawImage = Uri.decodeFull(rawImage);

            print("FINAL IMAGE URL: $rawImage");

            _networkImageUrl = rawImage;

            /// ✅ SAVE CLEAN URL
            LocalStorage.saveProfileImage(_networkImageUrl!);
          } else {
            _networkImageUrl = null;
            LocalStorage.clearProfileImage();
          }

          switch (userData.gender.toLowerCase()) {
            case "male":
              _selectedGenderIndex = 0;
              break;
            case "female":
              _selectedGenderIndex = 1;
              break;
            default:
              // fallback default selection
              _selectedGenderIndex = 0; // 👈 Default Male (set 1 for Female)
              break;
          }
          box.write('selectedGender', _selectedGenderIndex);
        });

        // PHONE NUMBER PARSING
        if (userData.mobile.isNotEmpty == true) {
          String rawMobile = userData.mobile.trim();
          print("Raw mobile from API: $rawMobile");

          String sanitizedMobile = sanitizePhoneNumber(rawMobile);
          print("Sanitized mobile for libphonenumber: $sanitizedMobile");

          try {
            PhoneNumber.getRegionInfoFromPhoneNumber(sanitizedMobile)
                .then((phone) {
              setState(() {
                _phoneNumber = phone;
                String number = phone.phoneNumber ?? '';
                if (number.startsWith(phone.dialCode ?? '')) {
                  number = number.substring((phone.dialCode ?? '').length);
                }
                _phoneController.text = number;
              });
            }).catchError((e) {
              print('PhoneNumber parse error: $e');
            });
          } catch (e) {
            print('Exception during phone parse: $e');
          }
        }
      } else {
        debugPrint("User details not found.");
      }
    } catch (e) {
      debugPrint("Error fetching user details: $e");
    }
  }

  Future<void> _pickImage() async {
    List<CameraDescription> cameras = [];

    // Check whether a camera is available on this device
    try {
      cameras = await availableCameras();
    } catch (e) {
      debugPrint('Camera availability check failed: $e');
    }

    final bool cameraAvailable = cameras.isNotEmpty;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show camera option ONLY if camera is available
              if (cameraAvailable)
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text('Take a Picture'.tr),
                  onTap: () async {
                    Navigator.pop(sheetContext);

                    try {
                      debugPrint('📸 Opening profile camera...');

                      final XFile? image = await _picker.pickImage(
                        source: ImageSource.camera,
                      );

                      if (image == null) {
                        debugPrint('⚠️ Camera capture cancelled');
                        return;
                      }

                      debugPrint('✅ Photo captured: ${image.path}');

                      final File? compressed =
                          await _compressImage(image);

                      if (compressed == null) {
                        debugPrint('❌ Profile image compression failed');
                        return;
                      }

                      debugPrint('✅ Compression successful');

                      // ⚠️ Bypass ImageCropper on iOS
                      if (!mounted) return;

                      setState(() {
                        _profileImage = compressed;
                      });

                      debugPrint(
                        '🟢 Profile image displayed successfully',
                      );
                    } catch (e, stackTrace) {
                      debugPrint('❌ PROFILE CAMERA ERROR: $e');
                      debugPrint('$stackTrace');

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Unable to process photo: $e'),
                          ),
                        );
                      }
                    }
                  },
                ),

              // Gallery option is always available
              ListTile(
                leading: const Icon(Icons.image),
                title: Text('Upload from Gallery'.tr),
                onTap: () async {
                  try {
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.gallery,
                    );

                    if (image != null) {
                      final File? compressed = await _compressImage(image);

                      if (compressed != null) {
                        final File? cropped = await _cropImage(compressed);

                        if (cropped != null && mounted) {
                          setState(() {
                            _profileImage = cropped;
                          });
                        }
                      }
                    }
                  } catch (e) {
                    debugPrint('Gallery error: $e');
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colours.secondarycolour,
        body: Stack(children: [
          Container(
            width: screenWidth * 0.55,
            height: screenHeight * 0.10,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    'https://app.pawdli.com/media/static/topimage.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(children: [
            AppBar(
              title: Text(
                'Profile'.tr,
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.black, width: 1.5),
                            ),
                            child: ClipOval(
                              child: _profileImage != null
                                  ? Image.file(
                                      _profileImage!,
                                      width: 160,
                                      height: 160,
                                      fit: BoxFit.cover,
                                    )
                                  : (_networkImageUrl != null
                                      ? CachedNetworkImage(
                                          imageUrl: _networkImageUrl!,
                                          width: 160,
                                          height: 160,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        )
                                      : Image.asset(
                                        "assets/images/Profile_Avathar.png",
                                        fit: BoxFit.fill,
                                      )),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.brown,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height:30), 

                    // Scrollable Form Container
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User Name Field
                            TextFormField(
                              controller: _usernameController,
                              // textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                labelText: 'User Name'.tr,
                                hintText: "Enter unique username",
                                labelStyle: TextStyle(
                                  fontSize: getResponsiveFont(context, 13),
                                  color: Colors.brown[600],
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.brown),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colours.primarycolour,
                                      width: 2.0), // Focus color
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Username is required";
                                }

                                if (value.trim().length < 4) {
                                  return "Username must be at least 4 characters";
                                }

                                if (!RegExp(r'^[a-zA-Z0-9_@#.-]+$').hasMatch(value.trim())) {
                                  return "Username can contain letters, numbers, _, @, #, . and -";
                                }

                                return null;
                              },
                            ),
                            SizedBox(height: 15),
                            // Name Field
                            TextFormField(
                              controller: _nameController,
                              style: TextStyle(
                                fontSize: getResponsiveFont(context, 14),
                              ),
                              decoration: InputDecoration(
                                labelText: 'Name'.tr,
                                labelStyle: TextStyle(
                                  fontSize: getResponsiveFont(context, 13),
                                  color: Colors.brown[600],
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.brown),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colours.primarycolour,
                                      width: 2.0), // Focus color
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name'.tr;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 15),

                            TextFormField(
                              controller: _ageController,
                              style: TextStyle(
                                fontSize: getResponsiveFont(context, 14),
                              ),
                              decoration: InputDecoration(
                                labelText: 'Age'.tr,
                                labelStyle: TextStyle(
                                  fontSize: getResponsiveFont(context, 13),
                                  color: Colors.brown[600],
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.brown),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colours.primarycolour, width: 2.0),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your age'.tr;
                                }
                                final age = int.tryParse(value);
                                if (age == null) {
                                  return 'Please enter a valid number'.tr;
                                }
                                if (age < 1 || age > 100) {
                                  return 'Age must be between 1 to 100'.tr;
                                }
                                return null;
                              },
                            ),

                            Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 5.0),
                              width: double.infinity, // Ensures finite width
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Text(
                                    'Gender:'.tr,
                                    style: TextStyle(
                                        fontSize: getResponsiveFont(context, 14),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Column(
                                    children: [
                                      ToggleSwitch(
                                        initialLabelIndex: _selectedGenderIndex,
                                        minWidth: 80.0,
                                        minHeight: 50.0,
                                        cornerRadius: 20.0,
                                        activeFgColor: Colors.white,
                                        inactiveBgColor: Colors.grey,
                                        inactiveFgColor: Colors.white,
                                        totalSwitches: 3,
                                        icons: const [
                                          Icons.male,
                                          Icons.female,
                                          Icons.transgender,
                                        ],
                                        iconSize: 30.0,
                                        borderWidth: 2.0,
                                        activeBgColors: [
                                          [Colours.primarycolour],
                                          [Colours.primarycolour],
                                          [Colours.primarycolour]
                                        ],
                                        onToggle: (index) {
                                          setState(() {
                                            _selectedGenderIndex = index;
                                          });
                                        },
                                      ),
                                      SizedBox(
                                          height:
                                              5), // Space between toggle and labels
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text('Male'.tr,
                                                style: TextStyle(
                                                    fontSize: getResponsiveFont(context, 13),
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text('Female'.tr,
                                                style: TextStyle(
                                                    fontSize: getResponsiveFont(context, 13),
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text('Others'.tr,
                                                style: TextStyle(
                                                    fontSize: getResponsiveFont(context, 13),
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 15),
                            InternationalPhoneNumberInput(
                              onInputChanged: (PhoneNumber number) {
                                setState(() {
                                  _phoneNumber = number;
                                });
                              },

                              onInputValidated: (bool isValid) {
                                setState(() {
                                  _isPhoneNumberValid = isValid;
                                });
                              },

                              selectorConfig: const SelectorConfig(
                                selectorType: PhoneInputSelectorType.DIALOG,
                              ),

                              textFieldController: _phoneController,

                              initialValue: _phoneNumber,

                              formatInput: false,

                              // 👇 ADD THESE TWO LINES
                              maxLength: 10,
                              keyboardType: TextInputType.number,

                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }

                                if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(value)) {
                                  return 'Please enter a valid 10 digit mobile number';
                                }

                                return null;
                              },
                              inputDecoration: InputDecoration(
                                labelText: 'Phone Number'.tr,
                                labelStyle: TextStyle(
                                  fontSize: getResponsiveFont(context, 13),
                                  color: Colors.brown[600],
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.brown),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colours.primarycolour, width: 2.0),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),

                            TextFormField(
                              controller: _emailController,
                              style: TextStyle(
                                fontSize: getResponsiveFont(context, 14, ), color: Colors.grey
                              ),
                              readOnly: true,
                              // style: TextStyle(color: Colors.grey), // Grey text
                              decoration: InputDecoration(
                                labelText: 'Email ID'.tr,
                                labelStyle: TextStyle(
                                  fontSize: getResponsiveFont(context, 13),
                                  color: Colors.brown[600],
                                ),
                                filled: true,
                                fillColor: Colors.grey[
                                    100], // Optional: light grey background
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),

                            SizedBox(height: 15),

                            // Address 1 Field
                            TextFormField(
                              controller: _address1Controller,
                              style: TextStyle(
                                fontSize: getResponsiveFont(context, 14),
                              ),
                              decoration: InputDecoration(
                                labelText: 'Address '.tr,
                                labelStyle: TextStyle(
                                  fontSize: getResponsiveFont(context, 13),
                                  color: Colors.brown[600],
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.brown),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colours.primarycolour,
                                      width: 2.0), // Focus color
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) => null,
                              // validator: (value) {
                              //   if (value == null || value.isEmpty) {
                              //     return 'Please enter your address'.tr;
                              //   }
                              //   return null;
                              // },
                            ),
                            SizedBox(height: 15),
                            TextFormField(
                              controller: _cityController,
                              style: TextStyle(
                                fontSize: getResponsiveFont(context, 14),
                              ),
                              decoration: InputDecoration(
                                labelText: 'City'.tr,
                                labelStyle: TextStyle(
                                  fontSize: getResponsiveFont(context, 13),
                                  color: Colors.brown[600],
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.brown),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colours.primarycolour,
                                      width: 2.0), // Focus color
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) => null,
                              // validator: (value) {
                              //   if (value == null || value.isEmpty) {
                              //     return 'Please enter your city'.tr;
                              //   }
                              //   return null;
                              // },
                            ),
                            SizedBox(height: 15),

                            // State Field
                            TextFormField(
                              controller: _stateController,
                              style: TextStyle(
                                fontSize: getResponsiveFont(context, 14),
                              ),
                              decoration: InputDecoration(
                                labelText: 'State'.tr,
                                labelStyle: TextStyle(
                                  fontSize: getResponsiveFont(context, 13),
                                  color: Colors.brown[600],
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.brown),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colours.primarycolour,
                                      width: 2.0), // Focus color
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) => null,
                              // validator: (value) {
                              //   if (value == null || value.isEmpty) {
                              //     return 'Please enter your state'.tr;
                              //   }
                              //   return null;
                              // },
                            ),
                            SizedBox(height: 15),

                            // Country Field
                            TextFormField(
                              controller: _countryController,
                              style: TextStyle(
                                fontSize: getResponsiveFont(context, 14),
                              ),
                              decoration: InputDecoration(
                                labelText: 'Country'.tr,
                                labelStyle: TextStyle(
                                  fontSize: getResponsiveFont(context, 13),
                                  color: Colors.brown[600],
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.brown),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colours.primarycolour,
                                      width: 2.0), // Focus color
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) => null,
                              // validator: (value) {
                              //   if (value == null || value.isEmpty) {
                              //     return 'Please enter your country'.tr;
                              //   }
                              //   return null;
                              // },
                            ),
                            SizedBox(height: 15),

                            // Pincode Field
                            TextFormField(
                              controller: _pincodeController,
                              style: TextStyle(
                                fontSize: getResponsiveFont(context, 14),
                              ),
                              decoration: InputDecoration(
                                labelText: 'Pincode'.tr,
                                labelStyle: TextStyle(
                                  fontSize: getResponsiveFont(context, 13),
                                  color: Colors.brown[600],
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.brown),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colours.primarycolour, width: 2.0),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => null,
                              // validator: (value) {
                              //   if (value == null || value.isEmpty) {
                              //     return 'Please enter your pincode'.tr;
                              //   }
                              //   return null;
                              // },
                            ),

                            SizedBox(height: 20),
                            Obx(
                              () => Center(
                                child: ElevatedButton(
                                  onPressed: updateProfileController.isLoading.value
                                      ? null
                                      : () async {
                                          if (!_isPhoneNumberValid) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Please enter a valid phone number'.tr,
                                                ),
                                                backgroundColor: Colors.black,
                                              ),
                                            );
                                            return;
                                          }

                                          if (_formKey.currentState!.validate()) {
                                            await _updateProfile();
                                            Get.offAll(() => MainLayout());
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colours.primarycolour,
                                    fixedSize: Size(
                                      screenWidth * 0.8,
                                      50,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: updateProfileController.isLoading.value
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Text(
                                          'Update'.tr,
                                          style: TextStyle(
                                            fontSize: getResponsiveFont(context, 16),
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ])
        ]));
  }

  Future<void> _updateProfile() async {
    final model = UpdateProfileModel(
      id: userId,

      // Only these five fields will be updated
      username: _usernameController.text.trim(),
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()),
      email: _emailController.text.trim(),
      mobile: _phoneNumber.phoneNumber?.trim() ??
          _phoneController.text.trim(),

      // All remaining fields are intentionally null
      password: null,
      lastLogin: null,
      gender: null,
      address: null,
      dob: null,
      pincode: null,
      bio: null,
      profilePicture: _profileImage?.path,
      registeredat: null,
      lastlogin: null,
      city: null,
      country: null,
      state: null,
      throughGoogle: null,
      fcmToken: null,
      isActive: null,
      updatedAt: null,
      updatedBy: null,
      currencyPreference: null,
      agoraUid: null,
      onlineStatus: null,
    );

    print("======= PROFILE UPDATE REQUEST =======");
    print("Username: ${model.username}");
    print("Name: ${model.name}");
    print("Age: ${model.age}");
    print("Email: ${model.email}");
    print("Mobile: ${model.mobile}");
    print("Other fields: null");
    print("======================================");

    await updateProfileController.updateUserProfile(model);

    await fetchUserDetails();
  }
}
