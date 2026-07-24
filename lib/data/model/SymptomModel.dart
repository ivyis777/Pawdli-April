class SymptomModel {
  bool? status;
  String? message;
  int? totalCount;
  List<SymptomData>? data;

  SymptomModel({
    this.status,
    this.message,
    this.totalCount,
    this.data,
  });

  SymptomModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    totalCount = json['total_count'];

    if (json['data'] != null) {
      data = <SymptomData>[];

      json['data'].forEach((v) {
        data!.add(SymptomData.fromJson(v));
      });
    }
  }
}

class SymptomData {
  int? id;
  String? name;
  bool? isActive;
  String? createdAt;
  String? updatedAt;

  SymptomData({
    this.id,
    this.name,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  SymptomData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}