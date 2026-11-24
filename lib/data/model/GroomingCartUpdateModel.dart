
class GroomingUpdateSessionRequest {
  final String date;
  final String startTime;

  const GroomingUpdateSessionRequest({
    required this.date,
    required this.startTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'start_time': startTime,
    };
  }
}

class GroomingCartUpdateRequest {
  final int? mainCartId;
  final int cartItemId;
  final int petId;

  final int? pricingPlanId;
  final int? sessionsPerMonth;
  final int? numberOfMonths;
  final int? oneTimePackageId;

  final String contactNumber;
  final String peopleComfortLevel;
  final String dogsComfortLevel;
  final String houseNumber;
  final String area;
  final String locality;
  final String landmark;
  final String completeAddress;
  final double latitude;
  final double longitude;
  final String? action;
  final List<Map<String, dynamic>>? services;

  // NEW: send session dates and times, not service_slot_ids.
  final List<GroomingUpdateSessionRequest> sessions;

    GroomingCartUpdateRequest({
      this.mainCartId,
      required this.cartItemId,
      required this.petId,
      this.pricingPlanId,
      this.sessionsPerMonth,
      this.numberOfMonths,
      this.oneTimePackageId,
      required this.contactNumber,
      required this.peopleComfortLevel,
      required this.dogsComfortLevel,
      required this.houseNumber,
      required this.area,
      required this.locality,
      required this.landmark,
      required this.completeAddress,
      required this.latitude,
      required this.longitude,
      required this.sessions,
      this.action,
      this.services,
    });

    Map<String, dynamic> toJson() {
      final Map<String, dynamic> json = {
        
        'cart_item_id': cartItemId,
        'pet_id': petId,
        'contact_number': contactNumber,
        'people_comfort_level': peopleComfortLevel,
        'dogs_comfort_level': dogsComfortLevel,
        'house_number': houseNumber,
        'area': area,
        'locality': locality,
        'landmark': landmark,
        'complete_address': completeAddress,
        'latitude': latitude.toStringAsFixed(7),
        'longitude': longitude.toStringAsFixed(7),
      };

      if (action != null && services != null) {
        json['action'] = action;
        json['services'] = services;
      } else {
        json['sessions'] = sessions.map((session) => session.toJson()).toList();

        if (oneTimePackageId != null) {
          json['one_time_package_id'] = oneTimePackageId;
        } else {
          if (pricingPlanId != null) {
            json['pricing_plan_id'] = pricingPlanId;
          }
          if (sessionsPerMonth != null) {
            json['sessions_per_month'] = sessionsPerMonth;
          }
          if (numberOfMonths != null) {
            json['number_of_months'] = numberOfMonths;
          }
          if (mainCartId != null) {
            json['main_cart_id'] = mainCartId;
          }
        }
      }

      return json;
    }
}

class GroomingCartUpdateResponse {
  final bool status;
  final String message;
  final Map<String, dynamic>? data;

  GroomingCartUpdateResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory GroomingCartUpdateResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return GroomingCartUpdateResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map
          ? Map<String, dynamic>.from(json['data'])
          : null,
    );
  }
}
