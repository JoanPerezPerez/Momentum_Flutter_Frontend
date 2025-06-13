class AmistatModel {
  final String id;
  final String mail;

  AmistatModel({required this.id, required this.mail});

  factory AmistatModel.fromJson(Map<String, dynamic> json) {
    return AmistatModel(
      id: json['_id'],
      mail: json['mail'],
    );
  }
}
