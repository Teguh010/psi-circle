import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/community.dart';
import '../../../core/models/discovery.dart';
import '../../../core/providers/repository_providers.dart';

class RadarScreen extends ConsumerStatefulWidget {
  const RadarScreen({super.key});

  @override
  ConsumerState<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends ConsumerState<RadarScreen> {
  List<Community> _myCommunities = [];
  String? _selectedCommunityId;
  PresenceStatus? _presence;
  List<DiscoveryNearbyItem> _nearby = [];
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final communities =
        await ref.read(communitiesRepositoryProvider).myCommunities();
    final presence = await ref.read(presenceRepositoryProvider).getStatus();
    setState(() {
      _myCommunities = communities;
      _selectedCommunityId =
          communities.isNotEmpty ? communities.first.id : null;
      _presence = presence;
      _loading = false;
    });
    if (presence.isVisible && _selectedCommunityId != null) {
      await _loadNearby();
    }
  }

  Future<void> _loadNearby() async {
    final communityId = _selectedCommunityId;
    if (communityId == null) return;
    final nearby = await ref
        .read(discoveryRepositoryProvider)
        .nearby(communityId: communityId);
    setState(() => _nearby = nearby);
  }

  Future<void> _toggleVisibility(bool visible) async {
    final communityId = _selectedCommunityId;
    if (visible && communityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Join a community first')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final presenceRepo = ref.read(presenceRepositoryProvider);
      if (visible) {
        final status = await presenceRepo.setVisible(
          latitude: -7.123456,
          longitude: 112.123456,
          activeCommunityIds: [communityId!],
        );
        setState(() => _presence = status);
        await _loadNearby();
      } else {
        final status = await presenceRepo.setInvisible();
        setState(() {
          _presence = status;
          _nearby = [];
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final visible = _presence?.isVisible ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Radar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          visible ? 'You are Visible' : 'You are Invisible',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Switch(
                        value: visible,
                        onChanged: _busy ? null : _toggleVisibility,
                      ),
                    ],
                  ),
                  Text(
                    visible
                        ? 'Nearby members from your active community can discover you. Coordinates stay on the server.'
                        : 'Turn Visible to publish temporary presence and see nearby members.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Active community', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          if (_myCommunities.isEmpty)
            const Text('Join a community to use Radar.')
          else
            DropdownButtonFormField<String>(
              initialValue: _selectedCommunityId,
              items: _myCommunities
                  .map(
                    (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                  )
                  .toList(),
              onChanged: (value) async {
                setState(() => _selectedCommunityId = value);
                if (visible) await _loadNearby();
              },
            ),
          const SizedBox(height: 24),
          Text(
            visible
                ? '${_nearby.length} people from your communities are nearby.'
                : 'Nearby list appears when you are Visible.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (!visible)
            const SizedBox.shrink()
          else if (_nearby.isEmpty)
            const Text('No one nearby right now (mock).')
          else
            ..._nearby.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  child: Text(item.displayName[0].toUpperCase()),
                ),
                title: Text(item.displayName),
                subtitle: Text('${item.communityName} · ${item.distanceLabel}'),
                trailing: FilledButton.tonal(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Wave to ${item.displayName} — Phase 4'),
                      ),
                    );
                  },
                  child: const Text('Wave'),
                ),
              ),
            ),
          const SizedBox(height: 24),
          // Simple map placeholder — real map wiring comes with location
          // integration in Phase 3. Mock UI keeps the Radar composition clear.
          AspectRatio(
            aspectRatio: 16 / 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'Map preview (mock)\nNo coordinates shown for other users',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
