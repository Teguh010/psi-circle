import 'package:flutter/material.dart';
import 'package:psi_circle_mobile/core/theme/psi_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/community.dart';
import '../../../core/providers/repository_providers.dart';
import '../data/mock_communities_repository.dart';

class CommunityDetailScreen extends ConsumerStatefulWidget {
  const CommunityDetailScreen({super.key, required this.communityId});

  final String communityId;

  @override
  ConsumerState<CommunityDetailScreen> createState() =>
      _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends ConsumerState<CommunityDetailScreen> {
  Community? _community;
  bool _joined = false;
  bool _loading = true;
  bool _busy = false;
  final _inviteCode = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _inviteCode.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = ref.read(communitiesRepositoryProvider);
    final community = await repo.getById(widget.communityId);
    final mine = await repo.myCommunities();
    setState(() {
      _community = community;
      _joined = mine.any((c) => c.id == community.id);
      _loading = false;
    });
  }

  Future<void> _toggleMembership() async {
    final community = _community;
    if (community == null) return;
    setState(() => _busy = true);
    try {
      final repo = ref.read(communitiesRepositoryProvider);
      if (_joined) {
        await repo.leave(community.id);
        setState(() => _joined = false);
      } else {
        await repo.join(
          community.id,
          invitationCode: community.isPublic ? null : _inviteCode.text.trim(),
        );
        setState(() => _joined = true);
      }
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _community == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final community = _community!;
    final mockRepo = ref.read(communitiesRepositoryProvider);
    final showInviteField = !community.isPublic &&
        !_joined &&
        mockRepo is MockCommunitiesRepository;

    return Scaffold(
      appBar: PsiAppBar(title: Text(community.name)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            community.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '${community.memberCount} members · ${community.visibility}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          Text(community.description),
          if (showInviteField) ...[
            const SizedBox(height: 24),
            TextField(
              controller: _inviteCode,
              decoration: const InputDecoration(
                labelText: 'Invitation code',
                helperText: 'Required for private communities',
              ),
            ),
          ],
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _busy ? null : _toggleMembership,
            child: _busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_joined ? 'Leave community' : 'Join community'),
          ),
        ],
      ),
    );
  }
}
