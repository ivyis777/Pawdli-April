import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/model/GroomingAddressModel.dart';


class AddressFormBottomSheet extends StatefulWidget {
  final double latitude;
  final double longitude;

  const AddressFormBottomSheet({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<AddressFormBottomSheet> createState() =>
      _AddressFormBottomSheetState();
}

class _AddressFormBottomSheetState
    extends State<AddressFormBottomSheet> {

  final box = GetStorage();

  final houseController =
      TextEditingController();

  final floorController =
      TextEditingController();

  final areaController =
      TextEditingController();

  final localityController =
      TextEditingController();

  final landmarkController =
      TextEditingController();

  final cityController =
      TextEditingController();

  final stateController =
      TextEditingController();

  final pincodeController =
      TextEditingController();

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAddress();
  }

  Future<void> loadAddress() async {

    List<Placemark> placemarks =
        await placemarkFromCoordinates(
      widget.latitude,
      widget.longitude,
    );

    Placemark place =
        placemarks.first;

    areaController.text =
        place.subLocality ?? "";

    localityController.text =
        place.street ?? "";

    cityController.text =
        place.locality ?? "";

    stateController.text =
        place.administrativeArea ?? "";

    pincodeController.text =
        place.postalCode ?? "";

    setState(() {
      loading = false;
    });
  }

  Future<void> saveAddress() async {

    if (houseController.text.isEmpty) {
      return;
    }

    AddressModel address =
        AddressModel(
      houseNo:
          houseController.text,
      flatFloor:
          floorController.text,
      area:
          areaController.text,
      locality:
          localityController.text,
      landmark:
          landmarkController.text,
      city:
          cityController.text,
      state:
          stateController.text,
      pincode:
          pincodeController.text,
    );

    List saved =
        box.read(
              "saved_addresses",
            ) ??
            [];

    saved.add(
      address.toJson(),
    );

    await box.write(
      "saved_addresses",
      saved,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;
    return Container(
      height: MediaQuery.of(context).size.height * 0.80,

      decoration:
          const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.only(
          topLeft:
              Radius.circular(30),
          topRight:
              Radius.circular(30),
        ),
      ),

      child: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : Column(
              children: [

                const SizedBox(
                    height: 12),

                Container(
                  width: 60,
                  height: 5,
                  decoration:
                      BoxDecoration(
                    color: Colors
                        .grey
                        .shade300,
                    borderRadius:
                        BorderRadius
                            .circular(
                                20),
                  ),
                ),

                const SizedBox(
                    height: 20),

                Text(
                  "Add Address Details",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colours.brownColour,
                  ),
                ),

                const SizedBox(
                    height: 20),

                Expanded(
                  child:
                      SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),

                    child: Column(
                      children: [

                        buildLabel("House Number *"),
                        buildField(
                          "House Number",
                          houseController,
                        ),

                        buildLabel("Flat / Floor *"),
                        buildField(
                          "Flat / Floor",
                          floorController,
                        ),
                        buildLabel("Area *"),
                        buildField(
                          "Area",
                          areaController,
                        ),

                        buildLabel("Locality *"),
                        buildField(
                          "Locality",
                          localityController,
                        ),
                        
                        buildLabel("Landmark (optional)"),
                        buildField(
                          "Landmark",
                          landmarkController,
                        ),

                        buildLabel("City *"),
                        buildField(
                          "City",
                          cityController,
                        ),

                        buildLabel("State *"),
                        buildField(
                          "State",
                          stateController,
                        ),

                        buildLabel("Pincode *"),
                        buildField(
                          "Pincode",
                          pincodeController,
                        ),

                        const SizedBox(
                            height: 30),

                        SizedBox(
                          width: double.infinity,
                          height:45,

                          child:
                              ElevatedButton(
                            onPressed:
                                saveAddress,

                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colours.primarycolour,

                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        20),
                              ),
                            ),

                            child:
                                const Text(
                              "Save Address",

                              style:
                                  TextStyle(
                                color:
                                    Colors.white,

                                fontSize:
                                    16,

                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                            height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
  Widget buildField(
    String hint,
    TextEditingController controller,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 22,
      ),
      child: 
        SizedBox(
          height: 58,
          child: TextFormField(

        controller: controller,

        decoration: InputDecoration(
          hintText: hint,

          filled: true,

          fillColor: Colors.white,

          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),

          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
                    16),

            borderSide:
                BorderSide(
              color:
                  Colours.brownColour,
            ),
          ),

          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
                    16),

            borderSide:
                BorderSide(
              color:
                  Colours.brownColour,
            ),
          ),

          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
                    16),

            borderSide:
                BorderSide(
              color:
                  Colours.primarycolour,
              width: 1.5,
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget buildLabel(String text) {
    bool isRequired = text.contains("*");

    String labelText =
        text.replaceAll("*", "").trim();

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: labelText,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              if (isRequired)
                const TextSpan(
                  text: " *",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}