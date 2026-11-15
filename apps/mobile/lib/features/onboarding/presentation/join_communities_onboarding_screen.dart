import 'package:flutter/material.dart';
import 'package:psi_circle_mobile/core/theme/psi_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/community.dart';
import '../../../core/providers/repository_providers.dart';
import '../../auth/presentation/session_controller.dart';

class JoinCommunitiesOnboardingScreen extends ConsumerStatefulWidget {
  const JoinCommunitiesOnboardingScreen({super.key});

  @override
  ConsumerState<JoinCommunitiesOnboardingScreen> createState() =>
      _JoinCommunitiesOnboardingScreenState();
}

class _JoinCommunitiesOnboardingScreenState
    extends ConsumerState<JoinCommunitiesOnboardingScreen> {
  late Future<CommunityListPage> _future;
  final Set<String> _joined = {};
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _future = ref.read(communitiesRepositoryProvider).search();
  }

  Future<void> _join(Community community) async {
    await ref.read(communitiesRepositoryProvider).join(community.id);
    setState(() => _joined.add(community.id));
  }

  Future<void> _finish() async {
    setState(() => _finishing = true);
    await ref.read(sessionControllerProvider.notifier).finishOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PsiAppBar(title: Text('Join a community')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Text(
                'Join at least one community to use Radar.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: FutureBuilder<CommunityListPage>(
                future: _future,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snapshot.data!.data;
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final community = items[index];
                      final joined = _joined.contains(community.id);
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        title: Text(community.name),
                        subtitle: Text(
                          '${community.memberCount} members · ${community.description}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: joined
                            ? const Icon(Icons.check_circle)
                            : TextButton(
                                onPressed: () => _join(community),
                                child: const Text('Join'),
                              ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                onPressed: (_joined.isEmpty || _finishing) ? null : _finish,
                child: _finishing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Go to Radar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
