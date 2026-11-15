import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/models/community.dart';
import '../../../core/models/discovery.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_theme.dart';
import 'radar_map.dart';

/// Mock "you are here" — Surabaya-ish coords from the OpenAPI presence example.
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
  DiscoveryNearbyItem? _selected;
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
    setState(() {
      _nearby = nearby;
      _selected = nearby.isEmpty ? null : nearby.first;
    });
  }

  Future<void> _setHidden(bool hidden) async {
    await _toggleVisibility(!hidden);
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
          _selected = null;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: PsiColors.black,
        body: Center(child: CircularProgressIndicator(color: PsiColors.red)),
      );
    }

    final visible = _presence?.isVisible ?? false;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: PsiColors.black,
      body: SizedBox.expand(
        child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: RadarMap(
              center: _mockSelfLocation,
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xCC111111),
                      Color(0x33111111),
                      Color(0x00111111),
                      Color(0xE6111111),
                    ],
                    stops: [0, 0.22, 0.55, 1],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _RadarRingsPainter(active: visible)),
            ),
          ),
          if (visible)
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size =
                      math.min(constraints.maxWidth, constraints.maxHeight) * 0.78;
                  final center = Offset(
                    constraints.maxWidth / 2,
                    constraints.maxHeight * 0.46,
                  );
                  return Stack(
                    children: [
                      for (var i = 0; i < _nearby.length; i++)
                        Positioned(
                          left: center.dx + _offset(i, size).dx - 28,
                          top: center.dy + _offset(i, size).dy - 28,
                          child: GestureDetector(
                            onTap: () => setState(() => _selected = _nearby[i]),
                            child: _PersonBubble(
                              person: _nearby[i],
                              index: i,
                              selected: _nearby[i].userId == _selected?.userId,
                              size: 56,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'People nearby',
                    style: TextStyle(
                      color: PsiColors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    visible
                        ? '${_nearby.length} from your communities'
                        : 'You are hidden',
                    style: const TextStyle(
                      color: PsiColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_myCommunities.isNotEmpty)
                    _CommunityPill(
                      communities: _myCommunities,
                      selectedId: _selectedCommunityId,
                      onChanged: (value) async {
                        setState(() => _selectedCommunityId = value);
                        if (visible) await _loadNearby();
                      },
                    ),
                ],
              ),
            ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 92 + bottomInset,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (visible && _nearby.length > 1) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'More people nearby',
                      style: TextStyle(
                        color: PsiColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 64,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _nearby.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final person = _nearby[index];
                        final active = person.userId == _selected?.userId;
                        return GestureDetector(
                          onTap: () => setState(() => _selected = person),
                          child: _PersonBubble(
                            person: person,
                            index: index,
                            selected: active,
                            size: 56,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (_selected != null)
                  _PersonCard(
                    person: _selected!,
                    onWave: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Wave to ${_selected!.displayName}'),
                        ),
                      );
                    },
                  )
                else
                  _HiddenCard(hidden: !visible),
                const SizedBox(height: 10),
                _HideLocationBar(
                  hidden: !visible,
                  busy: _busy,
                  onChanged: _setHidden,
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  /// Visual slot on a ring. Angle and radius come from the distance *bucket*,
  /// never from another user's coordinates.
  Offset _offset(int index, double mapSize) {
    final label = _nearby[index].distanceLabel;
    final ring = switch (label) {
      '300-500 m' => 0.22,
      '500 m-1 km' => 0.38,
      '1-3 km' => 0.52,
      _ => 0.62,
    };
    final angle = (-math.pi / 2) + (index * (math.pi * 2 / math.max(_nearby.length, 1)));
    final radius = mapSize * ring;
    return Offset(math.cos(angle) * radius, math.sin(angle) * radius);
  }
}

class _RadarRingsPainter extends CustomPainter {
  const _RadarRingsPainter({required this.active});

  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.46);
    final maxR = math.min(size.width, size.height) * 0.42;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = PsiColors.white.withValues(alpha: active ? 0.55 : 0.2);
    final sweep = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = PsiColors.red.withValues(alpha: active ? 0.9 : 0.35);
    for (final fraction in [0.28, 0.5, 0.72, 1.0]) {
      canvas.drawCircle(center, maxR * fraction, ring);
    }
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: maxR),
      -math.pi / 2,
      math.pi / 3,
      false,
      sweep,
    );
    canvas.drawCircle(
      center,
      7,
      Paint()..color = PsiColors.red,
    );
    canvas.drawCircle(
      center,
      7,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = PsiColors.black,
    );
  }

  @override
  bool shouldRepaint(covariant _RadarRingsPainter oldDelegate) =>
      oldDelegate.active != active;
}

class _PersonBubble extends StatelessWidget {
  const _PersonBubble({
    required this.person,
    required this.index,
    required this.selected,
    required this.size,
  });

  final DiscoveryNearbyItem person;
  final int index;
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fill = index.isEven ? PsiColors.red : PsiColors.white;
    final ink = index.isEven ? PsiColors.white : PsiColors.black;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? PsiColors.white : PsiColors.black,
              width: selected ? 3 : 2,
            ),
            boxShadow: const [
              BoxShadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 3)),
            ],
          ),
          child: Text(
            person.displayName.isEmpty
                ? '?'
                : person.displayName[0].toUpperCase(),
            style: TextStyle(
              color: ink,
              fontWeight: FontWeight.w800,
              fontSize: size * 0.38,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          person.displayName,
          style: const TextStyle(
            color: PsiColors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            shadows: [Shadow(color: Colors.black, blurRadius: 6)],
          ),
        ),
      ],
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({required this.person, required this.onWave});

  final DiscoveryNearbyItem person;
  final VoidCallback onWave;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PsiColors.white,
      elevation: 8,
      shadowColor: Colors.black54,
      borderRadius: BorderRadius.circular(28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: PsiColors.red,
                shape: BoxShape.circle,
                border: Border.all(color: PsiColors.black, width: 2),
              ),
              child: Text(
                person.displayName.isEmpty
                    ? '?'
                    : person.displayName[0].toUpperCase(),
                style: const TextStyle(
                  color: PsiColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              person.displayName,
              style: const TextStyle(
                color: PsiColors.black,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${person.distanceLabel} · ${person.communityName}',
              style: const TextStyle(
                color: PsiColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: PsiButtons.filled(),
                onPressed: onWave,
                child: const Text('Wave'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HiddenCard extends StatelessWidget {
  const _HiddenCard({required this.hidden});

  final bool hidden;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PsiColors.white,
      borderRadius: BorderRadius.circular(28),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          hidden
              ? 'You are hidden. Turn off “Hide my location” to see people from your communities.'
              : 'No one from this community is nearby right now.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: PsiColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _HideLocationBar extends StatelessWidget {
  const _HideLocationBar({
    required this.hidden,
    required this.busy,
    required this.onChanged,
  });

  final bool hidden;
  final bool busy;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PsiColors.white,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Hide my location',
                style: TextStyle(
                  color: PsiColors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Switch(
              value: hidden,
              onChanged: busy ? null : onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityPill extends StatelessWidget {
  const _CommunityPill({
    required this.communities,
    required this.selectedId,
    required this.onChanged,
  });

  final List<Community> communities;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: PsiColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PsiColors.black, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedId,
            isDense: true,
            dropdownColor: PsiColors.white,
            style: const TextStyle(
              color: PsiColors.black,
              fontWeight: FontWeight.w700,
            ),
            items: communities
                .map(
                  (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
