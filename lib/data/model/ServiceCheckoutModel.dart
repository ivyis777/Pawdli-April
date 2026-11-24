
class GroomingCheckoutResponse {
  final bool status;
  final String message;
  final int totalItems;
  final double totalAmount;
  final List<GroomingCheckoutItem> items;

  GroomingCheckoutResponse({
    required this.status,
    required this.message,
    required this.totalItems,
    required this.totalAmount,
    required this.items,
  });

  factory GroomingCheckoutResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return GroomingCheckoutResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      totalItems: (json['total_items'] as num?)?.toInt() ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      items: (json['data'] as List? ?? [])
          .map((e) => GroomingCheckoutItem.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .toList(),
    );
  }
}

class GroomingCheckoutItem {
  final int cartItemId;
  final int petId;
  final String petName;
  final String serviceName;
  final String serviceType;
  final double price;

  GroomingCheckoutItem({
    required this.cartItemId,
    required this.petId,
    required this.petName,
    required this.serviceName,
    required this.serviceType,
    required this.price,
  });

  factory GroomingCheckoutItem.fromJson(
    Map<String, dynamic> json,
  ) {
    final pet = json['pet'] ?? {};
    final service = json['service'] ?? {};
    final pricing = json['pricing'] ?? {};

    return GroomingCheckoutItem(
      cartItemId: (json['cart_item_id'] as num?)?.toInt() ?? 0,
      petId: (pet['pet_id'] as num?)?.toInt() ?? 0,

      // The checkout API currently doesn't return pet_name.
      petName: pet['pet_name']?.toString() ?? '',

      serviceName: service['service_name']?.toString() ?? '',
      serviceType: service['service_type']?.toString() ?? '',
      price: (pricing['price'] as num?)?.toDouble() ?? 0,
    );
  }
}
