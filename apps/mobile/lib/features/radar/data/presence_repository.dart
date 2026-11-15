import '../../../core/models/discovery.dart';
import '../../../core/models/vibe.dart';

abstract class PresenceRepository {
  Future<PresenceStatus> getStatus();

  /// [vibe] null publishes Visible with no badge.
  Future<PresenceStatus> setVisible({
    required double latitude,
    required double longitude,
    required List<String> activeCommunityIds,
    int radius = 3000,
    Vibe? vibe,
  });

  Future<PresenceStatus> setInvisible();
}
