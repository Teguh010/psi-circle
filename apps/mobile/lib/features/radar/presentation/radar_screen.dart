import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/psi_app_bar.dart';
import '../../../core/models/community.dart';
import '../../../core/models/discovery.dart';
import '../../../core/providers/repository_providers.dart';
import 'radar_map.dart';

/// Mock "you are here" — Surabaya-ish coords from OpenAPI presence example.
const _mockSelfLocation = LatLng(-7.123456, 112.123456);

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
          latitude: _mockSelfLocation.latitude,
          longitude: _mockSelfLocation.longitude,
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
    final radius = _presence?.radius ?? 3000;

    // Map must sit in a bounded box outside a scrolling ListView — putting
    // FlutterMap inside ListView triggers layout/semantics assertion storms.
    return Scaffold(
      appBar: const PsiAppBar(title: Text('Radar')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SizedBox(
              height: 240,
              child: RadarMap(
                center: _mockSelfLocation,
                isVisible: visible,
                radiusMeters: radius,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              'Map shows your area only. Nearby people are listed with '
              'approximate distance — never as exact pins.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ),
          Expanded(
            child: ListView(
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
                                visible
                                    ? 'You are Visible'
                                    : 'You are Invisible',
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
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Active community',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                if (_myCommunities.isEmpty)
                  const Text('Join a community to use Radar.')
                else
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCommunityId,
                    items: _myCommunities
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
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
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            child: Text(item.displayName[0].toUpperCase()),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.displayName,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  '${item.communityName} · ${item.distanceLabel}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            style: PsiButtons.compact(),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Wave to ${item.displayName} — Phase 4',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Wave'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
