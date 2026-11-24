
import 'package:flutter/material.dart';

class AvailableServiceSlotsResponse {
  final int serviceId;
  final String serviceName;
  final String month;
  final List<AvailableServiceDateModel> availableDates;

  AvailableServiceSlotsResponse({
    required this.serviceId,
    required this.serviceName,
    required this.month,
    required this.availableDates,
  });

  factory AvailableServiceSlotsResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final List<dynamic> dates = json['available_dates'] is List
        ? json['available_dates']
        : [];

    return AvailableServiceSlotsResponse(
      serviceId: _toInt(json['service_id']),
      serviceName: json['service_name']?.toString() ?? '',
      month: json['month']?.toString() ?? '',
      availableDates: dates
          .map(
            (item) => AvailableServiceDateModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class AvailableServiceDateModel {
  final String date;
  final String day;
  final List<String> slots;

  AvailableServiceDateModel({
    required this.date,
    required this.day,
    required this.slots,
  });

  factory AvailableServiceDateModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AvailableServiceDateModel(
      date: json['date']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      slots: (json['slots'] as List<dynamic>? ?? [])
          .map((slot) => slot.toString())
          .toList(),
    );
  }

  // Example: 2026-10-27 -> DateTime
  DateTime? get parsedDate {
    return DateTime.tryParse(date);
  }

  // Example: 13:30 -> 1:30 PM
  String formatTime(String time) {
    final parts = time.split(':');

    if (parts.length < 2) return time;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null ||
        hour < 0 || hour > 23 ||
        minute < 0 || minute > 59) {
      return time;
    }

    final timeOfDay = TimeOfDay(
      hour: hour,
      minute: minute,
    );

    final hour12 = timeOfDay.hourOfPeriod == 0
        ? 12
        : timeOfDay.hourOfPeriod;

    return '$hour12:${minute.toString().padLeft(2, '0')} '
        '${timeOfDay.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

  // Converts 01:30 PM -> 13:30:00 if needed by another API.
  static String toApiTime(String displayTime) {
    final parsed = displayTime.trim().split(RegExp(r'\s+'));

    if (parsed.length != 2) return displayTime;

    final timeParts = parsed[0].split(':');
    if (timeParts.length != 2) return displayTime;

    var hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);

    if (hour == null || minute == null ||
        hour < 1 || hour > 12 ||
        minute < 0 || minute > 59) {
      return displayTime;
    }

    final period = parsed[1].toUpperCase();

    if (period != 'AM' && period != 'PM') {
      return displayTime;
    }

    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}:00';
  }
}
