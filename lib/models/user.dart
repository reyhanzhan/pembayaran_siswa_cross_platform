class User {
  final int id;
  final String name;
  final String email;
  final String peran;

  User({required this.id, required this.name, required this.email, required this.peran});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      peran: json['peran'],
    );
  }
}