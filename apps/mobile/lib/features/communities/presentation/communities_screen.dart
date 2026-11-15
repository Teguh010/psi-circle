import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/community.dart';
import '../../../core/providers/repository_providers.dart';

class CommunitiesScreen extends ConsumerStatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  ConsumerState<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends ConsumerState<CommunitiesScreen> {
  final _search = TextEditingController();
  late Future<List<Community>> _mineFuture;
  late Future<CommunityListPage> _searchFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final repo = ref.read(communitiesRepositoryProvider);
    _mineFuture = repo.myCommunities();
    _searchFuture = repo.search(q: _search.text.trim());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communities'),
        actions: [
          IconButton(
            tooltip: 'Create community',
            onPressed: () async {
              await context.push('/communities/create');
              setState(_reload);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(_reload),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Search communities',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => setState(_reload),
                ),
              ),
              onSubmitted: (_) => setState(_reload),
            ),
            const SizedBox(height: 24),
            Text(
              'Your communities',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Community>>(
              future: _mineFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final mine = snapshot.data!;
                if (mine.isEmpty) {
                  return const Text('You have not joined any communities yet.');
                }
                return Column(
                  children: mine
                      .map(
                        (c) => _CommunityTile(
                          community: c,
                          onTap: () async {
                            await context.push('/communities/${c.id}');
                            setState(_reload);
                          },
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Discover',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            FutureBuilder<CommunityListPage>(
              future: _searchFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final items = snapshot.data!.data;
                if (items.isEmpty) {
                  return const Text('No communities match your search.');
                }
                return Column(
                  children: items
                      .map(
                        (c) => _CommunityTile(
                          community: c,
                          onTap: () async {
                            await context.push('/communities/${c.id}');
                            setState(_reload);
                          },
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityTile extends StatelessWidget {
  const _CommunityTile({required this.community, required this.onTap});

  final Community community;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          community.name.isNotEmpty ? community.name[0].toUpperCase() : '?',
        ),
      ),
      title: Text(community.name),
      subtitle: Text(
        '${community.memberCount} members · ${community.visibility}',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
