import '../../../core/models/discovery.dart';

abstract class DiscoveryRepository {
  Future<List<DiscoveryNearbyItem>> nearby({
    required String communityId,
    int radius = 3000,
  });
}
