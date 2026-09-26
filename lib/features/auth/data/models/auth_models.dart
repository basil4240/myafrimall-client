class AuthUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? avatar;
  final bool isVerified;
  final DateTime createdAt;

  const AuthUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.avatar,
    required this.isVerified,
    required this.createdAt,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        avatar: json['avatar'] as String?,
        isVerified: json['isVerified'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  String get fullName => '$firstName $lastName';

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
      );
}

class AuthResponse {
  final AuthTokens tokens;
  final AuthUser user;

  const AuthResponse({required this.tokens, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        tokens: AuthTokens.fromJson(json),
        user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      );
}
