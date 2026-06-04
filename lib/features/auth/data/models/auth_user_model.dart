/// Authenticated user returned by `/auth/login` and `/auth/me`.
class AuthUser {
  const AuthUser({
    required this.userId,
    required this.namaUser,
    required this.username,
    required this.role,
  });

  final int userId;
  final String namaUser;
  final String username;
  final String role;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: (json['userId'] as num).toInt(),
      namaUser: (json['namaUser'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
    );
  }
}
