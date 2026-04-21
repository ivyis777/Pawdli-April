import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/addresscontroller.dart';
import 'package:pawlli/data/model/addressmodel.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/presentation/screens/pet_store/add_addresspage.dart';

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

class AddressListPage extends StatelessWidget {
  AddressListPage({super.key});

  final AddressController addressController = Get.find<AddressController>();

  // ---------------------------------------------------------
  // ⭐ USE CURRENT LOCATION
  // ---------------------------------------------------------
  Future<void> _selectCurrentLocation() async {
  try {
    // ✅ 1. Check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: "Please enable location services");
      return;
    }

    // ✅ 2. Check permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // ❌ If still denied
    if (permission == LocationPermission.denied) {
      Fluttertoast.showToast(msg: "Location permission denied");
      return;
    }

    // ❌ If permanently denied
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg: "Enable location permission from app settings");
      await Geolocator.openAppSettings();
      return;
    }

    // ✅ 3. Get current position
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // ✅ 4. Convert to address
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isEmpty) {
      Fluttertoast.showToast(msg: "Unable to fetch address");
      return;
    }

    final p = placemarks.first;

    // ✅ Debug (optional)
    print("Lat: ${position.latitude}, Lng: ${position.longitude}");
    print("City: ${p.locality}");

    // ✅ 5. Navigate to address page
    final result = await Get.to(() => AddAddressPage(
          fromLocation: true,
          street: p.street ?? "",
          area: p.subLocality ?? "",
          city: p.locality ?? "",
          state: p.administrativeArea ?? "",
          pincode: p.postalCode ?? "",
        ));

    if (result != null && result is AddressModel) {
      addressController.saveAddress(result);
    }
  } catch (e) {
    print("Location Error: $e"); // 👈 IMPORTANT
    Fluttertoast.showToast(msg: "Location error: $e");
  }
}

  // ---------------------------------------------------------
  // UI
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ---------------- APP BAR WITH TOP IMAGE ----------------
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Select Address".tr,
          style: TextStyle(
            fontSize: getResponsiveFont(context, 18),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Stack(
          children: [
            Positioned(
              top: 1,
              left: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.55,
                height: MediaQuery.of(context).size.height * 0.10,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://pawlli-podcasts.s3.ap-south-1.amazonaws.com/static_images/topimage.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ---------------- ADD ADDRESS FAB ----------------
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colours.brownColour,
        onPressed: () async {
          final newAddress = await Get.to(() => AddAddressPage());
          if (newAddress != null && newAddress is AddressModel) {
            addressController.saveAddress(newAddress);
          }
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),

      // ---------------- USE CURRENT LOCATION (BOTTOM) ----------------
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: SafeArea(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.my_location, color: Colors.white),
            label:  Text(
              "Use Current Location".tr,
              style: TextStyle(
                  fontSize: getResponsiveFont(context, 15),
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
            onPressed: _selectCurrentLocation,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              backgroundColor: Colours.primarycolour,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ),

      // ---------------- ADDRESS LIST ----------------
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Obx(() {
        return addressController.allAddresses.isEmpty
            ?  Center(child: Text(
                  "No addresses found. Add one.".tr,
                  style: TextStyle(
                    fontSize: getResponsiveFont(context, 14),
                  ),
                ))
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 90),
                itemCount: addressController.allAddresses.length,
                itemBuilder: (ctx, i) {
                  final addr = addressController.allAddresses[i];

                  return Card(
                    color: const Color.fromARGB(255, 251, 236, 210),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: ListTile(
                      title: Text(
                        addr.name,
                        style: TextStyle(
                          fontSize: getResponsiveFont(context, 14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        "${addr.phone}\n${addr.address}",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: getResponsiveFont(context, 12),
                          color: Colors.grey[700],
                        ),
                      ),
                      isThreeLine: true,
                      onTap: () {
                        addressController.selectAddress(addr);
                        Get.back(result: true);
                      },
                      trailing: Row(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () async {
                              final updated = await Get.to(
                                () => AddAddressPage(editAddress: addr),
                              );
                              if (updated != null && updated is AddressModel) {
                                addressController.updateAddress(addr, updated);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () {
                              addressController.deleteAddress(addr);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
      }),
    );
  }
}
