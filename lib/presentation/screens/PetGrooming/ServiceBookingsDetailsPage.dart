import 'package:flutter/material.dart';
import 'package:pawlli/core/storage_manager/colors.dart';

import 'package:pawlli/data/model/GroomingBookingsmodel.dart';

class GroomingBookingDetailsPage extends StatelessWidget {
  final GroomingBooking booking;

  GroomingBookingDetailsPage({
    super.key,
    required this.booking,
  });

  final Color primaryColor = const Color.fromRGBO(245, 169, 38, 1);
  final Color brownColor = const Color.fromRGBO(127, 90, 76, 1);

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
      final parsed = DateTime.parse(date).toLocal();
      return '${parsed.day.toString().padLeft(2, '0')}-'
          '${parsed.month.toString().padLeft(2, '0')}-'
          '${parsed.year} '
          '${parsed.hour.toString().padLeft(2, '0')}:'
          '${parsed.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return date;
    }
  }

  Widget _summaryRow(
    String title,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            flex: 4,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: valueColor ?? Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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

              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.maybePop(context),
              ),

              title: Text(
                'Booking Details',
                style: TextStyle(
                  color: brownColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: booking.petImage.isNotEmpty
                    ? Image.network(
                        booking.petImage,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.pets,
                            size: 48,
                            color: Colours.primarycolour,
                          );
                        },
                      )
                    : Icon(
                        Icons.pets,
                        size: 48,
                        color: Colours.primarycolour,
                      ),
              ),
            ),

            const SizedBox(height: 15),

            _sectionTitle('Booking Summary', Icons.bookmark),

            // Booking Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colours.primarycolour,
                  width: 0.8,
                ),
              ),
              child: Column(
                children: [


                  _summaryRow(
                    'Booking ID',
                    booking.id.toString(),
                  ),

                  _summaryRow(
                    'Booking Status',
                    booking.status,
                    valueColor: getStatusColor(booking.status),
                  ),

                  _summaryRow(
                    'Payment Status',
                    booking.paymentStatus,
                    valueColor: getStatusColor(booking.paymentStatus),
                  ),

                  _summaryRow(
                    'Booking Amount',
                    '₹${booking.price}',
                  ),

                ],
              ),
            ),

            const SizedBox(height: 18),

            // if (booking.petImage.isNotEmpty)
            // Center(
            //   child: ClipRRect(
            //     borderRadius: BorderRadius.circular(12),
            //     child: Image.network(
            //       booking.petImage,
            //       width: 100,
            //       height: 100,
            //       fit: BoxFit.cover,
            //       errorBuilder: (_, __, ___) =>
            //           const Icon(Icons.pets, size: 60),
            //     ),
            //   ),
            // ),

            // Pet details
            _sectionTitle('Pet Details', Icons.pets),

            _detailsCard([
              _detailRow('Pet Name', booking.petName),
              // _detailRow('Pet ID', booking.pet.toString()),
              _detailRow('Pet Type', booking.petType),
              _detailRow('Breed', booking.petBreed),
              _detailRow('Age', booking.petAge),
              // _detailRow('Pet Category ID',
              //     booking.petCategory.toString()),
            ]),

            const SizedBox(height: 18),

            // Service details
            _sectionTitle('Service Details', Icons.spa),

            _detailsCard([
              _detailRow('Service Name', booking.serviceName),
              // _detailRow('Main Service ID',
              //     booking.mainService.toString()),
              _detailRow('Service Type', booking.serviceType),
              // _detailRow('Service Category ID',
              //     booking.serviceCategoryId.toString()),

              // _detailRow('Pricing Plan ID',
              //     booking.pricingPlan?.toString() ?? 'N/A'),

              if (booking.serviceType == "ONE_TIME")
                _detailRow('Package Name', booking.packageName ?? 'N/A'),
            ]),

            if (booking.serviceType == "PLAN") ...[

            const SizedBox(height: 10),

            _detailsCard([
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Included Services',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colours.brownColour,
                    ),
                  ),
                ),
              ),

              ...booking.includedServices.map((service) {
                return _detailRow(
                  service['name']?.toString() ?? 'N/A',
                  'Yes',
                );
              }),
            ]),

            const SizedBox(height: 18),

            _sectionTitle('Plan Details', Icons.calendar_month),

            _detailsCard([
              _detailRow(
                'Sessions Per Month',
                booking.sessionsPerMonth.toString(),
              ),
              _detailRow(
                'Number Of Months',
                booking.numberOfMonths.toString(),
              ),
              _detailRow(
                'Total Sessions',
                booking.totalSessions.toString(),
              ),
              _detailRow(
                'Plan Price',
                '₹${booking.planPrice}',
              ),
            ]),
          ],
          const SizedBox(height: 18),

            // Customer details
            _sectionTitle('Customer Details', Icons.person),
            _detailsCard([
              _detailRow('Customer Name', booking.customerName),
              _detailRow('Contact Number', booking.contactNumber),
              _detailRow('House Number', booking.houseNumber),
              _detailRow('Area', booking.area),
              _detailRow('Locality', booking.locality),
              _detailRow('Landmark', booking.landmark),
              _detailRow('Complete Address', booking.completeAddress),
              // _detailRow('Latitude', booking.latitude),
              // _detailRow('Longitude', booking.longitude),
            ]),

            const SizedBox(height: 18),

            // Payment
            _sectionTitle('Payment Details', Icons.payment),
            _detailsCard([
              _detailRow('Booking Amount', '₹${booking.price}'),
              _detailRow(
                'Payment Status',
                booking.paymentStatus,
                valueColor: getStatusColor(booking.paymentStatus),
              ),
              _detailRow(
                'Booking Status',
                booking.status,
                valueColor: getStatusColor(booking.status),
              ),
            ]),

            const SizedBox(height: 18),

            // Booking date
            _sectionTitle('Booking Information', Icons.calendar_month),
            _detailsCard([
              _detailRow(
                'Created At',
                formatDate(booking.createdAt),
              ),
              _detailRow('Booking ID', booking.id.toString()),
            ]),

            const SizedBox(height: 18),

            // Sessions
            _sectionTitle('Booking Sessions', Icons.event_available),

            if (booking.sessions.isEmpty)
              _detailsCard([
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('No sessions available'),
                ),
              ])
            else
              ...booking.sessions.asMap().entries.map((entry) {
                final session = entry.value;

                if (session is! Map) {
                  return const SizedBox.shrink();
                }

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colours.primarycolour,
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        'Session ${session['session_number'] ?? entry.key + 1}',
                        style: TextStyle(
                          color: Colours.brownColour,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),

                      const Divider(),

                      // _detailRow(
                      //   'Session ID',
                      //   session['id']?.toString() ?? 'N/A',
                      // ),

                      _detailRow(
                        'Scheduled Date',
                        session['scheduled_date']?.toString() ?? 'N/A',
                      ),

                      _detailRow(
                        'Start Time',
                        session['start_time']?.toString() ?? 'N/A',
                      ),

                      // _detailRow(
                      //   'Service Slot ID',
                      //   session['service_slot']?.toString() ?? 'N/A',
                      // ),

                      _detailRow(
                        'Session Status',
                        session['status']?.toString() ?? 'N/A',
                      ),

                      // const Divider(),

                    ],
                  ),
                );
              }),

                // staff assignment

                const SizedBox(height: 18),

                _sectionTitle('Staff Assignment', Icons.people),

                _detailsCard([
                  _detailRow(
                    'Assignment Type',
                    booking.sessions.isNotEmpty
                        ? booking.sessions.first['assignment_type']?.toString() ?? 'N/A'
                        : 'N/A',
                  ),

                  _detailRow(
                    'Assignment Status',
                    booking.sessions.isNotEmpty
                        ? booking.sessions.first['assignment_status']?.toString() ?? 'N/A'
                        : 'N/A',
                  ),

                  _detailRow(
                    'Assigned Staff',
                    booking.sessions.isNotEmpty
                        ? booking.sessions.first['assigned_staff']?.toString() ?? 'Not Assigned'
                        : 'Not Assigned',
                  ),

                  _detailRow(
                    'Assigned Center',
                    booking.sessions.isNotEmpty
                        ? booking.sessions.first['assigned_center']?.toString() ?? 'Not Assigned'
                        : 'Not Assigned',
                  ),

                  if (booking.sessions.isNotEmpty &&
                      booking.sessions.first['staff_details'] is Map) ...[
                    const Divider(),

                    const Text(
                      'Staff Information',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    ...(booking.sessions.first['staff_details'] as Map).entries.map(
                      (e) => _detailRow(
                        e.key.toString(),
                        e.value?.toString() ?? 'N/A',
                      ),
                    ),
                  ],
                ]),

                const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: brownColor, size: 21),
          const SizedBox(width: 9),
          Text(
            title,
            style: TextStyle(
              color: brownColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colours.primarycolour,
          width: 0.8,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _detailRow(
    String title,
    String value, {
    Color? valueColor,
  }) {
    final displayValue =
        value.trim().isEmpty ? 'N/A' : value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              displayValue,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text) {
    final status = text.split(': ').last;
    final color = getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}