
class GroomingSessionRequest {
  final String date;     
  final String startTime; 

  const GroomingSessionRequest({
    required this.date,
    required this.startTime,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'start_time': startTime,
      };
}

class GroomingPlanServiceRequest {
  final int serviceId;
  final int pricingPlanId;
  final int sessionsPerMonth;
  final int numberOfMonths;
  final List<GroomingSessionRequest> sessions;

  const GroomingPlanServiceRequest({
    required this.serviceId,
    required this.pricingPlanId,
    required this.sessionsPerMonth,
    required this.numberOfMonths,
    required this.sessions,
  });

  Map<String, dynamic> toJson() => {
        'service_id': serviceId,
        'pricing_plan_id': pricingPlanId,
        'sessions_per_month': sessionsPerMonth,
        'number_of_months': numberOfMonths,
        'sessions': sessions.map((e) => e.toJson()).toList(),
      };
}

class GroomingAddToCartRequest {
  final int petId;
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
  final List<GroomingPlanServiceRequest> services;

  const GroomingAddToCartRequest({
    required this.petId,
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
    required this.services,
  });

  Map<String, dynamic> toJson() => {
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
        'services': services.map((e) => e.toJson()).toList(),
      };
}

class OneTimeServiceCartRequest {
  final int serviceId;
  final int oneTimePackageId;
  final List<GroomingSessionRequest> sessions;

  const OneTimeServiceCartRequest({
    required this.serviceId,
    required this.oneTimePackageId,
    required this.sessions,
  });

  Map<String, dynamic> toJson() => {
        'service_id': serviceId,
        'one_time_package_id': oneTimePackageId,
        'sessions': sessions.map((e) => e.toJson()).toList(),
      };
}

class OneTimeGroomingAddToCartRequest {
  final int petId;
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
  final List<OneTimeServiceCartRequest> services;

  const OneTimeGroomingAddToCartRequest({
    required this.petId,
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
    required this.services,
  });

  Map<String, dynamic> toJson() => {
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
        'services': services.map((e) => e.toJson()).toList(),
      };
}



class GroomingAddToCartResponse {
  final bool status;
  final String message;

  // POST response fields
  final int? bookingId;
  final int? cartItemId;
  final String? bookingStatus;
  final String? paymentStatus;
  final String? serviceName;
  final double? price;

  // GET response fields
  final int totalCarts;
  final int totalItems;
  final List<GroomingMainCartModel> carts;

  const GroomingAddToCartResponse({
    required this.status,
    required this.message,
    this.bookingId,
    this.cartItemId,
    this.bookingStatus,
    this.paymentStatus,
    this.serviceName,
    this.price,
    this.totalCarts = 0,
    this.totalItems = 0,
    this.carts = const [],
  });

  /// Flat list for existing cart UI.
  /// The API's grouped cart structure is preserved in [carts].
  List<GroomingCartItemModel> get items =>
      carts.expand((cart) => cart.items).toList();

  factory GroomingAddToCartResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawData = json['data'];

