import '../../../core/models/discovery.dart';

abstract class PresenceRepository {
  Future<PresenceStatus> getStatus();

  Future<PresenceStatus> setVisible({
    required double latitude,
    required double longitude,
    required List<String> activeCommunityIds,
    int radius = 3000,
  });

  Future<PresenceStatus> setInvisible();
}
