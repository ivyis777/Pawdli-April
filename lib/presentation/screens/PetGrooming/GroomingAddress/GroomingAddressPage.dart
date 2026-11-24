import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/model/GroomingAddressModel.dart';
import 'package:pawlli/data/model/ServiceCartModel.dart';
import 'package:pawlli/presentation/screens/PetGrooming/GroomingAddress/AddressFormBottomSheet.dart';
import 'package:pawlli/presentation/screens/PetGrooming/GroomingAddress/MapSelectionBottomSheet.dart';
import 'package:pawlli/presentation/screens/PetGrooming/BuildPlans/GroomingSlotPage.dart';

class BuildPlanAddressPage extends StatefulWidget {
  final String serviceName;
  final int selectedSession;
  final int selectedDuration;
  final int totalSessions;
  final int totalPrice;
  final String selectedPet;
  final int petId;
  final int serviceId;
  final int pricingPlanId;
  final String peopleComfortLevel;
  final String dogsComfortLevel;
  final String contactNumber;
  final double latitude;
  final double longitude;
  final int? editCartItemId;
  final GroomingCartItemModel? existingCartItem;


  const BuildPlanAddressPage({
    super.key,
    required this.serviceName,
    required this.selectedSession,
    required this.selectedDuration,
    required this.totalSessions,
    required this.totalPrice,
    required this.selectedPet,
    required this.petId,
    required this.serviceId,
    required this.pricingPlanId,
    required this.peopleComfortLevel,
    required this.dogsComfortLevel,
    required this.contactNumber,
    required this.latitude,
    required this.longitude,
    this.editCartItemId,
    this.existingCartItem,
  });

  @override
  State<BuildPlanAddressPage> createState() => _BuildPlanAddressPageState();
}

class _BuildPlanAddressPageState extends State<BuildPlanAddressPage> {
  final box = GetStorage();

