import 'package:flutter/material.dart';

import '../../../core/models/discovery.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/psi_app_bar.dart';

/// Full-screen profile opened from a Radar avatar. Distance stays bucketed;
/// this page never shows coordinates.
class NearbyMemberScreen extends StatelessWidget {
  const NearbyMemberScreen({super.key, required this.person});

  final DiscoveryNearbyItem person;

  @override
  Widget build(BuildContext context) {
    final initial = person.displayName.isEmpty
        ? '?'
        : person.displayName[0].toUpperCase();

    return Scaffold(
      backgroundColor: PsiColors.white,
      appBar: const PsiAppBar(title: Text('Nearby')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            children: [
              Container(
                width: 112,
                height: 112,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: PsiColors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: PsiColors.black, width: 2),
                ),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: PsiColors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                person.displayName,
                style: const TextStyle(
                  color: PsiColors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '@${person.username}',
                style: const TextStyle(
                  color: PsiColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PsiColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PsiColors.black, width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      person.distanceLabel,
                      style: const TextStyle(
                        color: PsiColors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      person.communityName,
                      style: const TextStyle(
                        color: PsiColors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: PsiButtons.filled(),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Wave to ${person.displayName}')),
                    );
                  },
                  child: const Text('Wave'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
