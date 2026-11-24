// import 'package:flutter/material.dart';
// import 'package:pawlli/core/storage_manager/colors.dart';
// import 'package:pawlli/data/model/GroomingAddressModel.dart';
// import 'package:pawlli/data/model/ServiceCartModel.dart';
// import 'package:pawlli/presentation/screens/PetGrooming/ServiceCartPage.dart';

// class OneTimeGroomingSlotSelectionPage extends StatefulWidget {
//   final String serviceName;
//   final int selectedSession;
//   final int selectedDuration;
//   final int totalSessions;
//   final int totalPrice;
//   final String selectedPet;
//   final AddressModel selectedAddress;
//   final List<Map<String, dynamic>> selectedServices;

//   const OneTimeGroomingSlotSelectionPage({
//   super.key,
//   required this.serviceName,
//   required this.selectedSession,
//   required this.selectedDuration,
//   required this.totalSessions,
//   required this.totalPrice,
//   required this.selectedPet,
//   required this.selectedAddress,
//   required this.selectedServices,
// });

//   @override

//   State<OneTimeGroomingSlotSelectionPage> createState() =>

//       _OneTimeGroomingSlotSelectionPageState();

// }

//   class _OneTimeGroomingSlotSelectionPageState

//       extends State<OneTimeGroomingSlotSelectionPage> {

//     int selectedDateIndex = 0;

//     String selectedTime = "";

//     late List<DateTime> dates;

//     @override

//     void initState() {

//       super.initState();

//       dates = List.generate(

//         30,

//         (index) => DateTime.now().add(

//           Duration(days: index),

//         ),

//       );

//     }

//      List<String> generateSlots() {

//   List<String> slots = [];

//   DateTime start =

//       DateTime(2025, 1, 1, 8, 0);

//   DateTime end =

//       DateTime(2025, 1, 1, 21, 0);

//   while (

//       start.isBefore(end) ||

//       start == end) {

//     slots.add(

//       TimeOfDay(

//         hour: start.hour,

//         minute: start.minute,

//       ).format(context),

//     );

//     start = start.add(

//       const Duration(minutes: 30),

//     );

//   }

//   return slots;

// }

//  @override

//   Widget build(BuildContext context) {

//     final slots = generateSlots();

//     return Scaffold(

//       backgroundColor: Colors.white,

//       appBar: PreferredSize(

//         preferredSize: const Size.fromHeight(90),

//         child: AppBar(

//           elevation: 0,

//           backgroundColor: Colors.transparent,

//           leading: IconButton(

//             icon: const Icon(

//               Icons.arrow_back_ios,

//               color: Colors.black,

//             ),

//             onPressed: () {

//               Navigator.pop(context);

//             },

//           ),

//           flexibleSpace: Stack(

//             children: [

//               SizedBox(

//                 width: 220,

//                 height: 110,

//                 child: Image.network(

//                   "https://app.pawdli.com/media/static/topimage.png",

//                   fit: BoxFit.cover,

//                 ),

//               ),

//             ],

//           ),

//         ),

//       ),

//       body: Column(

//         children: [

//           Expanded(

//             child: SingleChildScrollView(

//               padding:

//                   const EdgeInsets.all(20),

//               child: Column(

//                 crossAxisAlignment:

//                     CrossAxisAlignment.start,

//                 children: [

//                   buildOneTimeStepperSection(),

//                   const SizedBox(height: 30),

//                   const Text(

//                     "Select Your Slots",

//                     style: TextStyle(

//                       fontSize: 20,

//                       fontWeight:

//                           FontWeight.w600,

//                     ),

//                   ),

//                   const SizedBox(height: 20),

//                   Text(

//                     "Choose Date",

//                     style: TextStyle(

//                       fontSize: 15,

//                       fontWeight:

//                           FontWeight.w600,

//                       color:

//                           Colors.black,

//                     ),

//                   ),

//                   const SizedBox(height: 16),

//                   SizedBox(

//                     height: 95,

//                     child: ListView.builder(

//                       scrollDirection:

//                           Axis.horizontal,

//                       itemCount: dates.length,

//                       itemBuilder:

//                           (context, index) {

//                         bool selected =

//                             selectedDateIndex ==

//                                 index;

//                         DateTime date =

//                             dates[index];

//                         return GestureDetector(

//                           onTap: () {

//                             setState(() {

//                               selectedDateIndex =

//                                   index;

//                             });

//                           },

//                           child: Container(

//                             width: 80,

//                             margin:

//                                 const EdgeInsets.only(

//                               right: 12,

//                             ),

//                             decoration:

//                                 BoxDecoration(

//                               color: selected

//                                   ? Colours.primarycolour

//                                       .withOpacity(

//                                           .12)

//                                   : Colors.white,

//                               borderRadius:

//                                   BorderRadius.circular(

//                                       18),

//                               border: Border.all(

//                                 color: selected

//                                     ? Colours

