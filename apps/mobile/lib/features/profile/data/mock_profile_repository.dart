import '../../../core/models/user.dart';
import '../../auth/data/mock_auth_repository.dart';
import 'profile_repository.dart';

/// Mirrors OpenAPI `/users/me` examples.
class MockProfileRepository implements ProfileRepository {
  @override
  Future<User> getMe() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return MockAuthRepository.seedUser;
  }

  @override
  Future<User> updateMe({
    String? username,
    String? displayName,
    String? avatarUrl,
    String? bio,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    MockAuthRepository.seedUser = MockAuthRepository.seedUser.copyWith(
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
      bio: bio,
    );
    return MockAuthRepository.seedUser;
  }
}
