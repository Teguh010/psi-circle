import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Passed at build time via `--dart-define-from-file=dart_defines.json`.
/// Empty in CI and fresh clones: the map falls back to darkened OSM tiles.
const cartoApiKey = String.fromEnvironment('CARTO_API_KEY');

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

    const mapBackground = Color(0xFF0E0E0E);

    return ColoredBox(
      color: mapBackground,
      child: SizedBox.expand(
        child: FlutterMap(
          key: ValueKey(
            '${MediaQuery.sizeOf(context).width.toStringAsFixed(0)}x'
            '${MediaQuery.sizeOf(context).height.toStringAsFixed(0)}',
          ),
          options: MapOptions(
            initialCenter: center,
            initialZoom: 14,
            backgroundColor: mapBackground,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.drag |
                  InteractiveFlag.pinchZoom |
                  InteractiveFlag.doubleTapZoom,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: cartoApiKey.isEmpty
                  ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
                  : 'https://basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}.png?key=$cartoApiKey',
              userAgentPackageName: 'com.psicircle.psi_circle_mobile',
              tileBuilder: cartoApiKey.isEmpty ? darkModeTileBuilder : null,
            ),
            RichAttributionWidget(
              attributions: [
                const TextSourceAttribution('OpenStreetMap contributors'),
                if (cartoApiKey.isNotEmpty)
                  const TextSourceAttribution('CARTO'),
              ],
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
