class GroomingBookingResponse {
  final bool status;
  final String message;
  final String bookingFilter;
  final int totalBookings;
  final List<GroomingBooking> data;

  GroomingBookingResponse({
    required this.status,
    required this.message,
    required this.bookingFilter,
    required this.totalBookings,
    required this.data,
  });

  factory GroomingBookingResponse.fromJson(Map<String, dynamic> json) {
    return GroomingBookingResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      bookingFilter: json['booking_filter'] ?? '',
      totalBookings: json['total_bookings'] ?? 0,
      data: (json['data'] as List? ?? [])
          .map((e) => GroomingBooking.fromJson(e))
          .toList(),
    );
  }
}

class GroomingBooking {
  final int id;
  final int user;
  final String customerName;
  final String contactNumber;
  final int pet;
  final String petName;
  final int mainService;
  final String serviceName;
  final int? pricingPlan;
  final int? oneTimePackage;
  final String? packageName;
  final int petCategory;
  final String price;
  final String houseNumber;
  final String area;
  final String locality;
  final String landmark;
  final String completeAddress;
  final String latitude;
  final String longitude;
  final String status;
  final String paymentStatus;
  final String createdAt;
  final List<dynamic> sessions;
  final String petType;
  final String petBreed;
  final String petAge;
  final String petImage;

  // Service
  final String serviceType;
  final int serviceCategoryId;
  final List<dynamic> includedServices;

  // Plan
  final int sessionsPerMonth;
  final int numberOfMonths;
  final int totalSessions;
  final String planPrice;

  GroomingBooking({
    required this.id,
    required this.user,
    required this.customerName,
    required this.contactNumber,
    required this.pet,
    required this.petName,
    required this.mainService,
    required this.serviceName,
    this.pricingPlan,
    this.oneTimePackage,
    this.packageName,
    required this.petCategory,
    required this.price,
    required this.houseNumber,
    required this.area,
    required this.locality,
    required this.landmark,
    required this.completeAddress,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
    required this.sessions,
    required this.petType,
    required this.petBreed,
    required this.petAge,
    required this.petImage,
    required this.serviceType,
    required this.serviceCategoryId,
    required this.includedServices,
    required this.sessionsPerMonth,
    required this.numberOfMonths,
    required this.totalSessions,
    required this.planPrice,
  });

  factory GroomingBooking.fromJson(Map<String, dynamic> json) {
    return GroomingBooking(
      id: json['id'] ?? 0,
      user: json['user'] ?? 0,
      customerName: json['customer_name'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      pet: json['pet'] ?? 0,
      petName: json['pet_name'] ?? '',
      mainService: json['main_service'] ?? 0,
      serviceName: json['service_name'] ?? '',
      pricingPlan: json['pricing_plan'],
      oneTimePackage: json['one_time_package'],
      packageName: json['package_name'],
      petCategory: json['pet_category'] ?? 0,
      price: json['price']?.toString() ?? '0.00',
      houseNumber: json['house_number'] ?? '',
      area: json['area'] ?? '',
      locality: json['locality'] ?? '',
      landmark: json['landmark'] ?? '',
      completeAddress: json['complete_address'] ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      status: json['status'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      createdAt: json['created_at'] ?? '',
      sessions: json['sessions'] as List? ?? [],
      petType: json['pet_type'] ?? '',
      petBreed: json['pet_breed'] ?? '',
      petAge: json['pet_age'] ?? '',
      petImage: json['pet_image'] ?? '',

      serviceType: json['service']?['service_type'] ?? '',
      serviceCategoryId:
          json['service']?['service_category_id'] ?? 0,

      includedServices:
          json['service']?['included_services'] ?? [],

      sessionsPerMonth:
          json['plan_details']?['sessions_per_month'] ?? 0,

      numberOfMonths:
          json['plan_details']?['number_of_months'] ?? 0,

      totalSessions:
          json['plan_details']?['total_sessions'] ?? 0,

      planPrice:
          json['plan_details']?['price']?.toString() ?? '0',
    );
  }
}