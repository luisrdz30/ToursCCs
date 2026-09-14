class UserModel {
  final String id;
  final String name;
  final String language;

  UserModel({
    required this.id,
    required this.name,
    required this.language,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      language: json['language'] ?? 'es',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'language': language,
    };
  }
}
