class AdminModel {
  final String id;
  final String name;
  final String namelowercase; // New field
  final String email;
  final String role;

  AdminModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'admin',
  }) : namelowercase = name.toLowerCase();

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'admin',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'name_lowercase': namelowercase, // Add to map
      'email': email,
      'role': role,
    };
  }

  factory AdminModel.fromJson(Map<String, dynamic> json) =>
      AdminModel.fromMap(json);

  Map<String, dynamic> toJson() => toMap();

  AdminModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
  }) {
    return AdminModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.role == role;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ email.hashCode ^ role.hashCode;
  }
}
