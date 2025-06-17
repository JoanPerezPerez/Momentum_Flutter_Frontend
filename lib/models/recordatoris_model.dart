enum RepetitionType { daily, weekly, monthly, yearly, never }

RepetitionType repetitionTypeFromString(String value) {
  return RepetitionType.values.firstWhere(
    (e) => e.name == value.toLowerCase(),
    orElse: () => RepetitionType.never,
  );
}

String repetitionTypeToString(RepetitionType type) {
  return type.name;
}

class Recordatori {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime time;
  final RepetitionType repeat;

  Recordatori({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.time,
    required this.repeat,
  });

  factory Recordatori.fromJson(Map<String, dynamic> json, String id) {
    return Recordatori(
      id: id,
      userId: json['user'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      time: DateTime.parse(json['time'] as String),
      repeat: repetitionTypeFromString(json['repeat'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'title': title,
      'description': description,
      'time': time.toIso8601String(),
      'repeat': repetitionTypeToString(repeat),
    };
  }
}
