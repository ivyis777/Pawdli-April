
class GroomingMainServiceModel {
  final int id;
  final String name;
  final String description;
  final String? image;
  final bool isActive;
  final String serviceType;

  const GroomingMainServiceModel({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    required this.isActive,
    required this.serviceType,
  });

  factory GroomingMainServiceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return GroomingMainServiceModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString(),
      isActive: json['is_active'] == true,
      serviceType: json['service_type']?.toString() ?? '',
    );
  }
}
