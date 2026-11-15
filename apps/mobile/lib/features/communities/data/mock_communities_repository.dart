import '../../../core/models/community.dart';
import '../../../core/models/page_meta.dart';
import 'communities_repository.dart';

/// Seed + responses shaped like OpenAPI Communities examples.
class MockCommunitiesRepository implements CommunitiesRepository {
  final List<Community> _catalog = [
    Community.fromJson(const {
      'id': 'c1111111-0000-0000-0000-000000000001',
      'name': 'Automotive Community',
      'slug': 'automotive-community',
      'description': 'For car enthusiasts.',
      'avatarUrl': null,
      'visibility': 'PUBLIC',
      'memberCount': 128,
      'createdBy': 'b1f0c6f0-1111-4a11-9a11-000000000001',
      'createdAt': '2026-01-10T08:00:00Z',
      'updatedAt': '2026-01-10T08:00:00Z',
    }),
    Community.fromJson(const {
      'id': 'c2222222-0000-0000-0000-000000000002',
      'name': 'Cycling Community',
      'slug': 'cycling-community',
      'description': 'Weekend rides and city cycling.',
      'avatarUrl': null,
      'visibility': 'PUBLIC',
      'memberCount': 86,
      'createdBy': 'a2f0c6f0-2222-4a11-9a11-000000000002',
      'createdAt': '2026-02-01T08:00:00Z',
      'updatedAt': '2026-02-01T08:00:00Z',
    }),
    Community.fromJson(const {
      'id': 'c3333333-0000-0000-0000-000000000003',
      'name': 'Photography Community',
      'slug': 'photography-community',
      'description': 'Street and travel photography meetups.',
      'avatarUrl': null,
      'visibility': 'PUBLIC',
      'memberCount': 54,
      'createdBy': 'd3f0c6f0-3333-4a11-9a11-000000000003',
      'createdAt': '2026-03-12T08:00:00Z',
      'updatedAt': '2026-03-12T08:00:00Z',
    }),
    Community.fromJson(const {
      'id': 'c4444444-0000-0000-0000-000000000004',
      'name': 'Private Runners Club',
      'slug': 'private-runners-club',
      'description': 'Invite-only morning run crew.',
      'avatarUrl': null,
      'visibility': 'PRIVATE',
      'memberCount': 18,
      'createdBy': 'a2f0c6f0-2222-4a11-9a11-000000000002',
      'createdAt': '2026-04-01T08:00:00Z',
      'updatedAt': '2026-04-01T08:00:00Z',
    }),
  ];

  final Set<String> _joinedIds = {
    'c1111111-0000-0000-0000-000000000001',
  };

  @override
  Future<CommunityListPage> search({
    String? q,
    int page = 1,
    int limit = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final query = (q ?? '').trim().toLowerCase();
    final filtered = _catalog.where((c) {
      if (!c.isPublic && !_joinedIds.contains(c.id)) return false;
      if (query.isEmpty) return true;
      return c.name.toLowerCase().contains(query) ||
          c.description.toLowerCase().contains(query);
    }).toList();

    return CommunityListPage(
      data: filtered,
      meta: PageMeta(page: page, limit: limit, total: filtered.length),
    );
  }

  @override
  Future<Community> getById(String communityId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _catalog.firstWhere((c) => c.id == communityId);
  }

  @override
  Future<Community> create({
    required String name,
    required String description,
    required String visibility,
    String? avatarUrl,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final slug = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    final community = Community(
      id: 'c${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      slug: slug,
      description: description,
      avatarUrl: avatarUrl,
      visibility: visibility,
      memberCount: 1,
      createdBy: 'b1f0c6f0-1111-4a11-9a11-000000000001',
      createdAt: DateTime.now().toUtc().toIso8601String(),
      updatedAt: DateTime.now().toUtc().toIso8601String(),
    );
    _catalog.insert(0, community);
    _joinedIds.add(community.id);
    return community;
  }

  @override
  Future<CommunityMember> join(
    String communityId, {
    String? invitationCode,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final community = _catalog.firstWhere((c) => c.id == communityId);
    if (!community.isPublic &&
        (invitationCode == null || invitationCode.trim().isEmpty)) {
      throw StateError('invitationCode required for private communities');
    }
    _joinedIds.add(communityId);
    final index = _catalog.indexWhere((c) => c.id == communityId);
    _catalog[index] = community.copyWith(memberCount: community.memberCount + 1);

    return CommunityMember.fromJson({
      'id': 'm-${DateTime.now().millisecondsSinceEpoch}',
      'communityId': communityId,
      'userId': 'b1f0c6f0-1111-4a11-9a11-000000000001',
      'role': 'MEMBER',
      'status': 'ACTIVE',
      'joinedAt': DateTime.now().toUtc().toIso8601String(),
      'profile': {
        'username': 'alex123',
        'displayName': 'Alex',
        'avatarUrl': null,
      },
    });
  }

  @override
  Future<void> leave(String communityId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _joinedIds.remove(communityId);
  }

  @override
  Future<List<Community>> myCommunities() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _catalog.where((c) => _joinedIds.contains(c.id)).toList();
  }

  bool isJoined(String communityId) => _joinedIds.contains(communityId);
}
