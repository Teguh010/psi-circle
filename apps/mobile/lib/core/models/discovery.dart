/// Mirrors OpenAPI `PresenceStatus` and `DiscoveryNearbyItem`.
/// Never includes raw coordinates for other users.
class PresenceStatus {
  const PresenceStatus({
    required this.visibility,
    required this.activeCommunityIds,
    required this.updatedAt,
    this.radius,
    this.expiresAt,
  });

  final String visibility;
  final List<String> activeCommunityIds;
  final int? radius;
  final String updatedAt;
  final String? expiresAt;

  bool get isVisible => visibility == 'VISIBLE';

  factory PresenceStatus.fromJson(Map<String, dynamic> json) {
    return PresenceStatus(
      visibility: json['visibility'] as String,
      activeCommunityIds: (json['activeCommunityIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      radius: json['radius'] as int?,
      updatedAt: json['updatedAt'] as String,
      expiresAt: json['expiresAt'] as String?,
    );
  }
}

class DiscoveryNearbyItem {
  const DiscoveryNearbyItem({
    required this.userId,
    required this.displayName,
    required this.username,
    required this.communityId,
    required this.communityName,
    required this.distanceLabel,
    this.avatarUrl,
  });

  final String userId;
  final String displayName;
  final String username;
  final String? avatarUrl;
  final String communityId;
  final String communityName;

  /// Bucketed label only — never a precise meter value (PRIVACY).
  final String distanceLabel;

  factory DiscoveryNearbyItem.fromJson(Map<String, dynamic> json) {
    final community = json['community'] as Map<String, dynamic>;
    return DiscoveryNearbyItem(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      communityId: community['id'] as String,
      communityName: community['name'] as String,
      distanceLabel: json['distanceLabel'] as String,
    );
  }
}
