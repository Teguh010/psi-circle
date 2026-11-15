import '../../../core/models/auth_tokens.dart';
import '../../../core/models/user.dart';

/// Contract for auth operations. UI depends on this interface only.
/// Swap [MockAuthRepository] → HTTP impl later without changing screens.
abstract class AuthRepository {
  Future<User> register({required String email, required String password});

  Future<AuthTokens> login({required String email, required String password});

  Future<void> logout();

  Future<void> verifyEmail({required String token});

  /// Whether a mock/session token is currently held.
  Future<bool> hasSession();

  Future<AuthTokens?> currentTokens();
}
