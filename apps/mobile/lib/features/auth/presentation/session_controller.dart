import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user.dart';
import '../../../core/providers/repository_providers.dart';

enum AppAuthStatus {
  unknown,
  unauthenticated,
  needsOnboarding,
  authenticated,
}

class SessionState {
  const SessionState({
    required this.status,
    this.user,
    this.selectedInterests = const [],
  });

  final AppAuthStatus status;
  final User? user;
  final List<String> selectedInterests;

  SessionState copyWith({
    AppAuthStatus? status,
    User? user,
    List<String>? selectedInterests,
  }) {
    return SessionState(
      status: status ?? this.status,
      user: user ?? this.user,
      selectedInterests: selectedInterests ?? this.selectedInterests,
    );
  }
}

class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() => const SessionState(status: AppAuthStatus.unknown);

  Future<void> bootstrap() async {
    final auth = ref.read(authRepositoryProvider);
    final hasSession = await auth.hasSession();
    if (!hasSession) {
      state = const SessionState(status: AppAuthStatus.unauthenticated);
      return;
    }
    await _loadProfileAndRoute();
  }

  Future<void> login({required String email, required String password}) async {
    final auth = ref.read(authRepositoryProvider);
    await auth.login(email: email, password: password);
    await _loadProfileAndRoute();
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    final auth = ref.read(authRepositoryProvider);
    await auth.register(email: email, password: password);
    // After register, auto-login with mock tokens so onboarding can continue.
    await auth.login(email: email, password: password);
    await auth.verifyEmail(token: 'mock-verify-token');
    await _loadProfileAndRoute(forceOnboarding: true);
  }

  Future<void> completeProfile({
    required String username,
    required String displayName,
    String? bio,
  }) async {
    final profile = ref.read(profileRepositoryProvider);
    final user = await profile.updateMe(
      username: username,
      displayName: displayName,
      bio: bio,
    );
    state = state.copyWith(
      user: user,
      status: AppAuthStatus.needsOnboarding,
    );
  }

  void setInterests(List<String> interests) {
    state = state.copyWith(selectedInterests: interests);
  }

  Future<void> finishOnboarding() async {
    state = state.copyWith(status: AppAuthStatus.authenticated);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const SessionState(status: AppAuthStatus.unauthenticated);
  }

  Future<void> refreshMe() async {
    final user = await ref.read(profileRepositoryProvider).getMe();
    state = state.copyWith(user: user);
  }

  Future<void> _loadProfileAndRoute({bool forceOnboarding = false}) async {
    final user = await ref.read(profileRepositoryProvider).getMe();
    if (forceOnboarding || !user.hasCompletedProfile) {
      state = SessionState(
        status: AppAuthStatus.needsOnboarding,
        user: user,
      );
      return;
    }
    state = SessionState(
      status: AppAuthStatus.authenticated,
      user: user,
    );
  }
}

final sessionControllerProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);
