import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Mock map for Radar. Centers on the caller's approximate area only.
/// Other users are never plotted at precise coordinates (privacy rule).
class RadarMap extends StatelessWidget {
  const RadarMap({
    super.key,
    required this.center,
  });

  /// Caller's own mock/real position — never another user's coords.
  final LatLng center;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: const Color(0xFFE6E6E6),
      child: SizedBox.expand(
        child: FlutterMap(
          key: ValueKey(
            '${MediaQuery.sizeOf(context).width.toStringAsFixed(0)}x'
            '${MediaQuery.sizeOf(context).height.toStringAsFixed(0)}',
          ),
          options: MapOptions(
            initialCenter: center,
            initialZoom: 14,
            backgroundColor: const Color(0xFFE6E6E6),
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
            MarkerLayer(
              markers: [
                Marker(
                  point: center,
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
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
      ),
    );
  }
}
