class OrderItemModel {
  final int orderItemId;
  final String productName;
  final String productImage;
  final List<String> productImages;
  final String variantName;
  final int quantity;
  final String price;
  final String totalPrice;

  OrderItemModel({
    required this.orderItemId,
    required this.productName,
    required this.productImage,
    required this.productImages,
    required this.variantName,
    required this.quantity,
    required this.price,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      orderItemId: json['order_item_id'],
      productName: json['product_name'] ?? '',
      productImage: json['product_image'] ?? '',
      productImages: List<String>.from(json['product_images'] ?? []),
      variantName: json['variant_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: json['price'] ?? '',
      totalPrice: json['total_price'] ?? '',
    );
  }
}