import '../../../core/models/discovery.dart';
import '../../../core/models/vibe.dart';
import 'presence_repository.dart';

/// OpenAPI Presence examples — never returns coordinates.
class MockPresenceRepository implements PresenceRepository {
  PresenceStatus _status = PresenceStatus.fromJson(const {
    'visibility': 'INVISIBLE',
    'activeCommunityIds': <String>[],
    'radius': null,
    'vibe': null,
    'updatedAt': '2026-11-15T08:00:00Z',
    'expiresAt': null,
  });

  @override
  Future<PresenceStatus> getStatus() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _status;
  }

  @override
  Future<PresenceStatus> setVisible({
    required double latitude,
    required double longitude,
    required List<String> activeCommunityIds,
    int radius = 3000,
    Vibe? vibe,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    // latitude/longitude accepted but never stored in the returned status.
    _status = PresenceStatus.fromJson({
      'visibility': 'VISIBLE',
      'activeCommunityIds': activeCommunityIds,
      'radius': radius,
      'vibe': vibe?.apiValue,
      'updatedAt': '2026-11-15T08:00:00Z',
      'expiresAt': '2026-11-15T08:02:00Z',
    });
    return _status;
  }

  @override
  Future<PresenceStatus> setInvisible() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _status = PresenceStatus.fromJson(const {
      'visibility': 'INVISIBLE',
      'activeCommunityIds': <String>[],
      'radius': null,
      'vibe': null,
      'updatedAt': '2026-11-15T08:05:00Z',
      'expiresAt': null,
    });
    return _status;
  }
}
