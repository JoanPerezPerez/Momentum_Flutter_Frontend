enum AppointmentServiceType { personal, professional, medical }

enum AppointmentState { requested, accepted, rejected, standby }

class AppointmentModel {
  final String? id;
  final DateTime inTime;
  final DateTime outTime;
  final String title;
  final String? colour;
  final String? description;
  final String? locationId;
  final AppointmentServiceType serviceType;
  final AppointmentState appointmentState;
  final bool isDeleted;

  AppointmentModel({
    this.id,
    required this.inTime,
    required this.outTime,
    required this.title,
    this.colour,
    this.description,
    this.locationId,
    this.serviceType = AppointmentServiceType.personal,
    this.appointmentState = AppointmentState.requested,
    this.isDeleted = false,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['_id']?.toString(),
      inTime:
          json['inTime'] is DateTime
              ? json['inTime']
              : DateTime.parse(json['inTime']),
      outTime:
          json['outTime'] is DateTime
              ? json['outTime']
              : DateTime.parse(json['outTime']),
      title: json['title'],
      colour: json['colour'],
      description: json['description'],
      locationId: json['location']?.toString(),
      serviceType: _parseServiceType(json['serviceType']),
      appointmentState: _parseAppointmentState(json['appointmentState']),
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'inTime': inTime.toIso8601String(),
      'outTime': outTime.toIso8601String(),
      'title': title,
      if (colour != null) 'colour': colour,
      if (description != null) 'description': description,
      if (locationId != null) 'location': locationId,
      'serviceType': serviceType.toString().split('.').last.toLowerCase(),
      'appointmentState':
          appointmentState.toString().split('.').last.toLowerCase(),
      'isDeleted': isDeleted,
    };
  }

  static AppointmentServiceType _parseServiceType(String? value) {
    if (value == null) return AppointmentServiceType.personal;

    switch (value.toUpperCase()) {
      case 'professional':
        return AppointmentServiceType.professional;
      case 'personal':
        return AppointmentServiceType.personal;
      default:
        return AppointmentServiceType.personal;
    }
  }

  static AppointmentState _parseAppointmentState(String? value) {
    if (value == null) return AppointmentState.requested;

    switch (value.toUpperCase()) {
      case 'ACCEPTED':
        return AppointmentState.accepted;
      case 'REJECTED':
        return AppointmentState.rejected;
      case 'STANDBY':
        return AppointmentState.standby;
      case 'REQUESTED':
      default:
        return AppointmentState.requested;
    }
  }
}
