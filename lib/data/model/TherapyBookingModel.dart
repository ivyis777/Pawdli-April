class TherapyBookingModel {

  final bool? status;

  final List<TherapyBookingData>? data;

  TherapyBookingModel({
    this.status,
    this.data,
  });

  factory TherapyBookingModel.fromJson(
      Map<String, dynamic> json) {

    return TherapyBookingModel(

      status: json['status'],

      data: json['data'] != null
          ? (json['data'] as List)
              .map(
                (e) =>
                    TherapyBookingData.fromJson(e),
              )
              .toList()
          : [],
    );
  }
}

class TherapyBookingData {

  final int? bookingId;

  final int? userId;

  final String? userName;

  final int? pettherapyId;

  final String? therapyName;

  final String? therapyImage;

  final String? bookingDate;

  final String? bookingStatus;

  final BookingSlot? slot;

  final String? location;
  final String? googleMapLink;
  final double? latitude;
  final double? longitude;
  final String? landmark;
  final String? amount;
  final bool? isPaid;
  final String? paymentId;
  final String? razorpayOrderId;
  final String? mode;
  final String? therapyType;
  final String? createdAt;
  final String? description;
    final String? petAge;
    final String? petGender;
    final String? vaccinationStatus;
    final String? petSpecialization;
    final bool? isFree;

  TherapyBookingData({
    this.bookingId,
    this.userId,
    this.userName,
    this.pettherapyId,
    this.therapyName,
    this.therapyImage,
    this.bookingDate,
    this.bookingStatus,
    this.location,
    this.googleMapLink,
    this.latitude,
    this.longitude,
    this.landmark,
    this.amount,
    this.isPaid,
    this.paymentId,
    this.razorpayOrderId,
    this.mode,
    this.therapyType,
    this.createdAt,
    this.slot,
    this.description,
    this.petAge,
    this.petGender,
    this.vaccinationStatus,
    this.petSpecialization,
    this.isFree,
  });

  factory TherapyBookingData.fromJson(
      Map<String, dynamic> json) {

    return TherapyBookingData(
      bookingId: json["booking_id"],

      bookingStatus: json["booking_status"],

      userId: json["user"]?["user_id"],

      userName: json["user"]?["name"],

      pettherapyId: json["pettherapy"]?["pettherapy_id"],

      therapyName: json["pettherapy"]?["name"],

      therapyImage: json["pettherapy"]?["cover_image"],

      bookingDate: json["slot"]?["date"],

      location: json["pettherapy"]?["location"],

      googleMapLink: json["pettherapy"]?["google_map_link"],

      latitude: (json["pettherapy"]?["latitude"] as num?)?.toDouble(),
      
      longitude: (json["pettherapy"]?["longitude"] as num?)?.toDouble(),

      landmark: json["pettherapy"]?["landmark"],

      amount: json["payment"]?["amount"],

      isPaid: json["payment"]?["is_paid"],

      paymentId: json["payment"]?["payment_id"],

      razorpayOrderId:
          json["payment"]?["razorpay_order_id"],

      mode: json["therapy"]?["mode"],

      therapyType:
          json["therapy"]?["therapy_type"],

      createdAt: json["created_at"],

      slot: json["slot"] != null
          ? BookingSlot.fromJson(json["slot"])
          : null,

      description: json["pettherapy"]?["description"],
      petAge: json["pettherapy"]?["age"],
      petGender: json["pettherapy"]?["gender"],
      vaccinationStatus: json["pettherapy"]?["vaccination_status"],
      petSpecialization: json["pettherapy"]?["pet_specialization"],
      isFree: json["payment"]?["is_free"],
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

    factory BookingSlot.fromJson(
        Map<String, dynamic> json) {

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