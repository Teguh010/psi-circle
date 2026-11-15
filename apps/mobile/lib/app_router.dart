import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/presentation/session_controller.dart';
import 'features/auth/presentation/welcome_screen.dart';
import 'features/chat/presentation/chats_placeholder_screen.dart';
import 'features/communities/presentation/communities_screen.dart';
import 'features/communities/presentation/community_detail_screen.dart';
import 'features/communities/presentation/create_community_screen.dart';
import 'features/onboarding/presentation/interest_selection_screen.dart';
import 'features/onboarding/presentation/join_communities_onboarding_screen.dart';
import 'features/onboarding/presentation/profile_setup_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/radar/presentation/nearby_member_screen.dart';
import 'core/models/discovery.dart';
import 'features/radar/presentation/radar_screen.dart';
import 'features/shell/main_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/welcome',
    refreshListenable: _SessionListenable(ref),
    redirect: (context, state) {
      final session = ref.read(sessionControllerProvider);
      final status = session.status;
      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/welcome' ||
          loc == '/login' ||
          loc == '/register';
      final isOnboarding = loc.startsWith('/onboarding');

      if (status == AppAuthStatus.unknown) {
        return null;
      }

      if (status == AppAuthStatus.unauthenticated) {
        return isAuthRoute ? null : '/welcome';
      }

      if (status == AppAuthStatus.needsOnboarding) {
        if (isOnboarding) return null;
        // Profile incomplete → start at profile setup; otherwise continue flow.
        final user = session.user;
        if (user == null || !user.hasCompletedProfile) {
          return '/onboarding/profile';
        }
        if (session.selectedInterests.isEmpty) {
          return '/onboarding/interests';
        }
        return '/onboarding/communities';
      }

      // authenticated
      if (isAuthRoute || isOnboarding) {
        return '/radar';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/onboarding/profile',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/onboarding/interests',
        builder: (context, state) => const InterestSelectionScreen(),
      ),
      GoRoute(
        path: '/onboarding/communities',
        builder: (context, state) => const JoinCommunitiesOnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/radar',
                builder: (context, state) => const RadarScreen(),
                routes: [
                  GoRoute(
                    path: 'member',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final person = state.extra;
                      if (person is! DiscoveryNearbyItem) {
                        return const Scaffold(
                          body: Center(child: Text('Member not found')),
                        );
                      }
                      return NearbyMemberScreen(person: person);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/communities',
                builder: (context, state) => const CommunitiesScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const CreateCommunityScreen(),
                  ),
                  GoRoute(
                    path: ':communityId',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['communityId']!;
                      return CommunityDetailScreen(communityId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chats',
                builder: (context, state) => const ChatsPlaceholderScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// Bridges Riverpod session changes into go_router's refreshListenable.
class _SessionListenable extends ChangeNotifier {
  _SessionListenable(this._ref) {
    _ref.listen<SessionState>(sessionControllerProvider, (_, _) {
      notifyListeners();
    });
  }

  final Ref _ref;
}
