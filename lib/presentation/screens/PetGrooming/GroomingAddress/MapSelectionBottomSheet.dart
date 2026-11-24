import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:pawlli/core/storage_manager/colors.dart';


class SelectedLocation {
  final double latitude;
  final double longitude;

  SelectedLocation({
    required this.latitude,
    required this.longitude,
  });
}

class MapSelectionBottomSheet
    extends StatefulWidget {
  const MapSelectionBottomSheet({
    super.key,
  });

  @override
  State<MapSelectionBottomSheet>
      createState() =>
          _MapSelectionBottomSheetState();
}

class _MapSelectionBottomSheetState
    extends State<
        MapSelectionBottomSheet> {

  final MapController mapController = MapController();

  LatLng selectedLocation =
      const LatLng(
    17.3850,
    78.4867,
  );

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void>
      getCurrentLocation() async {

    bool serviceEnabled =
        await Geolocator
            .isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    LocationPermission
        permission =
        await Geolocator
            .checkPermission();

    if (permission ==
        LocationPermission.denied) {
      permission =
          await Geolocator
              .requestPermission();
    }

    Position position =
        await Geolocator
            .getCurrentPosition(
      desiredAccuracy:
          LocationAccuracy.high,
    );

    selectedLocation = LatLng(
      position.latitude,
      position.longitude,
    );

    // mapController.move(
    //   selectedLocation,
    //   16,
    // );

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          MediaQuery.of(context).size.height * 0.80,

      decoration: const BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),

      child: Column(
        children: [

          const SizedBox(height: 12),

          Container(
            width: 60,
            height: 5,
            decoration:
                BoxDecoration(
              color:
                  Colors.grey.shade300,
              borderRadius:
                  BorderRadius.circular(
                      20),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Row(
              children: [

                const Spacer(),

                Text(
                  "Select Location",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Colours.brownColour,
                  ),
                ),

                const Spacer(),

                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: selectedLocation,
                    initialZoom: 16,
                    onTap: (tapPosition, point) {
                      setState(() {
                        selectedLocation = point;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.ivyis.pawlli',
                    ),

                    MarkerLayer(
                      markers: [
                        Marker(
                          point: selectedLocation,
                          width: 60,
                          height: 60,
                          child: Icon(
                            Icons.location_pin,
                            color: Colours.primarycolour,
                            size: 45,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: () async {
                      await getCurrentLocation();

                      mapController.move(
                        selectedLocation,
                        16,
                      );
                    },
                    child: Icon(
                      Icons.my_location,
                      color: Colours.primarycolour,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.all(
                    20),
            child: SizedBox(
              width:
                  double.infinity,
              height: 55,
              child:
                  ElevatedButton(
                onPressed: () {

                  Navigator.pop(
                    context,

                    SelectedLocation(
                      latitude:
                          selectedLocation
                              .latitude,

                      longitude:
                          selectedLocation
                              .longitude,
                    ),
                  );
                },

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colours
                          .primarycolour,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                            16),
                  ),
                ),

                child: const Text(
                  "Confirm Location",

                  style: TextStyle(
                    color:
                        Colors.white,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}