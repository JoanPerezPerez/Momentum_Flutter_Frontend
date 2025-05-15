class CalendarModel {
  final String id;
  final String name;
  final String owner;
  final String? defaultColour;

  CalendarModel({required this.id, required this.name, required this.defaultColour, required this.owner});

  factory CalendarModel.fromJson(Map<String, dynamic> json) {
    return CalendarModel(
      id: json['_id'],
      name: json['calendarName'],
      defaultColour: json['defaultColour'],
      owner: json['owner'],
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