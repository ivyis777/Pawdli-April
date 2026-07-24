class RatingReviewModel {
  final int productId;
  final int orderId;
  final int rating;
  final String comment;

  RatingReviewModel({
    required this.productId,
    required this.orderId,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      "product_id": productId,
      "order_id": orderId,
      "rating": rating,
      "comment": comment,
    };
  }
}