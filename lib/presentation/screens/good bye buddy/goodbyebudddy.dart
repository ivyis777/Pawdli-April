import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:http/http.dart' as http;
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/app%20url.dart';
import 'package:pawlli/data/controller/goodbyebuddycontroller.dart';
import 'package:get/get.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/good%20bye%20buddy/superuserdetailspage.dart';
import 'package:pawlli/presentation/screens/good%20bye%20buddy/userdetailspage.dart';

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

class Goodbyebudddy extends StatefulWidget {
  const Goodbyebudddy({Key? key}) : super(key: key);

  @override
  _GoodbyebudddyState createState() => _GoodbyebudddyState();
}

class _GoodbyebudddyState extends State<Goodbyebudddy>
    with SingleTickerProviderStateMixin {
  TextEditingController programDescriptionController = TextEditingController();
  TextEditingController landmarkController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  final GoodByeBuddyController goodByeBuddyController =
      Get.put(GoodByeBuddyController());

  late TabController _tabController;
  String pageTitle = "GoodByeBuddy";

  String? _locationString;

  final _locationChannel = MethodChannel('location_permissions');

  int _locationPermissionAttempts = 0;
  final box = GetStorage();
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  latLng.LatLng? _selectedLocation;
  bool _isLoadingLocation = false;
  List requests = [];
  bool isLoadingRequests = true;

  List<XFile>? _imageFiles;

  String formatDateTime(String date) {
    try {
      final parsedDate = DateTime.parse(date).toLocal();

      return DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate);
    } catch (e) {
      return date; // fallback if error
    }
  }

  @override
  void initState() {
    super.initState();


    _tabController = TabController(
      length: 2, // GoodByeBuddy, requests
      vsync: this,
    );

    _tabController.addListener(() {
      if (_tabController.index == 0) {
        setState(() {
          pageTitle = "GoodByeBuddy";
        });
  
      } else if (_tabController.index == 1) {
        setState(() {
          pageTitle = "Requests";
        });
      }
    });

    fetchRequests();
  }

  void safeSnackbar(String title, String message, {Color bg = Colors.black}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.overlayContext != null) {
        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: bg,
          colorText: Colors.white,
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    });
  }

  Future<void> _pickImage() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      List<XFile> compressedList = [];
      for (var file in pickedFiles) {
        final compressed = await _compressImage(file);
        if (compressed != null) {
          compressedList.add(XFile(compressed.path));
        }
      }
      setState(() {
        _imageFiles = compressedList;
      });
    }
  }

  Future<XFile?> _compressImage(XFile file) async {
    try {
      final filePath = file.path;

      final lastDot = filePath.lastIndexOf('.');
      if (lastDot == -1) return file;

      final outPath = '${filePath.substring(0, lastDot)}_compressed.jpg';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        quality: 70,
        format: CompressFormat.jpeg,
      );

      return compressedFile != null ? XFile(compressedFile.path) : file;
    } catch (e) {
      debugPrint('Compression error: $e');
      return file;
    }
  }

  Future<void> fetchRequests() async {
    try {
      final response = await http.get(
        Uri.parse(AppUrl.GoodByeBuddyListUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${box.read(LocalStorageConstants.access)}",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final allRequests = data["data"] ?? [];

        // final isSuperUser = box.read(LocalStorageConstants.isSuperUser);

        final userId = box.read(LocalStorageConstants.userId);

        // print("IS SUPER USER: $isSuperUser");
        // print("USER ID: $userId");
        // print("TOTAL REQUESTS FROM API: ${allRequests.length}");

        // bool isAdmin = false;

        final isSuperUser =
          box.read(LocalStorageConstants.isSuperUser) == true;

       print("IS SUPER USER: $isSuperUser");
        print("USER ID: $userId");
        print("TOTAL REQUESTS FROM API: ${allRequests.length}");

        bool isAdmin = isSuperUser;

        // if (isSuperUser == true || isSuperUser == "true" || isSuperUser == 1) {
        //   isAdmin = true;
        // }

        if (isAdmin) {
          requests = allRequests;
        } else {
          requests = allRequests
              .where((r) => r["created_by"]?.toString() == userId?.toString())
              .toList();
        }

        // ✅ SORT REQUESTS
        requests.sort((a, b) {
          final statusA = (a["status"] ?? "").toString().toLowerCase();
          final statusB = (b["status"] ?? "").toString().toLowerCase();

          // ✅ Pending first
          if (statusA == "completed" && statusB != "completed") {
            return 1; // completed goes down
          }
          if (statusA != "completed" && statusB == "completed") {
            return -1; // pending goes up
          }

          // ✅ If same status → sort by latest date
          final dateA =
              DateTime.tryParse(a["created_at"] ?? "") ?? DateTime(2000);
          final dateB =
              DateTime.tryParse(b["created_at"] ?? "") ?? DateTime(2000);

          return dateB.compareTo(dateA); // latest first
        });

        setState(() {
          isLoadingRequests = false;
        });
      }
    } catch (e) {
      print("Request API error: $e");
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      final compressed = await _compressImage(photo);
      if (compressed != null) {
        setState(() {
          _imageFiles = (_imageFiles ?? []) + [XFile(compressed.path)];
        });
      }
    }
  }

  final MapController _mapController = MapController();
  latLng.LatLng? _selectedMapLocation;
  bool _showMap = false;

  // Function to show map for location selection
  Future<void> _openMapForLocationSelection() async {
    setState(() => _isLoadingLocation = true);

    try {
      // 1️⃣ Permission check
      bool hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        hasPermission = await requestLocationPermission();
        if (!hasPermission) {
          _locationPermissionAttempts++;

          setState(() => _isLoadingLocation = false); // 🔴 FIX

          if (_locationPermissionAttempts >= 2) {
            final openSettings = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title:  Text('Permission Required'.tr),
                content:  Text(
                  'Location permission is denied.\nPlease enable it in app settings.'.tr,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child:  Text('Cancel'.tr),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child:  Text('Open Settings'.tr),
                  ),
                ],
              ),
            );

            if (openSettings == true) {
              await Geolocator.openAppSettings();
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('Location permission required'.tr)),
            );
          }
          return;
        }
      }

      // 2️⃣ Location services check
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoadingLocation = false); // 🔴 FIX
        bool? shouldEnable = await showEnableLocationDialog();
        if (shouldEnable == true) {
          await Geolocator.openLocationSettings();
        }
        return;
      }

      // 3️⃣ Get current location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );

      // 4️⃣ Open map with initial marker
      setState(() {
        _selectedMapLocation =
            latLng.LatLng(position.latitude, position.longitude);

        _showMap = true;

        _locationPermissionAttempts = 0;

        _isLoadingLocation = false;
      });

      /// Wait until FlutterMap is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_selectedMapLocation != null) {
          _mapController.move(
            _selectedMapLocation!,
            17,
          );
        }
      });
    } on PlatformException catch (e) {
      setState(() => _isLoadingLocation = false);
      _handleLocationError(e);
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    }
  }

  Future<bool?> showEnableLocationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title:  Text('Location Service Disabled'.tr),
        content:  Text('Please enable location services'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:  Text('Cancel'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:  Text('Enable'.tr),
          ),
        ],
      ),
    );
  }

  Future<bool> checkLocationPermission() async {
    final status = await Geolocator.checkPermission();
    return status == LocationPermission.always ||
        status == LocationPermission.whileInUse;
  }

  Future<bool> requestLocationPermission() async {
    final status = await Geolocator.requestPermission();
    return status == LocationPermission.always ||
        status == LocationPermission.whileInUse;
  }

  void _handleLocationError(PlatformException e) {
    String errorMessage;

    switch (e.code) {
      case 'PERMISSION_DENIED':
        errorMessage = 'Location permissions denied'.tr;
        break;
      case 'PERMISSION_DENIED_NEVER_ASK':
        errorMessage =
            'Location permissions permanently denied. Please enable in app settings.'.tr;
        _showPermissionSettingsDialog();
        break;
      case 'LOCATION_SERVICES_DISABLED':
        errorMessage = 'Location services disabled'.tr;
        break;
      case 'TIMEOUT':
        errorMessage = 'Location request timed out'.tr;
        break;
      default:
        errorMessage = 'Error getting location: ${e.message}';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }

  Future<void> _showPermissionSettingsDialog() async {
    final openSettings = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title:  Text('Permission Required'.tr),
        content:  Text('Location permissions are permanently denied. Please enable them in app settings.'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:  Text('Cancel'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:  Text('Open Settings'.tr),
          ),
        ],
      ),
    );

    if (openSettings == true) {
      await Geolocator.openAppSettings();
    }
  }

  Future<void> _confirmLocation() async {
    if (_selectedMapLocation == null) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _selectedMapLocation!.latitude,
        _selectedMapLocation!.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        // ✅ GET PINCODE
        String postalCode = place.postalCode ?? "";

        print("📮 Selected Pincode: $postalCode");

        // ✅ Allowed pincode series
          List<String> allowedSeries = ["50", "56"];

          // ✅ Check service availability
          bool isServiceAvailable = allowedSeries.any(
            (code) => postalCode.startsWith(code),
          );

        // ❌ NOT SERVICE AREA
        if (!isServiceAvailable) {
          setState(() {
            _isLoadingLocation = false;
            _showMap = false;
          });

          Get.dialog(
            Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Colours.primarycolour,
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/images/NotAvailable.png", // Change if you have a better image
                      height: 150,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 12),

                    // const Text(
                    //   "Service Not Available",
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(
                    //     fontSize: 22,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),

                    const SizedBox(height: 10),

                    const Text(
                      "We are not servicing in this location.\nWe will start as soon as possible.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colours.primarycolour,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text(
                          "OK",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            barrierDismissible: false,
          );

          return;
        }

        // ✅ ADDRESS BUILD
        String address = [
          place.street,
          place.locality,
          place.postalCode,
          place.country
        ].where((part) => part != null && part.isNotEmpty).join(', ');

        setState(() {
          _locationString = address;

          _selectedLocation = latLng.LatLng(
            _selectedMapLocation!.latitude,
            _selectedMapLocation!.longitude,
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get address: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingLocation = false;
        _showMap = false;
      });
    }
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _selectedMapLocation ??
                latLng.LatLng(0, 0), // Changed from 'center' to 'initialCenter'
            initialZoom: 15.0, // Changed from 'zoom' to 'initialZoom'
            onTap: (tapPosition, point) {
              setState(() {
                _selectedMapLocation = point;
              });
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.ivyis.pawlli',
            ),
            MarkerLayer(
              markers: [
                if (_selectedMapLocation != null)
                  Marker(
                    point: _selectedMapLocation!, // required parameter
                    child: const Icon(
                      // Changed from 'builder' to 'child'
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                    width: 40, // Added width
                    height: 40, // Added height
                  ),
              ],
            ),
          ],
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: ElevatedButton(
            onPressed: _confirmLocation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colours.primarycolour,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child:  Text(
              'Confirm Location'.tr,
              style: TextStyle(fontSize: getResponsiveFont(context, 15), 
              fontWeight: FontWeight.bold,
              color: Colors.white),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          right: 20,
          child: FloatingActionButton(
            heroTag: "myLocation",
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _goToCurrentLocation,
            child: Icon(
              Icons.my_location,
              color: Colors.blue,
            ),
          ),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: FloatingActionButton(
            heroTag: "closeMap",
            mini: true,
            backgroundColor: Colors.white,
            onPressed: () {
              if (_selectedMapLocation == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Please select a location".tr),
                  ),
                );
                return;
              }

              _confirmLocation();
            },
            child: Icon(
              Icons.close,
              color: Colours.primarycolour,
            ),
          ),
        ),
      ],
    );
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows better positioning
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;

        return Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom + 80, // Moves it up
            left: 16,
            right: 16,
            top: 10, // Extra top padding
          ),
          child: Wrap(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                "Select Image Source".tr,
                style: TextStyle(
                  fontSize: getResponsiveFont(context, 18),
                  fontWeight: FontWeight.w600,
                  fontFamily: FontFamily.Cairo,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.image, size: 25),
                title: Text(
                  "Gallery".tr,
                  style: TextStyle(
                    fontSize: getResponsiveFont(context, 14),
                    fontWeight: FontWeight.w500,
                    fontFamily: FontFamily.Cairo,
                    color: Colours.black,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera, size: 25),
                title: Text(
                  "Camera".tr,
                  style: TextStyle(
                    fontSize: getResponsiveFont(context, 14),
                    fontWeight: FontWeight.w500,
                    fontFamily: FontFamily.Cairo,
                    color: Colours.black,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Location services are disabled.'.tr;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied.'.tr;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.'.tr;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Reverse geocoding
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        // Build a readable address string, e.g.:
        String address =
            "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";

        setState(() {
          _selectedLocation =
              latLng.LatLng(position.latitude, position.longitude);
          _locationString = address; // <-- Save this string for upload
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _goToCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final current = latLng.LatLng(
        position.latitude,
        position.longitude,
      );

      _mapController.move(current, 17);

      setState(() {
        _selectedMapLocation = current;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to get current location"),
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colours.brownColour),
          onPressed: () {
            Navigator.pop(context);
          },
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colours.primarycolour,
          unselectedLabelColor: Colors.black,
          indicatorColor: Colours.primarycolour,
          indicatorWeight: 3,
          tabs:  [
            Tab(
              child: Text(
                "GoodByeBuddy".tr,
                style: TextStyle(
                  fontSize: getResponsiveFont(context, 12),
                ),
              ),
            ),

            Tab(
              child: Text(
                "Requests".tr,
                style: TextStyle(
                  fontSize: getResponsiveFont(context, 12),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 🔹 TAB CONTENT
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // ==================================================
                    // 🟢 TAB 1 — GOODBYEBUDDY (YOUR EXISTING FORM)
                    // ==================================================
                    SingleChildScrollView(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16),

                          Text('Location:'.tr,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: getResponsiveFont(context, 14))),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _openMapForLocationSelection,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colours.primarycolour,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(
                                  color: Colors.grey,
                                  // width: 1.5,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: Colours.black,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Select Location from Map".tr,
                                  style: TextStyle(
                                    fontSize: getResponsiveFont(context, 14),
                                    // fontWeight: FontWeight.w600,
                                    color: Colours.black
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_locationString != null)
                            Text("Address: ".tr + "$_locationString"),

                          SizedBox(height: 16),

                          /// UPLOAD IMAGES TITLE
                          Text(
                            "Upload Images".tr,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: getResponsiveFont(context, 14),
                            ),
                          ),

                          const SizedBox(height: 8),

                          /// IMAGE PICKER
                          GestureDetector(
                            onTap: _showImageSourceOptions,
                            child: Card(
                              color: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 15,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload_outlined,
                                      color: Colours.black,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Upload Image".tr,
                                      style: TextStyle(
                                        fontSize: getResponsiveFont(context, 14),
                                        // fontWeight: FontWeight.w600,
                                        color: Colours.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          if (_imageFiles != null && _imageFiles!.isNotEmpty)
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _imageFiles!.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: Image.file(
                                            File(_imageFiles![index].path),
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        ),

                                        /// ❌ REMOVE BUTTON
                                        Positioned(
                                          top: 5,
                                          right: 5,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _imageFiles!.removeAt(index); // ✅ remove image
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(4),
                                              child: const Icon(
                                                Icons.close,
                                                size: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),

                          SizedBox(height: 10),

                          Text(
                            'Landmark:'.tr,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: getResponsiveFont(context, 14)),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: landmarkController,
                            style: TextStyle(
                              fontSize: getResponsiveFont(context, 14),
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(16),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(16), // ✅ RADIUS
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                    color: Colours.primarycolour, width: 2),
                              ),
                            ),
                          ),

                          SizedBox(height: 16),

                          Text(
                            'Description:'.tr,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: getResponsiveFont(context, 14)),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: programDescriptionController,
                            style: TextStyle(
                              fontSize: getResponsiveFont(context, 14),
                            ),
                            maxLines: 3,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(16),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(16), // ✅ RADIUS
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                    color: Colours.primarycolour, width: 2),
                              ),
                            ),
                          ),

                          SizedBox(height: 24),

                          Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                // ✅ LOCATION VALIDATION
                                if (_locationString == null ||
                                    _locationString!.isEmpty) {
                                  safeSnackbar(
                                    "Location required".tr,
                                    "Please select and confirm a location from the map".tr,
                                    bg: Colors.transparent,
                                  );
                                  return;
                                }

                                // ✅ OTHER BASIC VALIDATION
                                if (landmarkController.text.trim().isEmpty ||
                                    programDescriptionController.text
                                        .trim()
                                        .isEmpty ||
                                    _imageFiles == null ||
                                    _imageFiles!.isEmpty) {
                                  safeSnackbar(
                                    "Missing details".tr,
                                    "Please fill all fields and upload images".tr,
                                    // snackPosition: SnackPosition.TOP,
                                    bg: Colours.primarycolour,
                                    // colorText: Colors.white,
                                  );
                                  return;
                                }

                                // ✅ DEBUG (IMPORTANT)
                                print(
                                    "📍 FINAL LOCATION STRING: $_locationString");

                                await goodByeBuddyController
                                    .uploadGoodByeBuddyData(
                                  location: _locationString!,
                                  latitude:
                                      _selectedLocation?.latitude, // ✅ ADD THIS
                                  longitude: _selectedLocation
                                      ?.longitude, // ✅ ADD THIS
                                  landmark: landmarkController.text.trim(),
                                  description:
                                      programDescriptionController.text.trim(),
                                  imageFiles: _imageFiles!
                                      .map((e) => File(e.path))
                                      .toList(),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colours.primarycolour,
                                fixedSize: Size(screenWidth * 0.8, 50),
                              ),
                              child:  Text(
                                "Submit".tr,
                                style: TextStyle(
                                  fontSize: getResponsiveFont(context, 16),
                                  color: Colors.white, ),
                              ),
                            ),
                          ),

                          SizedBox(height: 40),
                        ],
                      ),
                    ),

                    // ==================================================
                    // 🟢 TAB 2 — REQUEST LIST
                    // ==================================================

                    isLoadingRequests
                        ? const Center(child: CircularProgressIndicator())
                        : requests.isEmpty
                            ? SizedBox.expand(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Image.asset(
                                    'assets/images/NoRequestFound.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              )
                            : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: requests.length,
                            itemBuilder: (context, index) {
                              final item = requests[index];

                              return GestureDetector(
                                onTap: () {
                                  final isSuperUser = box.read(
                                          LocalStorageConstants.isSuperUser) ==
                                      true;

                                  if (isSuperUser) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SuperUserRequestDetailsPage(
                                          requestId: item["id"],
                                        ),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserRequestDetailsPage(
                                          requestId: item["id"],
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Card(
                                  elevation: 0,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: Colours.brownColour, width: 0.5
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Request No : ${item['id']}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: getResponsiveFont(context, 14),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white, // White background
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: item["status"] == "completed"
                                                      ? Colors.green
                                                      : Colors.orange,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                item["status"] != null && item["status"].toString().isNotEmpty
                                                    ? "${item["status"].toString()[0].toUpperCase()}${item["status"].toString().substring(1)}"
                                                    : "",
                                                style: TextStyle(
                                                  color: item["status"] == "completed"
                                                      ? Colors.black
                                                      : Colors.black,
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: getResponsiveFont(context, 12),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          item["location"] ?? "",
                                          style: TextStyle(
                                            fontSize: getResponsiveFont(context, 13),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          formatDateTime(
                                              item["created_at"] ?? ""),
                                          style: TextStyle(
                                            fontSize: getResponsiveFont(context, 12),
                                            color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ],
          ),

          // ================= MAP OVERLAY =================
          if (_showMap)
            Positioned.fill(
              child: Material(
                color: Colors.white,
                child: _buildMapView(),
              ),
            ),

          // ================= LOADING OVERLAY =================
          if (_isLoadingLocation)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black45,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
