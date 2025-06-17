class Usuari {
  final String? id;
  final String name;
  final int age;
  final String mail;
  final List<String> favoriteLocations;
  final List<String> friends;
  final List<String> friendRequests;

  Usuari({this.id, required this.name, required this.age, required this.mail, this.favoriteLocations = const [], this.friends = const [], this.friendRequests = const [],});

  // Constructor des de JSON
  factory Usuari.fromJson(Map<String, dynamic> json) {
    return Usuari(
      id: json['_id']?.toString(),
      name: json['name'],
      age: json['age'],
      mail: json['mail'],
      favoriteLocations: List<String>.from(json['favoriteLocations'] ?? []),
      friends: List<String>.from(json['friends'] ?? []),
      friendRequests: List<String>.from(json['friendRequests'] ?? []),
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {if (id != null) '_id': id, 'name': name, 'age': age, 'mail': mail, 'favoriteLocations': favoriteLocations,'friends': friends,'friendRequests': friendRequests,};
  }
}
