import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/mock_auth_repository.dart';
import '../../features/communities/data/communities_repository.dart';
import '../../features/communities/data/mock_communities_repository.dart';
import '../../features/profile/data/mock_profile_repository.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/radar/data/discovery_repository.dart';
import '../../features/radar/data/mock_discovery_repository.dart';
import '../../features/radar/data/mock_presence_repository.dart';
import '../../features/radar/data/presence_repository.dart';

/// Swap these providers to HTTP implementations during integration.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => MockAuthRepository(),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => MockProfileRepository(),
);

final communitiesRepositoryProvider = Provider<CommunitiesRepository>(
  (ref) => MockCommunitiesRepository(),
);

final presenceRepositoryProvider = Provider<PresenceRepository>(
  (ref) => MockPresenceRepository(),
);

final discoveryRepositoryProvider = Provider<DiscoveryRepository>(
  (ref) => MockDiscoveryRepository(),
);
