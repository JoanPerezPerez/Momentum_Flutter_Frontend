class ILocation {
  late final String _id;
  late final String nombre;
  late final String address;
  late final String phone;
  late final double rating;
  late final GeoJSONPoint ubicacion;
  late final List<locationServiceType> serviceType;
  late final List<LocationSchedule> schedule;
  late final String business;
  late final List<String> workers;

  ILocation({
    required String id,
    required this.nombre,
    required this.address,
    required this.phone,
    required this.rating,
    required this.ubicacion,
    required this.serviceType,
    required this.schedule,
    required this.business,
    required this.workers,
  }) {
    _id = id;
  }

  String get id => _id;

  factory ILocation.fromJson(Map<String, dynamic> json) {
    final List<LocationSchedule> parsedSchedule = (json['schedule'] as List<dynamic>?)
            ?.map((e) => LocationSchedule.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return ILocation(
      id: json['_id'] ?? '',
      nombre: json['nombre'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      ubicacion: GeoJSONPoint.fromJson(json['ubicacion']),
      serviceType: (json['serviceType'] as List<dynamic>?)
              ?.map((e) {
                if (e == null) return null;
                String normalized = e.toString().trim().toLowerCase();
                return locationServiceType.values.firstWhere(
                  (type) => type.description.toLowerCase() == normalized,
                  orElse: () {
                    print("Unrecognized service type: $e");
                    throw Exception("Service type '$e' not recognized.");
                  },
                );
              })
              .whereType<locationServiceType>()
              .toList() ??
          [],
      schedule: parsedSchedule,
      business: parsedSchedule.isNotEmpty
          ? (json['schedule'][0]['_id'] ?? '')
          : '',
      workers: (json['workers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': _id,
      'nombre': nombre,
      'address': address,
      'phone': phone,
      'rating': rating,
      'ubicacion': ubicacion.toJson(),
      'serviceType': serviceType.map((e) => e.description).toList(),
      'schedule': schedule.map((e) => e.toJson()).toList(),
      'business': business,
      'workers': workers,
    };
  }
}

class LocationSchedule {
  final String day;
  final String openingTime;
  final String closingTime;
  final String? business; // Nuevo campo para recoger business opcional

  LocationSchedule({
    required this.day,
    required this.openingTime,
    required this.closingTime,
    this.business,
  });

  factory LocationSchedule.fromJson(Map<String, dynamic> json) {
    return LocationSchedule(
      day: json['day'] ?? '',
      openingTime: json['open'] ?? '',
      closingTime: json['close'] ?? '',
      business: json['business'], // Nuevo campo opcional
    );
  }

  Map<String, dynamic> toJson() {
    return {'day': day, 'open': openingTime, 'close': closingTime};
  }
}

class GeoJSONPoint {
  final String type;
  final List<double> coordinates;

  GeoJSONPoint({required this.type, required this.coordinates});

  factory GeoJSONPoint.fromJson(Map<String, dynamic> json) {
    return GeoJSONPoint(
      type: json['type'],
      coordinates: List<double>.from(json['coordinates']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'coordinates': coordinates};
  }
}

enum locationServiceType {
  HAIRCUT,
  HAIR_COLOR,
  HAIR_TREATMENT,
  BEARD_TRIM,
  FACIAL,
  MAKEUP,
  MANICURE,
  PEDICURE,
  EYEBROWS,
  WAXING,
  MASSAGE,
  MEDICAL_APPOINTMENT,
  PHYSIOTHERAPY,
  THERAPY_SESSION,
  DENTAL_APPOINTMENT,
  NUTRITIONIST,
  GYM_SESSION,
  YOGA_CLASS,
  PILATES_CLASS,
  BOXING_CLASS,
  SWIMMING,
  PERSONAL_TRAINING,
  RESTAURANT_BOOKING,
  TAKEAWAY,
  CATERING,
  PRIVATE_DINNER,
  WINE_TASTING,
  TATTOO,
  PIERCING,
  LANGUAGE_CLASS,
  MUSIC_LESSON,
  DANCE_CLASS,
  COACHING,
}

extension LocationServiceTypeExtension on locationServiceType {
  String get description {
    switch (this) {
      case locationServiceType.HAIRCUT:
        return 'haircut';
      case locationServiceType.HAIR_COLOR:
        return 'hair coloring';
      case locationServiceType.HAIR_TREATMENT:
        return 'hair treatment';
      case locationServiceType.BEARD_TRIM:
        return 'beard trim';
      case locationServiceType.FACIAL:
        return 'facial cleansing';
      case locationServiceType.MAKEUP:
        return 'makeup';
      case locationServiceType.MANICURE:
        return 'manicure';
      case locationServiceType.PEDICURE:
        return 'pedicure';
      case locationServiceType.EYEBROWS:
        return 'eyebrows and lashes';
      case locationServiceType.WAXING:
        return 'waxing';
      case locationServiceType.MASSAGE:
        return 'relaxing massage';
      case locationServiceType.MEDICAL_APPOINTMENT:
        return 'medical appointment';
      case locationServiceType.PHYSIOTHERAPY:
        return 'physiotherapy';
      case locationServiceType.THERAPY_SESSION:
        return 'therapy session';
      case locationServiceType.DENTAL_APPOINTMENT:
        return 'dentist appointment';
      case locationServiceType.NUTRITIONIST:
        return 'nutritionist';
      case locationServiceType.GYM_SESSION:
        return 'gym workout';
      case locationServiceType.YOGA_CLASS:
        return 'yoga class';
      case locationServiceType.PILATES_CLASS:
        return 'pilates class';
      case locationServiceType.BOXING_CLASS:
        return 'boxing class';
      case locationServiceType.SWIMMING:
        return 'swimming session';
      case locationServiceType.PERSONAL_TRAINING:
        return 'personal training';
      case locationServiceType.RESTAURANT_BOOKING:
        return 'restaurant reservation';
      case locationServiceType.TAKEAWAY:
        return 'takeaway order';
      case locationServiceType.CATERING:
        return 'catering service';
      case locationServiceType.PRIVATE_DINNER:
        return 'private dinner';
      case locationServiceType.WINE_TASTING:
        return 'wine tasting';
      case locationServiceType.TATTOO:
        return 'tattoo';
      case locationServiceType.PIERCING:
        return 'piercing';
      case locationServiceType.LANGUAGE_CLASS:
        return 'language class';
      case locationServiceType.MUSIC_LESSON:
        return 'music lesson';
      case locationServiceType.DANCE_CLASS:
        return 'dance class';
      case locationServiceType.COACHING:
        return 'coaching session';
    }
  }
}
