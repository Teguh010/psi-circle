import 'page_meta.dart';

/// Mirrors OpenAPI `Community` and related membership types.
class Community {
  const Community({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.visibility,
    required this.memberCount,
    required this.createdAt,
    this.avatarUrl,
    this.createdBy,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String slug;
  final String description;
  final String? avatarUrl;
  final String visibility;
  final int memberCount;
  final String? createdBy;
  final String createdAt;
  final String? updatedAt;

  bool get isPublic => visibility == 'PUBLIC';

  Community copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    String? avatarUrl,
    String? visibility,
    int? memberCount,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
  }) {
    return Community(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      visibility: visibility ?? this.visibility,
      memberCount: memberCount ?? this.memberCount,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      visibility: json['visibility'] as String,
      memberCount: json['memberCount'] as int,
      createdBy: json['createdBy'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

class CommunityMember {
  const CommunityMember({
    required this.id,
    required this.communityId,
    required this.userId,
    required this.role,
    required this.status,
    required this.joinedAt,
    this.username,
    this.displayName,
    this.avatarUrl,
  });

  final String id;
  final String communityId;
  final String userId;
  final String role;
  final String status;
  final String joinedAt;
  final String? username;
  final String? displayName;
  final String? avatarUrl;

  factory CommunityMember.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>?;
    return CommunityMember(
      id: json['id'] as String,
      communityId: json['communityId'] as String,
      userId: json['userId'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      joinedAt: json['joinedAt'] as String,
      username: profile?['username'] as String?,
      displayName: profile?['displayName'] as String?,
      avatarUrl: profile?['avatarUrl'] as String?,
    );
  }
}

class CommunityListPage {
  const CommunityListPage({required this.data, required this.meta});

  final List<Community> data;
  final PageMeta meta;
}
