
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/GroomingServicePlansController.dart';

class GroomingDetailsPage extends StatefulWidget {
  final int serviceId;

  const GroomingDetailsPage({
    super.key,
    required this.serviceId,
  });

  @override
  State<GroomingDetailsPage> createState() =>
      _GroomingDetailsPageState();
}

class _GroomingDetailsPageState
    extends State<GroomingDetailsPage> {
  late final GroomingServiceController controller;

  @override
  void initState() {
    super.initState();

    final tag = 'grooming_${widget.serviceId}';

    if (Get.isRegistered<GroomingServiceController>(tag: tag)) {
      controller = Get.find<GroomingServiceController>(tag: tag);
    } else {
      controller = Get.put(
        GroomingServiceController(),
        tag: tag,
      );
      controller.fetchServiceDetails(widget.serviceId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colours.brownColour,
        elevation: 0,
        title: Obx(
          () => Text(
            controller.service.value?.name ?? 'Service Details',
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
                    onPressed: () => controller.fetchServiceDetails(
                      widget.serviceId,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final service = controller.service.value;

        if (service == null) {
          return const Center(
            child: Text('No service details found.'),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (service.image != null)
                Image.network(
                  service.image!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey.shade100,
                    child: const Icon(
                      Icons.pets,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
                )
              else
                Container(
                  height: 250,
                  width: double.infinity,
                  color: Colors.grey.shade100,
                  child: const Icon(
                    Icons.pets,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      service.description,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Included Services',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (service.includedServices.isEmpty)
                      const Text('No included services available.')
                    else
                      ...service.includedServices.map(
                        (item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          title: Text(item.name),
                          subtitle: item.description.isNotEmpty
                              ? Text(item.description)
                              : null,
                          trailing: item.image == null
                              ? null
                              : ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(8),
                                  child: Image.network(
                                    item.image!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.pets),
                                  ),
                                ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    const Text(
                      'Available Pricing Plans',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (service.pricingPlans.isEmpty)
                      const Text('No pricing plans available.')
                    else
                      ...service.pricingPlans.map(
                        (plan) => Card(
                          elevation: 0,
                          color: Colors.grey.shade50,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(
                              plan.formattedPrice,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            subtitle: Text(
                              '${plan.sessionsPerMonth} session(s) '
                              'per month\n'
                              '${plan.numberOfMonths} month(s) • '
                              '${plan.totalSessions} total sessions',
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colours.primarycolour,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Get.snackbar(
                            'Grooming',
                            'Connect your booking flow here.',
                          );
                        },
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
