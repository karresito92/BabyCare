class User {
  final int id;
  final String email;
  final String name;
  final String? profilePicture;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.profilePicture,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      profilePicture: json['profile_picture'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profile_picture': profilePicture,
      'created_at': createdAt.toIso8601String(),
    };
  }
}