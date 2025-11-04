// lib/features/profile/models/user_model.dart

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String? contactNumber;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    this.contactNumber,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      username: json['username'] ?? json['email'] ?? '',
      email: json['email'] ?? '',
      contactNumber: json['contact_number'],
    );
  }
}