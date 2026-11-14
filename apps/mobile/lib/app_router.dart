import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Placeholder root router. Each feature will register its own routes here
/// as it is built against the OpenAPI contract (see AGENTS.md §4).
final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PlaceholderHomeScreen(),
    ),
  ],
);

class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Psi Circle')),
      body: const Center(
        child: Text('Psi Circle — Phase 1 foundation. No feature UI yet.'),
      ),
    );
  }
}
