import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Mock map for Radar. Centers on the caller's approximate area only.
/// Other users are never plotted at precise coordinates (privacy rule).
class RadarMap extends StatelessWidget {
  const RadarMap({
    super.key,
    required this.center,
    required this.isVisible,
    this.radiusMeters = 3000,
    this.fullBleed = false,
  });

  /// Caller's own mock/real position — never another user's coords.
  final LatLng center;
  final bool isVisible;
  final int radiusMeters;
  final bool fullBleed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(fullBleed ? 0 : 16),
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 14,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.drag |
                    InteractiveFlag.pinchZoom |
                    InteractiveFlag.doubleTapZoom,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.psicircle.psi_circle_mobile',
              ),
              if (isVisible)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: center,
                      radius: radiusMeters.toDouble(),
                      useRadiusInMeter: true,
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderColor: colorScheme.primary.withValues(alpha: 0.45),
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: center,
                    width: 44,
                    height: 44,
                    child: Icon(
                      Icons.my_location,
                      color: colorScheme.primary,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Text(
                  '© OpenStreetMap',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
