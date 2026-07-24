class SuperTherapyBookingModel {
  final bool? status;
  final int? count;
  final List<SuperTherapyBookingData>? data;

  SuperTherapyBookingModel({
    this.status,
    this.count,
    this.data,
  });

  factory SuperTherapyBookingModel.fromJson(Map<String, dynamic> json) {
    return SuperTherapyBookingModel(
      status: json["status"],
      count: json["count"],
      data: json["data"] == null
          ? []
          : (json["data"] as List)
              .map((e) => SuperTherapyBookingData.fromJson(e))
              .toList(),
    );
  }
}

class SuperTherapyBookingData {
  final int? bookingId;
  final String? bookingStatus;

  /// USER
  final int? userId;
  final String? username;
  final String? userName;
  final String? email;
  final String? mobile;
  final String? gender;
  final int? age;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final int? pincode;

  final String? bookingFirstName;
  final String? bookingLastName;
  final String? bookingPhoneNumber;
  final String? bookingAddress;
  final int? bookingPincode;

  /// PET
  final int? pettherapyId;
  final String? therapyName;
  final String? therapyImage;
  final String? description;
  final String? location;
  final String? landmark;
  final String? petAge;
  final String? petGender;
  final String? vaccinationStatus;
  final String? petSpecialization;

  /// SLOT
  final BookingSlot? slot;

  /// PAYMENT
  final String? paymentAmount;
  final bool? isPaid;
  final bool? isFree;
  final String? paymentId;
  final String? razorpayOrderId;

  final String? therapyMode;
  final String? therapyType;
  final String? previousPetTherapy;
  final String? previousPetTherapyDetails;
  final String? therapyDescription;
  final String? breedOrPetType;
  /// ORGANIZATION
    final int? groupCount;
    final int? studentCount;
    final int? employeeCount;
    final String? organizationName;

    /// LANGUAGE
    final List<String>? languages;

    /// CREATED DATE
    final String? createdAt;

  SuperTherapyBookingData({
    this.bookingId,
    this.bookingStatus,
    this.userId,
    this.username,
    this.userName,
    this.email,
    this.mobile,
    this.gender,
    this.age,
    this.address,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.bookingFirstName,
    this.bookingLastName,
    this.bookingPhoneNumber,
    this.bookingAddress,
    this.bookingPincode,
    this.pettherapyId,
    this.therapyName,
    this.therapyImage,
    this.description,
    this.location,
    this.landmark,
    this.petAge,
    this.petGender,
    this.vaccinationStatus,
    this.petSpecialization,
    this.slot,
    this.paymentAmount,
    this.isPaid,
    this.isFree,
    this.paymentId,
    this.razorpayOrderId,
    this.therapyMode,
    this.therapyType,
    this.previousPetTherapy,
    this.previousPetTherapyDetails,
    this.therapyDescription,
    this.breedOrPetType,
    this.groupCount,
    this.studentCount,
    this.employeeCount,
    this.organizationName,
    this.languages,
    this.createdAt,
  });

  factory SuperTherapyBookingData.fromJson(Map<String, dynamic> json) {
    return SuperTherapyBookingData(
      bookingId: json["booking_id"],
      bookingStatus: json["booking_status"],

      userId: json["user"]?["user_id"],
      username: json["user"]?["username"],
      userName: json["user"]?["name"],
      email: json["user"]?["email"],
      mobile: json["user"]?["mobile"],
      gender: json["user"]?["gender"],
      age: json["user"]?["age"],
      address: json["user"]?["address"],
      city: json["user"]?["city"],
      state: json["user"]?["state"],
      country: json["user"]?["country"],
      pincode: json["user"]?["pincode"],

      bookingFirstName: json["user"]?["booking_first_name"],
      bookingLastName: json["user"]?["booking_last_name"],
      bookingPhoneNumber: json["user"]?["booking_phone_number"],
      bookingAddress: json["user"]?["booking_address"],
      bookingPincode: json["user"]?["booking_pincode"],

      pettherapyId: json["pettherapy"]?["pettherapy_id"],
      therapyName: json["pettherapy"]?["name"],
      therapyImage: json["pettherapy"]?["cover_image"],
      description: json["pettherapy"]?["description"],
      location: json["pettherapy"]?["location"],
      landmark: json["pettherapy"]?["landmark"],
      petAge: json["pettherapy"]?["age"],
      petGender: json["pettherapy"]?["gender"],
      vaccinationStatus: json["pettherapy"]?["vaccination_status"],
      petSpecialization: json["pettherapy"]?["pet_specialization"],

      slot: json["slot"] != null
          ? BookingSlot.fromJson(json["slot"])
          : null,

      paymentAmount: json["payment"]?["amount"],
      isPaid: json["payment"]?["is_paid"],
      isFree: json["payment"]?["is_free"],
      paymentId: json["payment"]?["payment_id"],
      razorpayOrderId: json["payment"]?["razorpay_order_id"],
      therapyMode: json["therapy"]?["mode"],
      therapyType: json["therapy"]?["therapy_type"],
      previousPetTherapy:
          json["therapy"]?["previous_pet_therapy"],
      previousPetTherapyDetails:
          json["therapy"]?["previous_pet_therapy_details"],
      therapyDescription:
          json["therapy"]?["description"],
      breedOrPetType:
          json["therapy"]?["breed_or_pet_type"],
      groupCount:
          json["organization"]?["group_count"],

      studentCount:
          json["organization"]?["student_count"],

      employeeCount:
          json["organization"]?["employee_count"],

      organizationName:
          json["organization"]?["organization_name"],

      languages: json["language"] == null
          ? []
          : List<String>.from(json["language"]),

      createdAt: json["created_at"],
    );
  }
}

class BookingSlot {
  final int? slotId;
  final String? date;
  final String? startTime;
  final String? endTime;
  final String? amount;
  final bool? isBooked;

  BookingSlot({
    this.slotId,
    this.date,
    this.startTime,
    this.endTime,
    this.amount,
    this.isBooked,
  });

  factory BookingSlot.fromJson(Map<String, dynamic> json) {
    return BookingSlot(
      slotId: json["slot_id"],
      date: json["date"],
      startTime: json["start_time"],
      endTime: json["end_time"],
      amount: json["amount"],
      isBooked: json["is_booked"],
    );
  }
}