  List<AddressModel> addresses = [];

  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    loadAddresses();
  }

  void loadAddresses() {
    final List saved = box.read("saved_addresses") ?? [];

    addresses = saved.map((e) {
      return AddressModel.fromJson(
        Map<String, dynamic>.from(e),
      );
    }).toList();

    final existing = widget.existingCartItem;

    if (existing != null) {
      selectedIndex = addresses.indexWhere((address) {
        return address.houseNo.trim() ==
                existing.houseNumber.trim() &&
            address.area.trim() == existing.area.trim() &&
            address.locality.trim() == existing.locality.trim();
      });
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final width =
        MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: Stack(
            children: [
              SizedBox(
                width: 220,
                height: 110,
                child: Image.network(
                  "https://app.pawdli.com/media/static/topimage.png",
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    buildStepperSection(),

                    const SizedBox(height: 35),

                    // Container(
                    //   padding: const EdgeInsets.all(16),
                    //   decoration: BoxDecoration(
                    //     color: Colours.secondarycolour,
                    //     borderRadius: BorderRadius.circular(20),
                    //     border: Border.all(
                    //       color: Colours.brownColour,
                    //     ),
                    //   ),
                    //   child: Row(
                    //     children: [
                    //       Container(
                    //         height: 55,
                    //         width: 55,
                    //         decoration: BoxDecoration(
                    //           color: Colours.primarycolour.withOpacity(.15),
                    //           borderRadius: BorderRadius.circular(14),
                    //         ),
                    //         child: Icon(
                    //           Icons.pets,
                    //           color: Colours.primarycolour,
                    //         ),
                    //       ),

                    //       const SizedBox(width: 12),

                    //       Expanded(
                    //         child: Column(
                    //           crossAxisAlignment:
                    //               CrossAxisAlignment.start,
                    //           children: [
                    //             Text(
                    //               widget.serviceName,
                    //               style: TextStyle(
                    //                 fontSize: 16,
                    //                 fontWeight: FontWeight.w700,
                    //                 color: Colours.brownColour,
                    //               ),
                    //             ),

                    //             const SizedBox(height: 4),

                    //             Text(
                    //               widget.selectedPet,
                    //               style: TextStyle(
                    //                 fontSize: 13,
                    //                 color: Colors.grey.shade700,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    // const SizedBox(height: 25),

                    Text(
                      "Select Address",
                      style: TextStyle(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(
                        height: 20),

                    addAddressField(),

                    const SizedBox(
                        height: 30),

                    Text(
                      "Saved Address List",
                      style: TextStyle(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(
                        height: 15),

                    ...List.generate(
                      addresses.length,
                      (index) =>
                          addressCard(
                        addresses[index],
                        index,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            bottomSummary(),
          ],
        ),
      ),
    );
  }

  Widget addAddressField() {
    return GestureDetector(
      onTap: () async {
        final location =
            await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) =>
              const MapSelectionBottomSheet(),
        );

        if (location != null) {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) =>
                AddressFormBottomSheet(
              latitude:
                  location.latitude,
              longitude:
                  location.longitude,
            ),
          );

          loadAddresses();
        }
      },
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(
        horizontal: 18),
        decoration: BoxDecoration(
          color: Colours.secondarycolour,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colours.brownColour,
          ),
        ),
        child: Row(
          children: [

            Expanded(
              child: Text(
                "Add Address",
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
              ),
            ),

            Icon(
              Icons.add_circle_outline,
              color:
                  Colours.primarycolour,
            )
          ],
        ),
      ),
    );
  }

    Widget addressCard(
      AddressModel address,
      int index,
    ) {
      bool selected = selectedIndex == index;

      return Dismissible(
        key: ValueKey(
          "${address.houseNo}_${address.area}_${address.locality}_${address.pincode}",
        ),
        direction: DismissDirection.endToStart,

        background: Container(
          margin: const EdgeInsets.only(
            bottom: 16,
          ),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius:
                BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 28,
          ),
        ),

        confirmDismiss: (direction) async {
          return await showDialog<bool>(
                context: context,
                builder: (context) =>
                    AlertDialog(
                  title: const Text(
                    "Delete Address",
                  ),
                  content: const Text(
                    "Are you sure you want to delete this address?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          false,
                        );
                      },
                      child:
                          const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          true,
                        );
                      },
                      child: const Text(
                        "Delete",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ) ??
              false;
        },

        onDismissed: (direction) {
          setState(() {
            addresses.removeAt(index);

            if (selectedIndex == index) {
              selectedIndex = -1;
            } else if (selectedIndex >
                index) {
              selectedIndex--;
            }
          });

          box.write(
            "saved_addresses",
            addresses
                .map(
                  (e) => e.toJson(),
                )
                .toList(),
          );

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            const SnackBar(
              content: Text(
                "Address deleted",
              ),
            ),
          );
        },

        child: GestureDetector(
          onTap: () {
            setState(() {
              selectedIndex = index;
            });
          },
          child: Container(
            margin:
                const EdgeInsets.only(
              bottom: 16,
            ),
            padding:
                const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  Colours.secondarycolour,
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
              border: Border.all(
                color: selected
                    ? Colours
                        .primarycolour
                    : Colours
                        .brownColour,
                width:
                    selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: RichText(
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "${address.houseNo}, ",
                          style:
                              const TextStyle(
                            fontSize: 15,
                            color:Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: "${address.area}, ${address.locality}, ${address.city}, ${address.state}, ${address.pincode}",
                          style:
                              TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    Widget buildStepperSection() {
      return Column(
        children: [
          // =========================================================
          // CIRCLES + LINES
          // =========================================================

          Row(
            children: [
              // Build Plan completed
              completedStep(),

              Expanded(
                child: activeLine(),
              ),

              completedStep(),

              Expanded(
                child: activeLine(),
              ),

              activeStep(),

              Expanded(
                child: inactiveLine(),
              ),

              inactiveStep(),

              Expanded(
                child: inactiveLine(),
              ),

              inactiveStep(),
            ],
          ),

          const SizedBox(height: 8),

          // =========================================================
          // STEP TEXTS
          // =========================================================

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "Build\nPlan",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colours.brownColour,
                    fontSize: 10,
                    height: 1.4,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),

              Expanded(
                child: Text(
                  "Add\nDetails",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colours.brownColour,
                    fontSize: 10,
                    height: 1.4,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),

              Expanded(
                child: Text(
                  "Add\nAddress",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colours.brownColour,
                    fontSize: 10,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              Expanded(
                child: Text(
                  "Select\nSlot",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              Expanded(
                child: Text(
                  "Preview\nSchedule",
                  textAlign:
                      TextAlign.right,
                  style: TextStyle(
                    color:
                        Colors.grey.shade500,
                    fontSize: 10,
                    height: 1.4,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // =============================================================
    // COMPLETED STEP
    // =============================================================

    Widget completedStep() {
      return Container(
        height: 24,
        width: 24,
        decoration: BoxDecoration(
          color:
              Colours.primarycolour,
          shape:
              BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          size: 15,
          color: Colors.white,
        ),
      );
    }

    // =============================================================
    // ACTIVE STEP
    // =============================================================

    Widget activeStep() {
      return Container(
        height: 24,
        width: 24,
        decoration: BoxDecoration(
          color:
              Colours.primarycolour,
          shape:
              BoxShape.circle,
        ),
        child: Center(
          child: Container(
            height: 9,
            width: 9,
            decoration:
                const BoxDecoration(
              color: Colors.white,
              shape:
                  BoxShape.circle,
            ),
          ),
        ),
      );
    }

    // =============================================================
    // INACTIVE STEP
    // =============================================================

    Widget inactiveStep() {
      return Container(
        height: 24,
        width: 24,
        decoration: BoxDecoration(
          color: Colors.white,

          shape:
              BoxShape.circle,

          border:
              Border.all(
            color:
                Colors.grey.shade400,
            width: 1.5,
          ),
        ),
      );
    }

    // =============================================================
    // ACTIVE LINE
    // =============================================================

    Widget activeLine() {
      return Container(
        height: 1.5,
        color:
            Colours.primarycolour,
      );
    }

    // =============================================================
    // INACTIVE LINE
    // =============================================================

    Widget inactiveLine() {
      return Container(
        height: 1.5,
        color:
            Colors.grey.shade300,
      );
    }
  Widget stepText(
    String text,
    bool active,
  ) {
    return SizedBox(
      width: 60,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: active
              ? FontWeight.w600
              : FontWeight.w400,
          color: active
              ? Colours.brownColour
              : Colors.grey,
        ),
      ),
    );
  }
  Widget bottomSummary() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.05, 14,
        screenWidth * 0.05, 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset:
                const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// PLAN DETAILS + PRICE
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    "${widget.serviceName} • "
                    "${widget.selectedSession} Session"
                    "${widget.selectedSession > 1 ? "s" : ""} • "
                    "${widget.selectedDuration} Months\n"
                    "Total ${widget.totalSessions} Sessions",
                    style: TextStyle(
                      fontSize:
                          screenWidth * 0.03,
                      height: 1.4,
                      fontWeight:
                          FontWeight.w500,
                      color:
                          Colors.grey.shade700,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Text(
                  "₹${widget.totalPrice}",
                  style: TextStyle(
                    fontSize:
                        screenWidth * 0.042,
                    fontWeight:
                        FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            /// CONTINUE BUTTON

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {

                  if (selectedIndex == -1) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please select address",
                        ),
                      ),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroomingSlotSelectionPage(
                        serviceName: widget.serviceName,
                        selectedSession: widget.selectedSession,
                        selectedDuration: widget.selectedDuration,
                        totalSessions: widget.totalSessions,
                        totalPrice: widget.totalPrice,
                        selectedPet: widget.selectedPet,
                        selectedAddress: addresses[selectedIndex],
                        mainServiceId: widget.serviceId,
                        petId: widget.petId,
                        pricingPlanId: widget.pricingPlanId,
                        peopleComfortLevel: widget.peopleComfortLevel,
                        dogsComfortLevel: widget.dogsComfortLevel,
                        contactNumber: widget.contactNumber,
                        latitude: widget.latitude,
                        longitude: widget.longitude,
                        editCartItemId: widget.editCartItemId,
                        existingCartItem: widget.existingCartItem,
                      ),
                    ),
                  );  
                },
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colours.primarycolour,
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                            16),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}