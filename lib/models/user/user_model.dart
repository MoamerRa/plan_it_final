class UserModel {
  final String id;
  final String name;
  final String namelowercase; 
  final String email;
  final String phone;
  final String role;
  final String customId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.customId,
  }) : namelowercase = name.toLowerCase(); // Automatically set the lowercase version

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? '',
      customId: map['customId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'name': name,
      'name_lowercase': namelowercase, // Add to map for Firestore
      'email': email,
      'phone': phone,
      'role': role,
      'customId': customId,
    };
  }
}
