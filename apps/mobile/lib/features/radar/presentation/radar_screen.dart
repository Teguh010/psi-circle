import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

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
  String? _communityId;
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
      _communityId = communities.isNotEmpty ? communities.first.id : null;
      _presence = presence;
      _loading = false;
    });
    if (presence.isVisible && _communityId != null) {
      await _loadNearby();
    }
  }

  Future<void> _loadNearby() async {
    final communityId = _communityId;
    if (communityId == null) return;
    final nearby = await ref
        .read(discoveryRepositoryProvider)
        .nearby(communityId: communityId);
    setState(() => _nearby = nearby);
  }

  Future<void> _setHidden(bool hidden) async {
    await _toggleVisibility(!hidden);
  }

  Future<void> _toggleVisibility(bool visible) async {
    final communityId = _communityId;
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
      return const Scaffold(
        backgroundColor: PsiColors.black,
        body: Center(child: CircularProgressIndicator(color: PsiColors.red)),
      );
    }

    final visible = _presence?.isVisible ?? false;

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
                      Color(0x99111111),
                      Color(0x22111111),
                      Color(0x00000000),
                    ],
                    stops: [0, 0.18, 0.42],
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
                            onTap: () => context.push(
                              '/radar/member',
                              extra: _nearby[i],
                            ),
                            child: _PersonBubble(
                              person: _nearby[i],
                              index: i,
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
              padding: const EdgeInsets.fromLTRB(16, 6, 8, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Text(
                      'People nearby',
                      style: TextStyle(
                        color: PsiColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _LocationToggle(
                    visible: visible,
                    busy: _busy,
                    onChanged: (show) => _setHidden(!show),
                  ),
                ],
              ),
            ),
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
    required this.size,
  });

  final DiscoveryNearbyItem person;
  final int index;
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
              color: PsiColors.black,
              width: 2,
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

class _LocationToggle extends StatelessWidget {
  const _LocationToggle({
    required this.visible,
    required this.busy,
    required this.onChanged,
  });

  final bool visible;
  final bool busy;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          visible ? 'Hide your location' : 'Show your location',
          style: const TextStyle(
            color: PsiColors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            shadows: [Shadow(color: Colors.black, blurRadius: 6)],
          ),
        ),
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: visible,
            onChanged: busy ? null : onChanged,
          ),
        ),
      ],
    );
  }
}

