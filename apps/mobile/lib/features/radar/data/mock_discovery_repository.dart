import '../../../core/models/discovery.dart';
import 'discovery_repository.dart';

/// OpenAPI `GET /discovery/nearby` example payload.
class MockDiscoveryRepository implements DiscoveryRepository {
  @override
  Future<List<DiscoveryNearbyItem>> nearby({
    required String communityId,
    int radius = 3000,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final all = [
      DiscoveryNearbyItem.fromJson(const {
        'userId': 'a2f0c6f0-2222-4a11-9a11-000000000002',
        'displayName': 'Alex',
        'username': 'alex123',
        'avatarUrl': null,
        'community': {
          'id': 'c1111111-0000-0000-0000-000000000001',
          'name': 'Automotive Community',
        },
        'distanceLabel': '300-500 m',
        'vibe': 'NGOPI',
      }),
      DiscoveryNearbyItem.fromJson(const {
        'userId': 'f5f0c6f0-5555-4a11-9a11-000000000005',
        'displayName': 'Sari',
        'username': 'sari.w',
        'avatarUrl': null,
        'community': {
          'id': 'c1111111-0000-0000-0000-000000000001',
          'name': 'Automotive Community',
        },
        'distanceLabel': '300-500 m',
        'vibe': 'DISKUSI',
      }),
      DiscoveryNearbyItem.fromJson(const {
        'userId': 'a6f0c6f0-6666-4a11-9a11-000000000006',
        'displayName': 'Bima',
        'username': 'bima_r',
        'avatarUrl': null,
        'community': {
          'id': 'c1111111-0000-0000-0000-000000000001',
          'name': 'Automotive Community',
        },
        'distanceLabel': '500 m-1 km',
        'vibe': null,
      }),
      DiscoveryNearbyItem.fromJson(const {
        'userId': 'b7f0c6f0-7777-4a11-9a11-000000000007',
        'displayName': 'Raka',
        'username': 'raka',
        'avatarUrl': null,
        'community': {
          'id': 'c1111111-0000-0000-0000-000000000001',
          'name': 'Automotive Community',
        },
        'distanceLabel': '1-3 km',
        'vibe': 'KEGIATAN',
      }),
      DiscoveryNearbyItem.fromJson(const {
        'userId': 'd3f0c6f0-3333-4a11-9a11-000000000003',
        'displayName': 'Daniel',
        'username': 'daniel_r',
        'avatarUrl': null,
        'community': {
          'id': 'c2222222-0000-0000-0000-000000000002',
          'name': 'Cycling Community',
        },
        'distanceLabel': '500 m-1 km',
        'vibe': 'OPEN_TO_SAY_HI',
      }),
      DiscoveryNearbyItem.fromJson(const {
        'userId': 'e4f0c6f0-4444-4a11-9a11-000000000004',
        'displayName': 'Michael',
        'username': 'mike_photo',
        'avatarUrl': null,
        'community': {
          'id': 'c3333333-0000-0000-0000-000000000003',
          'name': 'Photography Community',
        },
        'distanceLabel': '1-3 km',
        'vibe': null,
      }),
    ];

    return all
        .where((item) => item.communityId == communityId)
        .toList();
  }
}
