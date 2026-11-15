import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/session_controller.dart';

/// Interests are local onboarding UX (PRD §3.2). Not yet an OpenAPI endpoint.
const kInterestOptions = [
  'Automotive',
  'Cycling',
  'Running',
  'Photography',
  'Gaming',
  'Music',
  'Hiking',
  'Coffee',
  'Tech',
  'Alumni',
];

class InterestSelectionScreen extends ConsumerStatefulWidget {
  const InterestSelectionScreen({super.key});

  @override
  ConsumerState<InterestSelectionScreen> createState() =>
      _InterestSelectionScreenState();
}

class _InterestSelectionScreenState
    extends ConsumerState<InterestSelectionScreen> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your interests')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pick a few interests so we can suggest communities.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Stored locally for now — no API field yet.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kInterestOptions.map((interest) {
                      final selected = _selected.contains(interest);
                      return FilterChip(
                        label: Text(interest),
                        selected: selected,
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              _selected.add(interest);
                            } else {
                              _selected.remove(interest);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              FilledButton(
                onPressed: _selected.isEmpty
                    ? null
                    : () {
                        ref
                            .read(sessionControllerProvider.notifier)
                            .setInterests(_selected.toList());
                        context.go('/onboarding/communities');
                      },
                child: Text(
                  _selected.isEmpty
                      ? 'Select at least one'
                      : 'Continue (${_selected.length})',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
