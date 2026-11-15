import '../../../core/models/user.dart';

abstract class ProfileRepository {
  Future<User> getMe();

  Future<User> updateMe({
    String? username,
    String? displayName,
    String? avatarUrl,
    String? bio,
  });
}