    // New GET API:
    // data -> List<main cart> -> items -> cart items
    if (rawData is List) {
      if (rawData.isNotEmpty) {
        final first = _asMap(rawData.first);

        // New grouped GET response
        if (first.containsKey('main_cart_id')) {
          final carts = rawData
              .whereType<Map>()
              .map(
                (cart) => GroomingMainCartModel.fromJson(
                  Map<String, dynamic>.from(cart),
                ),
              )
              .toList();

          return GroomingAddToCartResponse(
            status: json['status'] == true,
            message: _asString(json['message']),
            totalCarts: _asInt(json['total_carts'] ?? carts.length),
            totalItems: _asInt(
              json['total_items'] ??
                  carts.fold<int>(
                    0,
                    (sum, cart) => sum + cart.items.length,
                  ),
            ),
            carts: carts,
          );
        }

        // Backward compatibility for an older flat GET response
        final oldItems = rawData
            .whereType<Map>()
            .map(
              (item) => GroomingCartItemModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();

        if (oldItems.isNotEmpty) {
          return GroomingAddToCartResponse(
            status: json['status'] == true,
            message: _asString(json['message']),
            totalItems: _asInt(
              json['total_items'] ?? oldItems.length,
            ),
            carts: [
              GroomingMainCartModel(
                mainCartId: 0,
                createdAt: '',
                updatedAt: '',
                totalItems: oldItems.length,
                items: oldItems,
              ),
            ],
          );
        }
      }

      return GroomingAddToCartResponse(
        status: json['status'] == true,
        message: _asString(json['message']),
        totalCarts: _asInt(json['total_carts']),
        totalItems: _asInt(json['total_items']),
      );
    }

    // POST response: data contains bookings.
    final data = _asMap(rawData);
    final rawBookings = data['bookings'];

    final firstEntry =
        rawBookings is List && rawBookings.isNotEmpty
            ? _asMap(rawBookings.first)
            : <String, dynamic>{};

    final booking = _asMap(firstEntry['booking']);
    final cart = _asMap(firstEntry['cart']);
    final service = _asMap(firstEntry['service']);
    final pricing = _asMap(firstEntry['pricing']);

    return GroomingAddToCartResponse(
      status: json['status'] == true,
      message: _asString(json['message']),
      bookingId: _asInt(booking['id']),
      cartItemId: _asInt(cart['cart_item_id']),
      bookingStatus: _asString(booking['status']),
      paymentStatus: _asString(booking['payment_status']),
      serviceName: _asString(
        service['name'] ?? service['service_name'],
      ),
      price: _asDouble(pricing['price']),
      totalItems: _asInt(data['total_bookings']),
    );
  }
}

/// One top-level cart from data[] in the new GET API.
class GroomingMainCartModel {
  final int mainCartId;
  final String createdAt;
  final String updatedAt;
  final int totalItems;
  final List<GroomingCartItemModel> items;

  const GroomingMainCartModel({
    required this.mainCartId,
    required this.createdAt,
    required this.updatedAt,
    required this.totalItems,
    required this.items,
  });

  factory GroomingMainCartModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawItems = json['items'];

    return GroomingMainCartModel(
      mainCartId: _asInt(json['main_cart_id']),
      createdAt: _asString(json['created_at']),
      updatedAt: _asString(json['updated_at']),
      totalItems: _asInt(
        json['total_items'] ??
            (rawItems is List ? rawItems.length : 0),
      ),
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map(
                (item) => GroomingCartItemModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
    );
  }
}

class GroomingCartItemModel {
  final int cartItemId;
  final String cartStatus;
  final String cartCreatedAt;

  final int bookingId;
  final String bookingStatus;
  final String paymentStatus;
  final String bookingCreatedAt;
  final String bookingUpdatedAt;

  final int petId;
  final String petName;
  final int petCategoryId;
  final String petCategoryName;
  final int subcategoryId;
  final String breedName;
  final String gender;
  final double weight;
  final double height;
  final String petProfileImage;

  final int serviceId;
  final String serviceName;
  final String serviceType;
  final int serviceCategoryId;
  final List<String> includedServices;

  final String packageName;
  final int? pricingPlanId;
  final int? oneTimePackageId;
  final int? sessionsPerMonth;
  final int? numberOfMonths;
  final int totalSessions;
  final double price;

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

  final List<GroomingCartSessionModel> sessions;

  const GroomingCartItemModel({
    required this.cartItemId,
    required this.cartStatus,
    required this.cartCreatedAt,
    required this.bookingId,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.bookingCreatedAt,
    required this.bookingUpdatedAt,
    required this.petId,
    required this.petName,
    required this.petCategoryId,
    required this.petCategoryName,
    required this.subcategoryId,
    required this.breedName,
    required this.gender,
    required this.weight,
    required this.height,
    required this.petProfileImage,
    required this.serviceId,
    required this.serviceName,
    required this.serviceType,
    required this.serviceCategoryId,
    required this.includedServices,
    required this.packageName,
    required this.pricingPlanId,
    required this.oneTimePackageId,
    required this.sessionsPerMonth,
    required this.numberOfMonths,
    required this.totalSessions,
    required this.price,
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
  });

