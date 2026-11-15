import '../../../core/models/auth_tokens.dart';
import '../../../core/models/user.dart';
import 'auth_repository.dart';

/// Returns payloads shaped exactly like OpenAPI `example:` blocks for Auth.
class MockAuthRepository implements AuthRepository {
  AuthTokens? _tokens;
  User? _registeredUser;

  /// Shared with [MockProfileRepository] during the mock phase so profile
  /// updates persist across screens without a real backend.
  static User seedUser = User.fromJson(const {
    'id': 'b1f0c6f0-1111-4a11-9a11-000000000001',
    'email': 'alex@example.com',
    'status': 'ACTIVE',
    'emailVerifiedAt': '2026-11-10T08:00:00Z',
    'createdAt': '2026-11-01T08:00:00Z',
    'username': 'alex123',
    'displayName': 'Alex',
    'avatarUrl': null,
    'bio': 'Weekend rider.',
  });

  @override
  Future<User> register({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    // OpenAPI example for POST /auth/register 201.
    _registeredUser = User.fromJson({
      'id': 'b1f0c6f0-1111-4a11-9a11-000000000001',
      'email': email,
      'status': 'ACTIVE',
      'emailVerifiedAt': null,
      'createdAt': '2026-11-15T08:00:00Z',
    });
    seedUser = _registeredUser!;
    return _registeredUser!;
  }

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    // OpenAPI example for POST /auth/login 200.
    _tokens = AuthTokens.fromJson(const {
      'accessToken': 'eyJhbGciOi...access',
      'refreshToken': 'eyJhbGciOi...refresh',
      'expiresIn': 900,
    });
    if (_registeredUser == null) {
      seedUser = User.fromJson({
        'id': 'b1f0c6f0-1111-4a11-9a11-000000000001',
        'email': email,
        'status': 'ACTIVE',
        'emailVerifiedAt': '2026-11-10T08:00:00Z',
        'createdAt': '2026-11-01T08:00:00Z',
        'username': 'alex123',
        'displayName': 'Alex',
        'avatarUrl': null,
        'bio': 'Weekend rider.',
      });
    }
    return _tokens!;
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _tokens = null;
  }

  @override
  Future<void> verifyEmail({required String token}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    seedUser = seedUser.copyWith(
      emailVerifiedAt: '2026-11-15T08:10:00Z',
    );
  }

  @override
  Future<bool> hasSession() async => _tokens != null;

  @override
  Future<AuthTokens?> currentTokens() async => _tokens;
}
