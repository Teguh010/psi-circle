import 'package:flutter/material.dart';
import 'package:psi_circle_mobile/core/theme/psi_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/session_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final user = session.user;

    return Scaffold(
      appBar: const PsiAppBar(title: Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              (user?.displayName?.isNotEmpty ?? false)
                  ? user!.displayName![0].toUpperCase()
                  : '?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.displayName ?? '—',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            '@${user?.username ?? '—'}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(user?.email ?? ''),
          if (user?.bio != null && user!.bio!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(user.bio!),
          ],
          if (session.selectedInterests.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Interests', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: session.selectedInterests
                  .map((i) => Chip(label: Text(i)))
                  .toList(),
            ),
          ],
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () =>
                ref.read(sessionControllerProvider.notifier).logout(),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}
