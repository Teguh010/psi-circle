import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: PsiColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                width: 48,
                height: 4,
                color: PsiColors.red,
              ),
              const SizedBox(height: 20),
              Text(
                'Psi Circle',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: PsiColors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Discover people from your communities when you are nearby.',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: PsiColors.muted,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.push('/register'),
                child: const Text('Create account'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.push('/login'),
                child: const Text('Log in'),
              ),
              const SizedBox(height: 8),
              Text(
                'Mock data mode — no backend calls yet',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: PsiColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
