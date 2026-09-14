class LoginResponse {
  final String token;
  final String role;
  final String email;
  final String firstName;
  final String lastName;

  LoginResponse({
    required this.token,
    required this.role,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      // En C# el Enum puede venir como String o Int. Si es Int lo pasamos a String o lo manejamos como String
      role: json['role']?.toString() ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'role': role,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}
