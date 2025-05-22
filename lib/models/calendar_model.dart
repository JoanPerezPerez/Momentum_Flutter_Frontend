class CalendarModel {
  final String id;
  final String name;
  final String owner;
  final String? defaultColour;

  CalendarModel({required this.id, required this.name, required this.defaultColour, required this.owner});

  factory CalendarModel.fromJson(Map<String, dynamic> json) {
    return CalendarModel(
      id: json['_id'].toString(),
      name: json['calendarName'].toString(),
      owner: json['owner'].toString(),
      defaultColour: json['defaultColour'],
    );
  }

   CalendarModel copyWith({
    String? id,
    String? name,
    String? defaultColour,
    String? owner,
  }) {
    return CalendarModel(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultColour: defaultColour ?? this.defaultColour,
      owner: owner ?? this.owner,
    );
  }

}