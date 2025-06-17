class AmistatModel {
  final String id;
  final String name;
  final String mail;

  AmistatModel({required this.id, required this.name, required this.mail});

  factory AmistatModel.fromJson(Map<String, dynamic> json) {
    return AmistatModel(
      id: json['_id'],
      name: json['name'],
      mail: json['mail'],
    );
  }
}