  factory GroomingCartItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final booking = _asMap(json['booking']);
    final pet = _asMap(json['pet']);
    final service = _asMap(json['service']);
    final pricing = _asMap(json['pricing']);
    final comfort = _asMap(json['comfort_details']);
    final address = _asMap(json['address']);

    final rawSessions = json['sessions'];
    final rawIncluded = service['included_services'];

    return GroomingCartItemModel(
      cartItemId: _asInt(json['cart_item_id']),
      cartStatus: _asString(json['cart_status']),
      cartCreatedAt: _asString(json['cart_created_at']),

      bookingId: _asInt(booking['booking_id']),
      bookingStatus: _asString(booking['status']),
      paymentStatus: _asString(booking['payment_status']),
      bookingCreatedAt: _asString(booking['created_at']),
      bookingUpdatedAt: _asString(booking['updated_at']),

      petId: _asInt(pet['pet_id']),
      petName: _asString(pet['pet_name']),
      petCategoryId: _asInt(pet['pet_category_id']),
      petCategoryName: _asString(pet['pet_category_name']),
      subcategoryId: _asInt(pet['subcategory_id']),
      breedName: _asString(pet['breed_name']),
      gender: _asString(pet['gender']),
      weight: _asDouble(pet['weight']),
      height: _asDouble(pet['height']),
      petProfileImage: _asString(pet['pet_profile_image']),

      serviceId: _asInt(service['service_id']),
      serviceName: _asString(service['service_name']),
      serviceType: _asString(service['service_type']),
      serviceCategoryId: _asInt(service['service_category_id']),
      includedServices: rawIncluded is List
          ? rawIncluded.map((e) => e.toString()).toList()
          : const [],

      packageName: _asString(pricing['package_name']),
      pricingPlanId: _nullableInt(pricing['pricing_plan_id']),
      oneTimePackageId: _nullableInt(
        pricing['one_time_package_id'],
      ),
      sessionsPerMonth: _nullableInt(
        pricing['sessions_per_month'],
      ),
      numberOfMonths: _nullableInt(
        pricing['number_of_months'],
      ),
      totalSessions: _asInt(pricing['total_sessions']),
      price: _asDouble(pricing['price']),

      contactNumber: _asString(json['contact_number']),
      peopleComfortLevel: _asString(
        comfort['people_comfort_level'],
      ),
      dogsComfortLevel: _asString(
        comfort['dogs_comfort_level'],
      ),

      houseNumber: _asString(address['house_number']),
      area: _asString(address['area']),
      locality: _asString(address['locality']),
      landmark: _asString(address['landmark']),
      completeAddress: _asString(address['complete_address']),
      latitude: _asDouble(address['latitude']),
      longitude: _asDouble(address['longitude']),

      sessions: rawSessions is List
          ? rawSessions
              .whereType<Map>()
              .map(
                (session) => GroomingCartSessionModel.fromJson(
                  Map<String, dynamic>.from(session),
                ),
              )
              .toList()
          : const [],
    );
  }
}

class GroomingCartSessionModel {
  final int sessionId;
  final int sessionNumber;
  final int serviceSlotId;
  final String scheduledDate;
  final String startTime;
  final String sessionStatus;
  final bool slotIsActive;
  final int slotCapacity;

  const GroomingCartSessionModel({
    required this.sessionId,
    required this.sessionNumber,
    required this.serviceSlotId,
    required this.scheduledDate,
    required this.startTime,
    required this.sessionStatus,
    required this.slotIsActive,
    required this.slotCapacity,
  });

  factory GroomingCartSessionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return GroomingCartSessionModel(
      sessionId: _asInt(json['session_id']),
      sessionNumber: _asInt(json['session_number']),
      serviceSlotId: _asInt(json['service_slot_id']),
      scheduledDate: _asString(json['scheduled_date']),
      startTime: _asString(json['start_time']),
      sessionStatus: _asString(json['session_status']),
      slotIsActive: json['slot_is_active'] == true,
      slotCapacity: _asInt(json['slot_capacity']),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

int _asInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _nullableInt(dynamic value) {
  if (value == null) return null;
  if (value is String && value.isEmpty) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}

String _asString(dynamic value) {
  return value?.toString() ?? '';
}
