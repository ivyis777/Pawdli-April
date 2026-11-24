import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/GroomingBookingsController.dart';
import 'package:pawlli/data/model/GroomingBookingsmodel.dart';
import 'package:pawlli/presentation/screens/PetGrooming/ServiceBookingsDetailsPage.dart';

class MyGroomingBookingsPage extends StatefulWidget {
  const MyGroomingBookingsPage({super.key});

  @override
  State<MyGroomingBookingsPage> createState() =>
      _MyGroomingBookingsPageState();
}

class _MyGroomingBookingsPageState
    extends State<MyGroomingBookingsPage> {
  late GroomingBookingController controller;

  final Color primaryColor = const Color.fromRGBO(245, 169, 38, 1);
  final Color brownColor = const Color.fromRGBO(127, 90, 76, 1);

  @override
  void initState() {
    super.initState();

    controller = GroomingBookingController();
    controller.fetchBookings();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
      case 'COMPLETED':
      case 'PAID':
        return Colors.green;

      case 'PENDING':
      case 'DRAFT':
        return Colors.orange;

      case 'CANCELLED':
      case 'FAILED':
        return Colors.red;

      case 'REFUNDED':
        return Colors.blue;

      default:
        return brownColor;
    }
  }

  String formatDate(String date) {
    try {
      return DateFormat('dd MMM yyyy, hh:mm a')
          .format(DateTime.parse(date).toLocal());
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colours.secondarycolour,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Stack(
          children: [
            // Background top image
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.55,
                height: 90,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://app.pawdli.com/media/static/topimage.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // AppBar
            AppBar(
              centerTitle: true,
              // elevation: 1,
              backgroundColor: Colors.transparent,
              foregroundColor: brownColor,

              title: Text(
                'Bookings',
                style: TextStyle(
                  color: brownColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
            ),
          ],
        ),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),

              // Booking filter
              SizedBox(
                height: 43,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.filters.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: 9),
                  itemBuilder: (context, index) {
                    final filter = controller.filters[index];
                    final selected =
                        controller.selectedFilter == filter;

                    return GestureDetector(
                      onTap: () => controller.changeFilter(filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? brownColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: selected
                                ? brownColor
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          filter[0].toUpperCase() +
                              filter.substring(1),
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : brownColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Bookings',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: brownColor,
                      ),
                    ),
                    Text(
                      '${controller.totalBookings} Bookings',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: _buildBookingList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingList() {
    if (controller.isLoading && controller.bookings.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    if (controller.errorMessage != null &&
        controller.bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 45,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(
                controller.errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: controller.refreshBookings,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (controller.bookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.refreshBookings,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 120),
            Icon(
              Icons.pets,
              size: 65,
              color: brownColor.withOpacity(0.4),
            ),
            const SizedBox(height: 15),
            const Center(
              child: Text(
                'No grooming bookings found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshBookings,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: controller.bookings.length,
        itemBuilder: (context, index) {
          final booking = controller.bookings[index];

          return _bookingCard(booking);
        },
      ),
    );
  }

  Widget _bookingCard(GroomingBooking booking) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GroomingBookingDetailsPage(
              booking: booking,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking ID and status
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking Id: ${booking.id}',
                  style: TextStyle(
                    color: brownColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                _statusBadge(booking.status),
              ],
            ),

            const SizedBox(height: 14),

            // Pet and service
            Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: booking.petImage.isNotEmpty
                        ? Image.network(
                            booking.petImage,
                            height: 48,
                            width: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.pets,
                                color: brownColor,
                                size: 26,
                              );
                            },
                          )
                        : Icon(
                            Icons.pets,
                            color: brownColor,
                            size: 26,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.petName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.serviceName,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${booking.price}',
                  style: TextStyle(
                    color: brownColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            Divider(color: Colors.grey.shade200),

            const SizedBox(height: 5),

            Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  size: 17,
                  color: brownColor,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    formatDate(booking.createdAt),
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: brownColor,
                  size: 15,
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(
                  Icons.payment,
                  size: 17,
                  color: Colors.green,
                ),
                const SizedBox(width: 7),
                const Text(
                  'Payment: ',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  booking.paymentStatus,
                  style: TextStyle(
                    color: getStatusColor(booking.paymentStatus),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color = getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}