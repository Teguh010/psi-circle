import 'package:flutter_test/flutter_test.dart';
import 'package:psi_circle_mobile/core/models/discovery.dart';
import 'package:psi_circle_mobile/core/models/vibe.dart';

void main() {
  test('discovery item reads a vibe preset and treats null as no badge', () {
    final withVibe = DiscoveryNearbyItem.fromJson(const {
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
    });
    expect(withVibe.vibe, Vibe.ngopi);
    expect(withVibe.vibe!.shortLabel, 'Ngopi');
    expect(withVibe.vibe!.label, 'Ngopi');

    final withoutBadge = DiscoveryNearbyItem.fromJson(const {
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
    });
    expect(withoutBadge.vibe, isNull);
  });

  test('invisible presence has no vibe', () {
    final status = PresenceStatus.fromJson(const {
      'visibility': 'INVISIBLE',
      'activeCommunityIds': <String>[],
      'radius': null,
      'vibe': null,
      'updatedAt': '2026-11-15T08:05:00Z',
      'expiresAt': null,
    });
    expect(status.isVisible, isFalse);
    expect(status.vibe, isNull);
  });

  test('a free-text vibe is ignored', () {
    expect(Vibe.fromApi('at the cafe on floor 2'), isNull);
    expect(Vibe.fromApi('OPEN_TO_SAY_HI')!.label, 'Open to say hi');
  });
}
