import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/controller/signcontroller.dart';
import 'package:pawlli/data/model/addressmodel.dart';
import 'package:pawlli/gen/assests.gen.dart';

class AddAddressPage extends StatefulWidget {
  final bool fromLocation;
  final String? street;
  final String? area;
  final String? city;
  final String? state;
  final String? pincode;
  final AddressModel? editAddress;

  const AddAddressPage({
    super.key,
    this.fromLocation = false,
    this.street,
    this.area,
    this.city,
    this.state,
    this.pincode,
    this.editAddress,
  });

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();

  final SignupController signupController = Get.find<SignupController>();
  final box = GetStorage();

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final houseCtrl = TextEditingController();
  final streetCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final pincodeCtrl = TextEditingController();

  String selectedCountryCode = "+91";

  @override
  void initState() {
    super.initState();

    // 🔐 Logged-in email (must exist)
    emailCtrl.text =
        box.read(LocalStorageConstants.userEmail)?.toString() ?? "";

    // ✏️ Edit mode
    if (widget.editAddress != null) {
      nameCtrl.text = widget.editAddress!.name;

      final phoneParts = widget.editAddress!.phone.split(' ');
      if (phoneParts.length > 1) {
        selectedCountryCode = phoneParts.first;
        phoneCtrl.text = phoneParts.sublist(1).join(' ');
      } else {
        phoneCtrl.text = widget.editAddress!.phone;
      }
    }

    // 📍 From current location
    if (widget.fromLocation) {
      streetCtrl.text = widget.street ?? "";
      cityCtrl.text = widget.city ?? "";
      stateCtrl.text = widget.state ?? "";
      pincodeCtrl.text = widget.pincode ?? "";
    }
  }

  // ---------------- INPUT DECORATION ----------------
  InputDecoration _input(
    String hint, {
    Color fillColor = Colors.white,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colours.primarycolour),
      ),
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  // ---------------- REQUIRED VALIDATOR ----------------
  String? _required(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ---------------- APP BAR WITH IMAGE ----------------
      appBar: AppBar(
        centerTitle: true,
        title:  Text("Add Address".tr),
        backgroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Stack(
          children: [
            Positioned(
              top: 0,
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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // ---------------- NAME ----------------
              TextFormField(
                controller: nameCtrl,
                decoration: _input("Full Name".tr),
                validator: (v) => _required(v, "Enter full name".tr),
              ),
              const SizedBox(height: 12),

              // ---------------- PHONE ----------------
              Row(
                children: [
                  CountryCodePicker(
                    initialSelection: 'IN',
                    favorite: const ['+91', 'IN'],
                    onChanged: (code) {
                      selectedCountryCode = code.dialCode ?? "+91";
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: _input("Mobile Number".tr),
                      validator: (v) => _required(v, "Enter mobile number".tr),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ---------------- EMAIL (READ ONLY) ----------------
              TextFormField(
                controller: emailCtrl,
                enabled: false,
                decoration: _input(
                  "Email".tr,
                  fillColor: Colors.grey.shade200,
                ),
                validator: (v) => _required(v, "Login email not found".tr),
              ),
              const SizedBox(height: 12),

              // ---------------- HOUSE ----------------
              TextFormField(
                controller: houseCtrl,
                decoration: _input("House / Flat No".tr),
                validator: (v) => _required(v, "Enter house / flat number".tr),
              ),
              const SizedBox(height: 12),

              // ---------------- STREET ----------------
              TextFormField(
                controller: streetCtrl,
                decoration: _input("Street / Area".tr),
                validator: (v) => _required(v, "Enter street / area".tr),
              ),
              const SizedBox(height: 12),

              // ---------------- CITY ----------------
              TextFormField(
                controller: cityCtrl,
                decoration: _input("City".tr),
                validator: (v) => _required(v, "Enter city".tr),
              ),
              const SizedBox(height: 12),

              // ---------------- STATE ----------------
              TextFormField(
                controller: stateCtrl,
                decoration: _input("State".tr),
                validator: (v) => _required(v, "Enter state".tr),
              ),
              const SizedBox(height: 12),

              // ---------------- PINCODE ----------------
              TextFormField(
                controller: pincodeCtrl,
                keyboardType: TextInputType.number,
                decoration: _input("Pincode".tr),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Enter pincode".tr;
                  }
                  if (v.length < 6) {
                    return "Enter valid pincode".tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ---------------- SAVE BUTTON ----------------
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  backgroundColor: Colours.primarycolour,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final address = AddressModel(
                      name: nameCtrl.text.trim(),
                      phone: "$selectedCountryCode ${phoneCtrl.text.trim()}",
                      email: emailCtrl.text.trim(),
                      address:
                          "${houseCtrl.text}, ${streetCtrl.text}, ${cityCtrl.text}, ${stateCtrl.text} - ${pincodeCtrl.text}",
                    );
                    Get.back(result: address);
                  }
                },
                child:  Text(
                  "Save Address".tr,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