//                                         .primarycolour

//                                     : Colours.brownColour,

//                                 width:0.5

//                               ),

//                             ),

//                             child: Column(

//                               mainAxisAlignment:

//                                   MainAxisAlignment

//                                       .center,

//                               children: [

//                                 Text(

//                                   [

//                                     "Sun",

//                                     "Mon",

//                                     "Tue",

//                                     "Wed",

//                                     "Thu",

//                                     "Fri",

//                                     "Sat"

//                                   ][date.weekday %

//                                       7],

//                                   style: TextStyle(

//                                     fontSize:14,

//                                     color: Colors.grey.shade500,

//                                   ),

//                                 ),

//                                 const SizedBox(

//                                     height: 8),

//                                 Text(

//                                   "${date.day}",

//                                   style:

//                                       const TextStyle(

//                                     fontSize:

//                                         20,

//                                     fontWeight:

//                                         FontWeight

//                                             .w600,

//                                   ),

//                                 ),

//                               ],

//                             ),

//                           ),

//                         );

//                       },

//                     ),

//                   ),

//                   const SizedBox(height: 30),

//                   Text(

//                     "Choose Time",

//                     style: TextStyle(

//                       fontSize: 15,

//                       fontWeight:

//                           FontWeight.w600,

//                       color:

//                           Colors.black,

//                     ),

//                   ),

//                   const SizedBox(height: 15),

//                   GridView.builder(

//                     shrinkWrap: true,

//                     physics:

//                         const NeverScrollableScrollPhysics(),

//                     itemCount: slots.length,

//                     gridDelegate:

//                         const SliverGridDelegateWithFixedCrossAxisCount(

//                       crossAxisCount: 3,

//                       mainAxisSpacing: 12,

//                       crossAxisSpacing: 12,

//                       childAspectRatio:

//                           2.4,

//                     ),

//                     itemBuilder:

//                         (context, index) {

//                       bool selected =

//                           selectedTime ==

//                               slots[index];

//                       return GestureDetector(

//                         onTap: () {

//                           setState(() {

//                             selectedTime =

//                                 slots[index];

//                           });

//                         },

//                         child: Container(

//                           decoration:

//                               BoxDecoration(

//                             color: selected

//                                 ? Colours

//                                     .primarycolour

//                                     .withOpacity(

//                                         .12)

//                                 : Colors.white,

//                             borderRadius:

//                                 BorderRadius.circular(

//                                     14),

//                             border:

//                                 Border.all(

//                               color: selected

//                                   ? Colours

//                                       .primarycolour

//                                   : Colours.brownColour,

//                               width:0.5,

//                             ),

//                           ),

//                           child: Center(

//                             child: Text(

//                               slots[index],

//                               style:

//                                   TextStyle(

//                                 fontSize:

//                                     14,

//                                 fontWeight:

//                                     FontWeight

//                                         .w600,

//                                 color: Colors.black

//                               ),

//                             ),

//                           ),

//                         ),

//                       );

//                     },

//                   ),

//                 ],

//               ),

//             ),

//           ),

//           bottomSummary(),

//         ],

//       ),

//     );

//   }

//   Widget buildOneTimeStepperSection() {
//     final steps = <String>[
//       'Add\nDetails',
//       'Add\nAddress',
//       'Select\nSlot',
//     ];

//     return Column(
//       children: [
//         Row(
//           children: List.generate(steps.length * 2 - 1, (index) {
//             if (index.isOdd) {
//               return Expanded(
//                 child: Container(
//                   height: 1.5,
//                   color: Colours.primarycolour,
//                 ),
//               );
//             }

//             final stepIndex = index ~/ 2;
//             final isCompleted = stepIndex < 2;
//             final isActive = stepIndex == 2;

//             return Container(
//               width: 30,
//               height: 30,
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: isCompleted || isActive
//                     ? Colours.primarycolour
//                     : Colors.white,
//                 border: Border.all(
//                   color: isCompleted || isActive
//                       ? Colours.primarycolour
//                       : Colors.grey.shade400,
//                   width: 2,
//                 ),
//               ),
//               child: isCompleted
//                   ? const Icon(
//                       Icons.check,
//                       size: 16,
//                       color: Colors.white,
//                     )
//                   : isActive
//                       ? const Icon(
//                           Icons.circle,
//                           size: 10,
//                           color: Colors.white,
//                         )
//                       : null,
//             );
//           }),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           children: steps.asMap().entries.map((entry) {
//             final isActive = entry.key == 2;
//             return Expanded(
//               child: Text(
//                 entry.value,
//                 textAlign: entry.key == 0
//                     ? TextAlign.left
//                     : entry.key == 2
//                         ? TextAlign.right
//                         : TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 10,
//                   height: 1.4,
//                   color: isActive
//                       ? Colours.brownColour
//                       : entry.key < 2
//                           ? Colours.brownColour
//                           : Colors.grey.shade500,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget bottomSummary() {

