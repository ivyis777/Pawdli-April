
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/controller/GroomingPlansController.dart';
import 'package:pawlli/presentation/screens/PetGrooming/BuildPlans/GroomingBookingPage.dart';
import 'package:pawlli/presentation/screens/PetGrooming/BuildPlans/GroomingDetailsPage.dart';

class BuildGroomingPlanPage extends StatefulWidget {
  const BuildGroomingPlanPage({super.key});

  @override
  State<BuildGroomingPlanPage> createState() =>
      _BuildGroomingPlanPageState();
}

class _BuildGroomingPlanPageState
    extends State<BuildGroomingPlanPage> {
  late final GroomingServiceListController controller;

  final Map<int, Future<String?>> _priceRequests = {};

  @override
  void initState() {
    super.initState();

    controller = Get.put(
      GroomingServiceListController(),
      tag: 'grooming_service_list',
    );
  }

  Future<String?> _fetchStartingPrice(int serviceId) async {
    try {
      final details = await ApiService.fetchGroomingServiceDetails(
        serviceId,
      );

      if (details.pricingPlans.isEmpty) return null;

      final prices = details.pricingPlans
          .map((plan) => double.tryParse(plan.price))
          .whereType<double>()
          .toList();

      if (prices.isEmpty) return null;

      prices.sort();
      return '₹${prices.first.toStringAsFixed(0)}';
    } catch (e) {
      debugPrint('Price fetch failed for service $serviceId: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).size.height * 0.055,
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          flexibleSpace: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 250,
              height: 100,
              child: Image.network(
                'https://app.pawdli.com/media/static/topimage.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),
          title: Text(
            'Grooming Plans',
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              color: Colours.brownColour,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.fetchServices,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.services.isEmpty) {
          return const Center(
            child: Text('No grooming services available.'),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 16,
          ),
          itemCount: controller.services.length,
          itemBuilder: (context, index) {
            final service = controller.services[index];

            // Cache each price request so list rebuilds do not
            // repeatedly request the same service details.
            final priceRequest = _priceRequests.putIfAbsent(
              service.id,
              () => _fetchStartingPrice(service.id),
            );

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colours.brownColour,
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.name,
                              style: TextStyle(
                                fontSize: screenWidth * 0.040,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              service.description,
                              style: TextStyle(
                                fontSize: screenWidth * 0.030,
                                height: 1.2,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Starts From',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: screenWidth * 0.025,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          FutureBuilder<String?>(
                            future: priceRequest,
                            builder: (context, snapshot) {
                              final price = snapshot.data;

                              return Text(
                                price ??
                                    (snapshot.connectionState ==
                                            ConnectionState.waiting
                                        ? '...'
                                        : 'N/A'),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: screenWidth * 0.045,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              Get.to(
                                () => GroomingDetailsPage(
                                  serviceId: service.id,
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colours.brownColour,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'View Details',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: screenWidth * 0.032,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BuildPlanBookingPage(
                                    serviceName: service.name,
                                    serviceId: service.id,
                                  ),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              backgroundColor: Colors.white,
                              foregroundColor: Colours.primarycolour,
                              side: BorderSide(
                                color: Colours.primarycolour,
                                width: 0.8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Booking',
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: screenWidth * 0.032,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
      }),
    );
  }
}
