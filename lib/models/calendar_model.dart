class CalendarModel {
  final String id;
  final String name;
  final String owner;

  CalendarModel({required this.id, required this.name, required this.owner});

  factory CalendarModel.fromJson(Map<String, dynamic> json) {
    return CalendarModel(
      id: json['_id'].toString(),
      name: json['calendarName'].toString(),
      owner: json['owner'].toString(),
    );
  }

   CalendarModel copyWith({
    String? id,
    String? name,
    String? owner,
  }) {
    return CalendarModel(
      id: id ?? this.id,
      name: name ?? this.name,
      owner: owner ?? this.owner,
    );
  }

}