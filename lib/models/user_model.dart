class Usuari {
  final String? id;
  final String name;
  final int age;
  final String mail;

  Usuari({this.id, required this.name, required this.age, required this.mail});

  // Constructor des de JSON
  factory Usuari.fromJson(Map<String, dynamic> json) {
    return Usuari(
      id: json['_id']?.toString(),
      name: json['name'],
      age: json['age'],
      mail: json['mail'],
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {if (id != null) '_id': id, 'name': name, 'age': age, 'mail': mail};
  }
}
