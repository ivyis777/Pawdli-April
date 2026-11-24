import 'package:flutter/material.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/GroomingBookingsmodel.dart';

class GroomingBookingController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  String selectedFilter = 'paid';

  List<GroomingBooking> bookings = [];

  int totalBookings = 0;

  final List<String> filters = [
    'draft',
    'pending',
    'paid',
    'completed',
    'cancelled',
    'failed',
    'refunded',
  ];

  Future<void> fetchBookings({String? filter}) async {
    if (filter != null) {
      selectedFilter = filter;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response =
          await ApiService.fetchMyGroomingBookings(
        bookingFilter: selectedFilter,
      );

      bookings = response.data;
      totalBookings = response.totalBookings;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      bookings = [];
      totalBookings = 0;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeFilter(String filter) async {
    if (selectedFilter == filter) return;

    await fetchBookings(filter: filter);
  }

  Future<void> refreshBookings() async {
    await fetchBookings(filter: selectedFilter);
  }
}