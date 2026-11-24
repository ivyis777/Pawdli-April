
class OneTimeGroomingServiceModel {
  final int id;
  final String name;
  final String description;
  final String? image;
  final bool isActive;
  final String serviceType;

  const OneTimeGroomingServiceModel({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    required this.isActive,
    required this.serviceType,
  });

  factory OneTimeGroomingServiceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return OneTimeGroomingServiceModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString(),
      isActive: json['is_active'] == true,
      serviceType: json['service_type']?.toString() ?? '',
    );
  }
}
