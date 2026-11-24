class GroomingServiceModel {
  final int id;
  final String name;
  final String description;
  final String? image;
  final String serviceType;
  final List<IncludedGroomingService> includedServices;
  final List<GroomingPricingPlan> pricingPlans;
  final List<OneTimeGroomingPackage> oneTimePackages;

  const GroomingServiceModel({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    required this.serviceType,
    required this.includedServices,
    required this.pricingPlans,
    required this.oneTimePackages,
  });

  factory GroomingServiceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return GroomingServiceModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: _nullableString(json['image']),
      serviceType: json['service_type']?.toString() ?? '',

      includedServices:
          (json['included_services'] as List? ?? [])
              .whereType<Map>()
              .map(
                (item) => IncludedGroomingService.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),

      pricingPlans:
          (json['pricing_plans'] as List? ?? [])
              .whereType<Map>()
              .map(
                (item) => GroomingPricingPlan.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .where((plan) => plan.id > 0)
              .toList(),

      oneTimePackages:
          (json['one_time_packages'] as List? ?? [])
              .whereType<Map>()
              .map(
                (item) => OneTimeGroomingPackage.fromJson(
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

  static String? _nullableString(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return null;
    }
    return value.toString();
  }
}


class IncludedGroomingService {
  final int id;
  final String name;
  final String description;
  final String? image;

  const IncludedGroomingService({
    required this.id,
    required this.name,
    required this.description,
    this.image,
  });

  factory IncludedGroomingService.fromJson(
    Map<String, dynamic> json,
  ) {
    return IncludedGroomingService(
      id: GroomingServiceModel._toInt(json['id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: GroomingServiceModel._nullableString(json['image']),
    );
  }
}

class GroomingPricingPlan {
  final int id;
  final int sessionsPerMonth;
  final int numberOfMonths;
  final int totalSessions;
  final String price;

  const GroomingPricingPlan({
    required this.id,
    required this.sessionsPerMonth,
    required this.numberOfMonths,
    required this.totalSessions,
    required this.price,
  });

  factory GroomingPricingPlan.fromJson(
    Map<String, dynamic> json,
  ) {
    return GroomingPricingPlan(
      id: GroomingServiceModel._toInt(json['id']),
      sessionsPerMonth:
          GroomingServiceModel._toInt(json['sessions_per_month']),
      numberOfMonths:
          GroomingServiceModel._toInt(json['number_of_months']),
      totalSessions:
          GroomingServiceModel._toInt(json['total_sessions']),
      price: json['price']?.toString() ?? '0.00',
    );
  }

  String get formattedPrice {
    final amount = double.tryParse(price) ?? 0;
    return '₹${amount.toStringAsFixed(0)}';
  }
}


class OneTimeGroomingPackage {
  final int id;
  final int mainService;
  final String name;
  final String description;
  final String? image;
  final String price;
  final int? petCategory;

  const OneTimeGroomingPackage({
    required this.id,
    required this.mainService,
    required this.name,
    required this.description,
    this.image,
    required this.price,
    this.petCategory,
  });

  factory OneTimeGroomingPackage.fromJson(
    Map<String, dynamic> json,
  ) {
    return OneTimeGroomingPackage(
      id: GroomingServiceModel._toInt(json['id']),
      mainService:
          GroomingServiceModel._toInt(json['main_service']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: GroomingServiceModel._nullableString(json['image']),
      price: json['price']?.toString() ?? '0.00',
      petCategory: json['pet_category'] == null
          ? null
          : GroomingServiceModel._toInt(json['pet_category']),
    );
  }

  String get formattedPrice {
    final amount = double.tryParse(price) ?? 0;
    return '₹${amount.toStringAsFixed(0)}';
  }
}



