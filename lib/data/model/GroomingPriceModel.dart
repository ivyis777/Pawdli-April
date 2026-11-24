
class GroomingPlanPriceModel {
  final int pricingPlanId;
  final int serviceId;
  final String serviceName;
  final String serviceType;
  final int petId;
  final String petName;
  final int petCategoryId;
  final String petCategoryName;
  final int sessionsPerMonth;
  final int numberOfMonths;
  final int totalSessions;
  final String price;

  const GroomingPlanPriceModel({
    required this.pricingPlanId,
    required this.serviceId,
    required this.serviceName,
    required this.serviceType,
    required this.petId,
    required this.petName,
    required this.petCategoryId,
    required this.petCategoryName,
    required this.sessionsPerMonth,
    required this.numberOfMonths,
    required this.totalSessions,
    required this.price,
  });

  factory GroomingPlanPriceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    int toInt(dynamic value) =>
        int.tryParse(value?.toString() ?? '') ?? 0;

    return GroomingPlanPriceModel(
      pricingPlanId: toInt(json['pricing_plan_id']),
      serviceId: toInt(json['service_id']),
      serviceName: json['service_name']?.toString() ?? '',
      serviceType: json['service_type']?.toString() ?? '',
      petId: toInt(json['pet_id']),
      petName: json['pet_name']?.toString() ?? '',
      petCategoryId: toInt(json['pet_category_id']),
      petCategoryName:
          json['pet_category_name']?.toString() ?? '',
      sessionsPerMonth: toInt(json['sessions_per_month']),
      numberOfMonths: toInt(json['number_of_months']),
      totalSessions: toInt(json['total_sessions']),
      price: json['price']?.toString() ?? '0.00',
    );
  }

  double get priceAmount =>
      double.tryParse(price) ?? 0;

  int get roundedPrice => priceAmount.round();

  String get formattedPrice =>
      '₹${priceAmount.toStringAsFixed(0)}';
}
