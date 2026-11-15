import '../../../core/models/community.dart';

abstract class CommunitiesRepository {
  Future<CommunityListPage> search({
    String? q,
    int page = 1,
    int limit = 20,
  });

  Future<Community> getById(String communityId);

  Future<Community> create({
    required String name,
    required String description,
    required String visibility,
    String? avatarUrl,
  });

  Future<CommunityMember> join(
    String communityId, {
    String? invitationCode,
  });

  Future<void> leave(String communityId);

  /// Mock-only helper: communities the current user has joined (ACTIVE).
  /// OpenAPI does not yet expose a dedicated "my memberships" list endpoint;
  /// this keeps UI working until the contract adds one.
  Future<List<Community>> myCommunities();
}
