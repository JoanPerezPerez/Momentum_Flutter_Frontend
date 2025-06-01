class Worker {
  late final String? id;
  late final String name;
  late final int age;
  late final String mail;
  late final String role;
  late final List<String> location;
  late final String? password;
  late final String? businessAdministrated;

  Worker({
    this.id,
    required this.name,
    required this.age,
    required this.mail,
    required this.role,
    required this.location,
    this.password,
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
      password: json['password']?.toString(),
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
      if (password != null) 'password': password,
      if (businessAdministrated != null)
        'businessAdministrated': businessAdministrated,
    };
  }
}
