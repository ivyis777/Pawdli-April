
import 'package:flutter/material.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/ServiceSlotsModel.dart';

class AvailableServiceSlotController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  AvailableServiceSlotsResponse? monthlyResponse;

  List<AvailableServiceDateModel> availableDates = [];

  AvailableServiceDateModel? selectedDate;
  String? selectedTime;

  String? selectedMonth;

  Future<void> fetchSlots({
    required int mainServiceId,
    required DateTime month,
  }) async {
    isLoading = true;
    errorMessage = null;

    // Clear data from the previous month.
    monthlyResponse = null;
    availableDates = [];
    selectedDate = null;
    selectedTime = null;

    selectedMonth =
        '${month.year.toString().padLeft(4, '0')}-'
        '${month.month.toString().padLeft(2, '0')}';

    notifyListeners();

    try {
      monthlyResponse =
          await ApiService.fetchAvailableServiceSlots(
        mainServiceId: mainServiceId,
        month: selectedMonth!,
      );

      availableDates = monthlyResponse!.availableDates;
    } catch (e) {
      errorMessage =
          e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectDate(AvailableServiceDateModel date) {
    selectedDate = date;
    selectedTime = null;
    notifyListeners();
  }

  void selectTime(String time) {
    if (selectedDate == null ||
        !selectedDate!.slots.contains(time)) {
      return;
    }

    selectedTime = time;
    notifyListeners();
  }

  List<String> get availableTimes {
    return selectedDate?.slots ?? [];
  }

  void clearSelection() {
    selectedDate = null;
    selectedTime = null;
    notifyListeners();
  }
}