//     final screenWidth = MediaQuery.of(context).size.width;

//     return Container(

//       padding:

//           const EdgeInsets.all(20),

//       decoration: BoxDecoration(

//         color: Colors.white,

//         boxShadow: [

//           BoxShadow(

//             color:

//                 Colors.black.withOpacity(

//                     0.05),

//             blurRadius: 10,

//           ),

//         ],

//       ),

//       child: Column(

//         mainAxisSize:

//             MainAxisSize.min,

//         children: [

//           Row(

//               crossAxisAlignment:

//                   CrossAxisAlignment.center,

//               children: [

//                 Expanded(

//                   child: Text(

//                     "${widget.serviceName}\\n"
//                     "Pet: ${widget.selectedPet}",

//                     style: TextStyle(

//                       fontSize:

//                           screenWidth * 0.03,

//                       height: 1.4,

//                       fontWeight:

//                           FontWeight.w500,

//                       color:

//                           Colors.grey.shade700,

//                     ),

//                   ),

//                 ),

//                 const SizedBox(width: 12),

//                 Text(

//                   "₹${widget.totalPrice}",

//                   style: TextStyle(

//                     fontSize:

//                         screenWidth * 0.042,

//                     fontWeight:

//                         FontWeight.w700,

//                     color: Colors.black,

//                   ),

//                 ),

//               ],

//             ),

//           const SizedBox(height: 15),

//           SizedBox(

//             width: double.infinity,

//             height: 55,

//             // child: ElevatedButton(

//             // // onPressed: selectedTime.isEmpty
//             // //     ? null
//             // //     : () async {
//             // //         try {
//             // //           final address = widget.selectedAddress;

//             // //           final String addressLine = [
//             // //             address.houseNo,
//             // //             address.flatFloor,
//             // //             address.area,
//             // //             address.locality,
//             // //             address.landmark,
//             // //             address.city,
//             // //             address.state,
//             // //             address.pincode,
//             // //           ]
//             // //               .where((value) => value.trim().isNotEmpty)
//             // //               .join(', ');

//             // //           // Save every selected grooming package separately.
                      
//             // //           if (widget.selectedServices.isEmpty) {
//             // //             throw Exception('No grooming services selected');
//             // //           }

//             // //           for (int index = 0;
//             // //               index < widget.selectedServices.length;
//             // //               index++) {
//             // //             final service = widget.selectedServices[index];

//             // //             final rawPrice = (service['price'] ?? service['totalPrice'] ?? '0').toString();
//             // //             final cleanPrice = rawPrice.replaceAll(
//             // //               RegExp(r'[^0-9.]'),
//             // //               '',
//             // //             );
//             // //             final price = double.tryParse(cleanPrice)?.round() ?? 0;

//             // //             debugPrint(
//             // //               'Service: ${service['name']}, '
//             // //               'Price: $rawPrice, Parsed: $price',
//             // //             );

//             // //             final item = GroomingCartItem(
//             // //               id: '${DateTime.now().microsecondsSinceEpoch}_$index',
//             // //               serviceName: (service['name'] ?? service['serviceName'] ?? '').toString(),
//             // //               selectedSession:
//             // //                   int.tryParse(service['selectedSession']?.toString() ?? '') ?? 1,
//             // //               selectedDuration:
//             // //                   int.tryParse(service['selectedDuration']?.toString() ?? '') ?? 1,
//             // //               totalSessions:
//             // //                   int.tryParse(service['totalSessions']?.toString() ?? '') ?? 1,
//             // //               totalPrice: price,
//             // //               firstDate: dates[selectedDateIndex].toIso8601String(),
//             // //               firstTime: selectedTime,
//             // //               petName: widget.selectedPet,
//             // //               petBreed: '',
//             // //               addressLine: addressLine,
//             // //             );

//             // //             await GroomingCartStorage.addItem(item);
//             // //           }


//             // //           if (!mounted) return;

//             // //           // Open the cart after saving.
//             // //           Navigator.push(
//             // //             context,
//             // //             MaterialPageRoute(
//             // //               builder: (_) => const GroomingCartPage(),
//             // //             ),
//             // //           );
//             // //         } catch (e) {
//             // //           if (!mounted) return;

//             // //           ScaffoldMessenger.of(context).showSnackBar(
//             // //             SnackBar(
//             // //               content: Text('Unable to add booking to cart: $e'),
//             // //             ),
//             // //           );
//             // //         }
//             // //       },


//             // //   style:

//             // //       ElevatedButton.styleFrom(

//             // //     backgroundColor:

//             // //         Colours.primarycolour,

//             // //   ),

//             // //   child: const Text(

//             // //     "Confirm Slot",

//             // //     style: TextStyle(

//             // //       color: Colors.white,

//             // //     ),

//             // //   ),

//             // ),

//           ),

//         ],

//       ),

//     );

//   }

// }