class AddressModel {
  String houseNo;
  String flatFloor;
  String area;
  String locality;
  String landmark;
  String city;
  String state;
  String pincode;

  AddressModel({
    required this.houseNo,
    required this.flatFloor,
    required this.area,
    required this.locality,
    required this.landmark,
    required this.city,
    required this.state,
    required this.pincode,
  });

  Map<String, dynamic> toJson() => {
        "houseNo": houseNo,
        "flatFloor": flatFloor,
        "area": area,
        "locality": locality,
        "landmark": landmark,
        "city": city,
        "state": state,
        "pincode": pincode,
      };

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      houseNo: json["houseNo"],
      flatFloor: json["flatFloor"],
      area: json["area"],
      locality: json["locality"],
      landmark: json["landmark"],
      city: json["city"],
      state: json["state"],
      pincode: json["pincode"],
    );
  }
}