class Role {
  final String id;
  final String name;
  final String description;

  Role({
    required this.id,
    required this.name,
    required this.description,
  });

  // Factory method to create a Role from a JSON object
  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  // Method to convert a Role object to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}
