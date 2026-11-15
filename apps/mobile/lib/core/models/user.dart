/// Mirrors OpenAPI `User` / `MeResponse`.
class User {
  const User({
    required this.id,
    required this.email,
    required this.status,
    required this.createdAt,
    this.emailVerifiedAt,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.bio,
  });

  final String id;
  final String email;
  final String status;
  final String? emailVerifiedAt;
  final String createdAt;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;

  bool get hasCompletedProfile =>
      username != null &&
      username!.isNotEmpty &&
      displayName != null &&
      displayName!.isNotEmpty;

  User copyWith({
    String? id,
    String? email,
    String? status,
    String? emailVerifiedAt,
    String? createdAt,
    String? username,
    String? displayName,
    String? avatarUrl,
    String? bio,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      status: status ?? this.status,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      status: json['status'] as String,
      emailVerifiedAt: json['emailVerifiedAt'] as String?,
      createdAt: json['createdAt'] as String,
      username: json['username'] as String?,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'status': status,
        'emailVerifiedAt': emailVerifiedAt,
        'createdAt': createdAt,
        'username': username,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'bio': bio,
      };
}
