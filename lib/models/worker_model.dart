class Worker {
  final String? id;
  final String name;
  final int age;
  final String mail;
  final String role;
  final List<String> location;
  final String? businessAdministrated;

  Worker({
    this.id,
    required this.name,
    required this.age,
    required this.mail,
    required this.role,
    required this.location,
    this.businessAdministrated,
  });

  // Constructor des de JSON
  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['_id']?.toString(),
      name: json['name'],
      age: json['age'],
      mail: json['mail'],
      role: json['role'],
      location: List<String>.from(
        json['location']?.map((loc) => loc.toString()) ?? [],
      ),
      businessAdministrated: json['businessAdministrated']?.toString(),
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'age': age,
      'mail': mail,
      'role': role,
      'location': location,
      if (businessAdministrated != null)
        'businessAdministrated': businessAdministrated,
    };
  }
}
